---
name: simple-review
description: Run a multi-pass code review with two independent reviewers in parallel, emphasizing simplicity, maintainability, readability, and practical correctness. Run only when explicitly invoked by the user.
disable-model-invocation: true
---

# Simple review

Run this skill only when the user explicitly invokes it using the environment's supported syntax, such as `/skill:simple-review` in OMP or `/simple-review` in Claude Code, or asks ChatGPT to use the skill. Don't start it for a general review request or while editing the skill.

Use this skill in OMP, Claude Code, or the ChatGPT app with parallel subagent support. Launch exactly two reviewer subagents in parallel using the environment's native tools. Each reviewer completes all passes in order within the same session. Don't launch additional reviewers; continue the existing reviewers when reconciliation needs a follow-up.

Prefer different models for the two reviewers when the environment makes them available. Otherwise, use the same available model in two separate reviewer contexts.

In OMP, use `codex-reviewer` and `claude-reviewer` when both are available, backed by the `CODEX-REVIEWER` and `CLAUDE-REVIEWER` model roles. Otherwise, choose available subagents that can carry out the complete review.

If the environment can't launch two subagents in parallel, report that limitation instead of substituting a single-reviewer or sequential workflow.

Do not use `review-anvil` or any related review-anvil skill.

Give both reviewers the same review scope and, when reviewing changes, the same comparison baseline. Resolve these from the request and repository context; ask only if materially ambiguous. Give both reviewers the same context and complete review instructions. Let them work independently from each other. Ask each reviewer to keep the passes distinct in its reasoning and report, while carrying relevant context forward. Conclusions from an earlier pass are useful context, not settled facts: the reviewer should revise them when later evidence contradicts them.

For PR reviews, consider existing review discussion and validate relevant author explanations against the current code before repeating a concern.

After both reviewers complete all passes, collect their findings, check material claims against the code and available context, and merge duplicates. If you disagree with a finding or the reviewers conflict, use the environment's messaging or continuation tools to ask the relevant reviewers to reconsider. Share the missing context or counterargument. Continue until you reach common ground or clearly identify the remaining disagreement. If follow-up isn't available, resolve what you can from the evidence and state any remaining material uncertainty. Do not decide by majority without examining the evidence.

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

## Final report

Present one concise report in simple, human-friendly language. Use technical detail only where it helps the author act.

Prioritize findings by impact. For each finding, explain why it matters and include file and line references where possible. Omit findings resolved as invalid during reconciliation. If a disagreement remains, state the positions and practical tradeoff.

State any material gaps in review coverage. Don't present an incomplete review as a clean result.

Keep minor issues and unlikely edge cases in an optional, brief footnote. Do not inflate the report with a play-by-play of the review process.