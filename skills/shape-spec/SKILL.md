---
name: shape-spec
description: Collaboratively shape product, feature, system, API, process, requirements, PRD, or technical-design specifications through progressive refinement in an evolving file. Use when the user asks to create, draft, define, explore, or refine a specification from an incomplete idea, especially when decisions should be discussed before becoming requirements, the user's language should be preserved, and the document's evolution should remain visible through diffs and milestone commits. Do not use for simple proofreading or summarization of an already-settled specification unless the user wants to reopen its decisions.
---

# Shape Specifications Progressively

Treat specification work like a progressively rendered image: establish the whole shape at low resolution, then sharpen the most consequential areas. Let the useful stopping point emerge from the work.

## Core Contract

- Use the specification file as the working surface from the beginning. Do not conduct a long chat-only interview and write the document afterward.
- Preserve the user's terminology, distinctions, uncertainty, and level of formality.
- Keep confirmed content distinct from proposals, open questions, and deferred or excluded ideas.
- Never promote an inference, convention, research finding, or best practice into a requirement without user agreement.
- Treat confirmation literally and atomically. Record only the meaning the user actually stated or selected; do not enrich it with adjacent prerequisites or likely details.
- Find gaps; do not silently fill them.
- Recommend the next useful increase in detail. Do not require the user to choose a final depth up front.
- Establish a coarse view of the whole before making one region highly detailed.
- Do not implement the specified work unless the user separately requests implementation.

## 1. Inspect Context and Agree on the File Location

Inspect relevant repository documentation, existing specification conventions, and nearby files before asking questions. Do not ask for information that reliable project context already answers.

Before the first write:

1. If the user supplied a path, use it.
2. Otherwise, identify the most suitable existing convention and ask where the specification file or files should live.
3. Include one concrete, repository-aware recommendation in the location question.
4. Wait for agreement before creating a new file.

Keep this as the only required setup question. Do not assume a default path. When refining an existing specification the user already identified, edit that file rather than asking again.

Default to one evolving specification file so there is one source of truth. Propose splitting files only when parts have meaningfully different audiences or lifecycles, or the document has become difficult to navigate. Get agreement before splitting.

## 2. Create the Seed Immediately

After the location is agreed, create a small but meaningful first version in the same turn. Adapt its structure to the use case; do not instantiate a standard PRD template.

The seed normally contains:

- A title.
- A visible `Status: Shaping` marker.
- A descriptive resolution marker such as `Resolution: Seed`.
- A short current understanding based only on user statements and established project facts.
- A provisional working map of the areas that appear worth resolving.
- The single most consequential open question, when one is already apparent.

Omit any element that would add noise. Mark the working map as provisional. Its bullets identify discussion areas, not promised sections or implied requirements.

## 3. Derive the Shape From the Use Case

Use these as reasoning lenses, never as mandatory headings:

- What is this trying to accomplish?
- Where are its meaningful boundaries?
- Which decisions could materially change the result?
- What evidence would show that the result is right?

Name topics in the user's language. Add security, performance, architecture, rollout, analytics, accessibility, compatibility, or testing only when the use case, project constraints, or intended handoff makes them relevant.

Revise the provisional map with the user until the overall image is recognizable. Avoid fully resolving one narrow area while the rest of the concept remains shapeless.

## 4. Run the Refinement Loop

Choose the next area by impact and uncertainty, then repeat:

1. Restate the currently confirmed understanding briefly.
2. Ask one focused question by default.
3. When real alternatives exist, offer a small number of distinct options with tradeoffs.
4. State the exact decision each option would confirm. Keep its rationale and possible consequences separate from that decision.
5. Label the recommended option as a proposal; never treat it as accepted by default.
6. Treat selection of an option as acceptance of only its stated decision, not its rationale, examples, prerequisites, or follow-on details.
7. After the answer, update the specification file promptly.
8. Before marking new text confirmed, verify that every semantic claim traces to the user's answer or authoritative project context. Otherwise mark it proposed or open.
9. Update the working map so resolved topics do not remain presented as unresolved.
10. Inspect the actual diff and summarize the change in meaning.
11. State what remains open and recommend the next useful focus.

Do not dump a comprehensive questionnaire. Ask follow-ups only when the answer materially affects scope, behavior, verification, risk, or a downstream decision.

Maintain these semantic states in the evolving document when needed:

- **Confirmed**: explicitly stated, established by authoritative project context, or approved by the user.
- **Proposal**: suggested by the agent and awaiting a decision.
- **Open**: unresolved and consequential.
- **Deferred / out**: intentionally postponed or excluded.

Keep proposals outside normative specification text until accepted. Clearly identify project facts sourced from the repository when they have not been endorsed as product decisions.

Approved text is stable, not immutable. If later information conflicts with it, explain why it needs to reopen, show the semantic change, and seek renewed agreement. Do not silently rewrite earlier decisions during cleanup.

## 5. Increase Resolution Adaptively

Use resolution labels to describe the document's present usefulness, not to impose a fixed lifecycle:

- **Seed**: captures the request and initial map.
- **Shape**: makes the overall intent, boundaries, and major decisions recognizable.
- **Behavior**: clarifies important flows, rules, states, and examples.
- **Delivery**: resolves relevant constraints, interfaces, failure behavior, and verification well enough for the intended handoff.

The user does not need to select one of these at the beginning or reach the last one. At a natural pause, report:

- What the document is now sufficient for.
- Which consequential areas remain blurry.
- The next refinement you recommend and why.
- Whether stopping at the current resolution is reasonable.

Increase resolution across the document before pursuing incidental detail. Zoom into a section early only when it is a linchpin or a material risk.

## 6. Review Without Inventing

At useful checkpoints, inspect the whole specification for:

- Contradictions or inconsistent terminology.
- Ambiguous or unverifiable normative statements.
- Missing boundaries or important scenarios.
- Unstated assumptions.
- Feasibility or dependency risks.
- Details that exceed the document's intended resolution.
- Confirmed statements that cannot be traced to a user decision or authoritative project fact.

Turn discoveries into an explicit question, proposal, or deferred item. Do not manufacture numeric targets, user needs, acceptance criteria, non-goals, edge cases, or technical constraints merely to satisfy a checklist.

When copyediting, preserve meaning. If a cleanup changes meaning or commitment, present it as a decision and obtain approval.

## 7. Use Diffs and Git Checkpoints

After every material edit, reason from the file's actual diff. Summarize semantic changes rather than only listing changed headings or line counts.

When the specification is in a Git repository, recommend a checkpoint commit when:

- The initial coarse shape is confirmed.
- The document moves to a meaningfully deeper resolution.
- A substantial section or coherent group of small sections is agreed.
- A risky change in direction is about to be explored.
- The document reaches a useful baseline.

Batch minor edits between milestones. Before recommending a commit:

1. Inspect repository status and the relevant specification diff.
2. Confirm the changes form one coherent checkpoint.
3. Mention unresolved items that remain.
4. Propose a concise Conventional Commit message, normally using the `docs` type.

Never stage or commit without user authorization. If authorized, include only the agreed specification files and preserve unrelated working-tree changes. Never push unless the user separately asks.

## 8. Hand Off the Current Resolution

When the user pauses or concludes shaping, leave the file internally coherent at its current resolution. Report:

- The specification path or paths.
- Its current resolution and what it is sufficient for.
- Confirmed scope and major decisions.
- Open, proposed, and deferred items.
- The latest semantic changes.
- Whether a checkpoint commit is recommended.
- The next refinement, if any, that would add the most value.

Do not present the specification as complete merely because the conversation is ending.

## Explicit Overrides

Follow an explicit user request for a different interaction style. If the user asks for a single-pass draft, produce it, but visibly distinguish sourced requirements from assumptions and proposals. If the user asks for multiple questions at once, batch them coherently. Preserve the core rule that unagreed additions must not masquerade as decisions.

## Avoid These Failure Modes

- Generating a polished, comprehensive first draft from a short request.
- Asking the user to choose an abstract specification depth before either party understands the work.
- Treating a generic template as a list of mandatory sections.
- Converting likely best practices into hidden requirements.
- Keeping the real specification in chat while the file remains stale.
- Filling every gap found during review.
- Rewriting approved sections during final assembly without showing the semantic delta.
- Committing after every answer or combining unrelated changes in a checkpoint.
