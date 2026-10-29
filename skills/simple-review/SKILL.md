---
name: simple-review
description: Run a multi-pass code review with two independent reviewers in parallel, emphasizing simplicity, maintainability, readability, and practical correctness. Run only when explicitly invoked by the user.
disable-model-invocation: true
---

# Simple review

Run this skill only when the user explicitly invokes it using the environment's supported syntax, such as `/skill:simple-review` in OMP or `/simple-review` in Claude Code, or asks ChatGPT to use the skill. Don't start it for a general review request or while editing the skill.

Use this skill in OMP, Claude Code, or the ChatGPT app with parallel subagent support. Launch exactly two reviewer subagents in parallel using the environment's native tools. Each reviewer completes all passes in order within the same session. When manual testing is warranted, also launch the testing agents described in [Manual testing](#manual-testing). Don't launch other subagents; continue the existing ones when reconciliation needs a follow-up.

Prefer different models for the two reviewers when the environment makes them available. Otherwise, use the same available model in two separate reviewer contexts.

In OMP, use `codex-reviewer` and `claude-reviewer` when both are available, backed by the `CODEX-REVIEWER` and `CLAUDE-REVIEWER` model roles. Otherwise, choose available subagents that can carry out the complete review.

If the environment can't launch two subagents in parallel, report that limitation instead of substituting a single-reviewer or sequential workflow.

Do not use `review-anvil` or any related review-anvil skill.

Give both reviewers the same review scope and, when reviewing changes, the same comparison baseline. Resolve these from the request and repository context; ask only if materially ambiguous. Give both reviewers the same context and complete review instructions. Let them work independently from each other. Ask each reviewer to keep the passes distinct in its reasoning and report, while carrying relevant context forward. Conclusions from an earlier pass are useful context, not settled facts: the reviewer should revise them when later evidence contradicts them.

For PR reviews, consider existing review discussion and validate relevant author explanations against the current code before repeating a concern.

After both reviewers complete all passes and any manual testing is checked, collect the findings, check material claims against the code and available context, and merge duplicates. If you disagree with a finding or the reviewers conflict, use the environment's messaging or continuation tools to ask the relevant reviewers to reconsider. Share the missing context or counterargument. Continue until you reach common ground or clearly identify the remaining disagreement. If follow-up isn't available, resolve what you can from the evidence and state any remaining material uncertainty. Do not decide by majority without examining the evidence.

Check that each recommended change addresses the underlying problem and is proportional to its impact. Prefer the smallest clear change that preserves required behavior.

After reconciliation, check each remaining finding against the comparison baseline: did the change introduce the problem, or did it already exist? Code that was moved, renamed, or refactored can carry an old problem along so it looks new. Find the original code and check whether it behaved the same way. Mark a finding as pre-existing only when the baseline shows the same problem. Keep pre-existing findings in the report. The author may reasonably leave them out of a change that only moves code.

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

Manual testing runs alongside the review. It checks that the change works when actually used. This skill decides what to test. The [manual-testing](../manual-testing/SKILL.md) skill covers how: environments, browsers, accounts, evidence, outcomes, and the evidence review. Read it before testing. If it isn't installed, install it from `sli-do/agent-skills` with the user's permission, or report manual testing as a coverage gap.

### Choose a testing level

Before launching the reviewers, pick a level and give a short reason in the final report:

- **None**: the change is small and low-risk, or automated tests already exercise the real behavior. Docs-only changes, behavior-preserving refactors, and test-only changes usually land here. Don't test something just because it's under review.
- **Targeted**: a moderate change. Test the changed behavior and its most likely breakage.
- **Thorough**: the change is complex, has significant consequences (such as data, auth, payments, migrations, or important user flows), or is broad.

### Write the brief

Give the tester a manual-testing brief:

- **Purpose:** what the change is meant to do, from its description and linked issues.
- **Target:** the reviewed revision, such as the PR head commit or the user's working tree. For a bug fix, also the base revision: run the same steps on both to show the bug on the base and its absence on the change. Add the base for other cases only when a comparison is the clearest evidence.
- **Cases:** one per changed behavior. For a broad change, cover every changed item, not a sample. Items that behave identically may share a case only when the brief says so. Take expected results from the requirements, not from what the changed code does. Skip behavior that automated tests already exercise for real, and name those tests.
- **Limits:** don't edit the reviewed checkout, push, post, or touch shared or production environments. Allowed: running another revision in a separate worktree and installing its project dependencies, and installing a headless browser such as Playwright in a scratch directory outside the project.
- **Review:** full evidence review for thorough testing, spot-check for targeted.
- **Label:** the PR number or branch name.

For thorough testing, launch a test planner on a strong model to write the cases, then check them for missed behavior and unnecessary cases before the tester starts. For targeted testing, write the cases yourself or let the tester write them from the rest of the brief.

### Run and check

Launch a tester on a capable but faster model: Sonnet-level, not the smallest available. Testing can reveal problems the code didn't make obvious, so the tester needs to notice them. It follows manual-testing with your brief and returns the result per case.

Then review the evidence as manual-testing describes. For thorough testing, run its full evidence review with a fresh reviewer, preferably from a different model family than the tester. For targeted testing, spot-check the decisive evidence yourself. Reconcile testing findings the same way as review findings.

If no runnable environment can be set up, report manual testing as a coverage gap instead of guessing results.

### Agents

In OMP, use `test-planner` and `tester`, backed by the `TEST-PLANNER` and `TESTER` model roles, and `codex-reviewer` for the evidence review. In Claude Code, use Opus for the planner and Sonnet for the tester. Otherwise, use the closest available models, or the same model in separate contexts.

## Final report

Present one concise report in simple, human-friendly language. Use technical detail only where it helps the author act.

Prioritize findings by impact. For each finding, explain why it matters and include file and line references where possible. Label pre-existing findings as "Pre-existing" and point to where the problem was in the original code. Omit findings resolved as invalid during reconciliation. If a disagreement remains, state the positions and practical tradeoff.

When a concrete scenario makes a finding easier to understand, include one, in both the report and PR comments. Keep it short and simple, and write it as bullet points: the starting state, what the user or system does, and what goes wrong. For example:

```markdown
- A user has two tabs open on the same form.
- They save in the first tab, then save in the second.
- The second save silently overwrites the first one.
```

Skip the scenario when the problem is already obvious from the explanation.

State any material gaps in review or testing coverage. Don't present an incomplete review as a clean result.

Report the testing level and the tested revisions. If you tested, list failed, blocked, and inconclusive cases, summarize what passed, give the evidence review status (full, spot-check, or unreviewed) and the attempt directory, and include a short "Setup friction" section when the tester recorded any. It tells the human where setup docs or flows could improve.

Keep minor issues and unlikely edge cases in an optional, brief footnote. Do not inflate the report with a play-by-play of the review process.

In PR comments, link to code only when the author would want to open it, for example to see evidence for the finding or a related place outside the diff. Keep links few, usually one or two per comment. An inline comment already sits on its line, so don't link back to it. A plain comment with no links is often easiest to read. When you do link, use a commit permalink to the exact lines, such as `https://github.com/<owner>/<repo>/blob/<sha>/<path>#L10-L14`. Use the PR's head commit SHA for code in the change, and the base commit SHA for the original code behind a pre-existing finding. For Markdown files, add `?plain=1` before the line anchor. Use short link text such as `src/foo.ts:10`. When seeing the code helps, put the bare permalink on its own line instead, so GitHub shows the lines as an embedded snippet.

If you post findings as PR comments, keep each comment short and easy for a human to read. Say what's wrong, why it matters, and what to change. Leave out review process details. End every comment, including the review summary, with a signature line:

```markdown
_Posted by <agent> on behalf of @<user>._
```

Use your model family name for `<agent>`, such as Claude or GPT, and the GitHub handle of the person you're posting for as `<user>`.