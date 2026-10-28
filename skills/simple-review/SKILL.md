---
name: simple-review
description: Run a multi-pass code review with two independent reviewers in parallel, emphasizing simplicity, maintainability, readability, and practical correctness. Run only when explicitly invoked by the user.
disable-model-invocation: true
---

# Simple review

Run this skill only when the user explicitly invokes it using the environment's supported syntax, such as `/skill:simple-review` in OMP or `/simple-review` in Claude Code, or asks ChatGPT to use the skill. Don't start it for a general review request or while editing the skill.

Use this skill in OMP, Claude Code, or the ChatGPT app with parallel subagent support. Launch exactly two reviewer subagents in parallel using the environment's native tools. Each reviewer completes all passes in order within the same session. When manual testing is warranted, also launch a tester and, for thorough testing, a test planner, as described in [Manual testing](#manual-testing). Don't launch other subagents; continue the existing ones when reconciliation needs a follow-up.

Prefer different models for the two reviewers when the environment makes them available. Otherwise, use the same available model in two separate reviewer contexts.

In OMP, use `codex-reviewer` and `claude-reviewer` when both are available, backed by the `CODEX-REVIEWER` and `CLAUDE-REVIEWER` model roles. Otherwise, choose available subagents that can carry out the complete review.

If the environment can't launch two subagents in parallel, report that limitation instead of substituting a single-reviewer or sequential workflow.

Do not use `review-anvil` or any related review-anvil skill.

Give both reviewers the same review scope and, when reviewing changes, the same comparison baseline. Resolve these from the request and repository context; ask only if materially ambiguous. Give both reviewers the same context and complete review instructions. Let them work independently from each other. Ask each reviewer to keep the passes distinct in its reasoning and report, while carrying relevant context forward. Conclusions from an earlier pass are useful context, not settled facts: the reviewer should revise them when later evidence contradicts them.

For PR reviews, consider existing review discussion and validate relevant author explanations against the current code before repeating a concern.

After both reviewers complete all passes and any manual testing is checked, collect the findings, check material claims against the code and available context, and merge duplicates. If you disagree with a finding or the reviewers conflict, use the environment's messaging or continuation tools to ask the relevant reviewers to reconsider. Share the missing context or counterargument. Continue until you reach common ground or clearly identify the remaining disagreement. If follow-up isn't available, resolve what you can from the evidence and state any remaining material uncertainty. Do not decide by majority without examining the evidence.

Check that each recommended change addresses the underlying problem and is proportional to its impact. Prefer the smallest clear change that preserves required behavior.

If a reviewer finds a fundamental motivation or design problem that makes the remaining review wasteful, it may stop and report that problem instead of reviewing an implementation that should be reconsidered.

Before reporting a material finding, inspect the relevant surrounding code, callers, and tests. Distinguish a demonstrated defect from missing coverage or an unresolved design choice.

Do not invent findings. Each reported finding costs the author time and attention, so include it only when it matters. You may collect minor issues and unlikely edge cases while reviewing, but put them in a short footnote only when they provide useful context. It is valid to return no findings.

## 1. High-level motivation and design

Skip quickly to the next pass when the change and its benefit are obvious. Otherwise, trace the motivation through available linked resources.

Critically assess the motivation and chosen approach before accepting the implementation:

- Does the implementation still match the problem and any prior design agreement?
- Is the change worth making?
- Is the approach proportional to the problem?
- Would an existing project or vendor solution serve the need better than custom code?

## 2. Test coverage

Using the motivation and design conclusions, assess whether the planned behavior has appropriate test coverage.

Focus on test titles and stated scenarios, not test implementation yet. Check whether:

- Important behaviors and boundaries are covered.
- Each named test case represents useful behavior.
- Expensive or complex tests justify their maintenance cost.
- Existing tests already cover the same behavior.
- Tests with substantial overlap would be clearer as one test.

Do not reward test count. Flag missing coverage only when a plausible regression would matter.

## 3. Test correctness

Read the test implementation. Verify that each test exercises and observes the behavior its title claims. Check setup, assertions, failure paths, and whether the test would fail for the regression it is meant to catch.

Flag tests that only verify mocks, wiring, implementation details, incidental defaults, or that code does not throw when the claimed behavior remains untested.

## 4. Implementation

Review the production code against the confirmed motivation, design, and tested behavior. Prioritize:

1. Simplicity
2. Maintainability
3. Readability
4. Correctness

Keep complexity proportional to exercised product behavior. Look for concrete defects, unnecessary abstraction, duplicated concepts, surprising control flow, unclear naming, and divergence from existing project patterns. Do not demand handling for hypothetical edge cases that the product does not exercise.

## 5. Documentation

Review the changed JSDoc, line comments, and commit message. If one of these is not part of the change, skip it.

Check whether the text:

- Is clear and understandable to someone who did not work on the change.
- Accurately describes the final behavior and the reason behind it.
- Includes only information relevant to its audience.
- Avoids developer journey details, abandoned approaches, and intermediate decisions that do not help an outside reader understand the final result.

Comments should explain useful context that the code cannot express clearly on its own. In longer functions, also allow brief comments that separate the function into logical blocks and make it easier to scan, even when they describe the code below them. Otherwise, flag comments that merely repeat the code, preserve stale implementation history, or require missing conversational context to make sense.

## Manual testing

Manual testing runs alongside the review. It checks that the change works when actually used.

### Choose a testing level

Before launching the reviewers, pick a level and give a short reason in the final report:

- **None**: the change is small and low-risk, or automated tests already exercise the real behavior. Docs-only changes, behavior-preserving refactors, and test-only changes usually land here. Don't test something just because it's under review.
- **Targeted**: a moderate change. Test the changed behavior and its most likely breakage.
- **Thorough**: the change is complex, has significant consequences (such as data, auth, payments, migrations, or important user flows), or is broad.

### Plan

For thorough testing, launch a test planner on a strong model to write the plan. For targeted testing, the tester plans for itself using the same rules:

- Write one case per changed behavior. For a broad change, cover every changed item, not a sample. Items that behave identically may share a case only when the plan says so.
- Combine factors only where the code suggests they interact. Don't enumerate every combination.
- For each case, give the setup, steps, expected result, and the evidence to collect.
- Skip behavior that automated tests already exercise for real, and name those tests.

For thorough testing, check the plan for missed behavior and unnecessary cases before the tester starts.

### Execute

Launch a tester on a capable but faster model: Sonnet-level, not the smallest available. Testing can reveal problems the code didn't make obvious, so the tester needs to notice them. The tester:

- Uses the real product. It starts the app and exercises the change the way a user or client would. For frontend changes, it drives a real browser and captures screenshots. The browser runs headless, separate from the user's own browser, so it doesn't take focus or act in their signed-in sessions. If the environment's browser tool can't guarantee that, the tester uses a scriptable headless browser such as Playwright. Unit tests, rendered markup, or mocked responses don't count as manual testing.
- Saves evidence for each case, such as commands and output, screenshots, responses, or stored state.
- Reports unexpected behavior it notices as separate findings, without widening the plan.
- Doesn't edit project files, push, post, or touch shared or production environments. Before anything with external side effects, it stops and reports back so you can ask the user.
- Marks a case as blocked when it can't run it, with the reason. A blocked case never counts as passed.
- Records setup friction: each step needed to get the app or feature into a testable state that wasn't clear from the docs or scripts, even if the tester worked it out.

If no runnable environment can be set up, report manual testing as a coverage gap instead of guessing results.

### Check the testing

Check that the evidence shows each claimed result. For targeted testing, spot-check it yourself. For thorough testing, also ask a reviewer that has finished its passes to check the evidence. Reconcile testing findings the same way as review findings.

### Agents

In OMP, use `test-planner` and `tester`, backed by the `TEST-PLANNER` and `TESTER` model roles. In Claude Code, use Opus for the planner and Sonnet for the tester. Otherwise, use the closest available models, or the same model in separate contexts.

## Final report

Present one concise report in simple, human-friendly language. Use technical detail only where it helps the author act.

Prioritize findings by impact. For each finding, explain why it matters and include file and line references where possible. Omit findings resolved as invalid during reconciliation. If a disagreement remains, state the positions and practical tradeoff.

When a concrete scenario makes a finding easier to understand, include one, in both the report and PR comments. Keep it short and simple, and write it as bullet points: the starting state, what the user or system does, and what goes wrong. For example:

```markdown
- A user has two tabs open on the same form.
- They save in the first tab, then save in the second.
- The second save silently overwrites the first one.
```

Skip the scenario when the problem is already obvious from the explanation.

State any material gaps in review or testing coverage. Don't present an incomplete review as a clean result.

Report the testing level. If you tested, list failed and blocked cases, summarize what passed, and include a short "Setup friction" section when the tester recorded any. It tells the human where setup docs or flows could improve.

Keep minor issues and unlikely edge cases in an optional, brief footnote. Do not inflate the report with a play-by-play of the review process.

If you post findings as PR comments, keep each comment short and easy for a human to read. Say what's wrong, why it matters, and what to change. Leave out review process details. End every comment, including the review summary, with a signature line:

```markdown
_Posted by <agent> on behalf of @<user>._
```

Use your model family name for `<agent>`, such as Claude or GPT, and the GitHub handle of the person you're posting for as `<user>`.