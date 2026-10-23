---
name: writing-commit-messages
description: >-
  Use when writing, rewriting, or reviewing Git commit messages in this repository. Enforces
  Conventional Commits and valid Nx scopes, then adds durable what/why context so history stays
  useful for review, blame, revert, and debugging.
---

## Intent

Produce commit messages that pass repository conventions and remain useful months later without
opening the diff.

Use this two-gate workflow in order:

1. Format gate: enforce Conventional Commit structure and valid scope.
2. Content gate: capture impact, motivation, constraints, and validation.

## Gate 1: Format (must pass)

Required header pattern:

```
<type>(<scope>): <summary>
<type>: <summary>
<type>(<scope>)!: <summary>
<type>!: <summary>
```

Types allowed in this repo:

- `feat`: new feature in production code
- `fix`: bug fix in production code
- `build`: build system, dependencies, or auxiliary tooling
- `ci`: CI configuration/scripts
- `docs`: documentation-only changes
- `style`: formatting/whitespace (no meaning change)
- `refactor`: refactor without feature or bugfix behavior change
- `perf`: runtime performance improvement
- `test`: add/fix tests
- `chore`: miscellaneous maintenance/moves/removals
- `hotfix`: urgent production fix (use sparingly)
- `revert`: revert a previous commit

Scope rules:

- Scope is optional.
- If used, scope must be a valid Nx project name (`project.json` -> `name`).
- Determine scope from changed files by walking up to nearest `project.json`.
- If change is outside Nx projects or workspace-wide, omit scope.
- For 2-3 affected projects, multi-scope may be used: `fix(admin,auth): ...`.
- Validate chosen scope(s) with: `yarn -s nx show projects --sep=","`.

Subject rules:

- Imperative mood (`prevent`, `reject`, `remove`).
- Describe effect, not implementation details.
- Lowercase summary, no trailing period.
- Keep header concise (target <= 72 chars when practical).
- One reviewable change per commit. Split mechanical moves, behavior changes, tests, and style-only
  edits when mixing them would make the diff harder to trust.

Breaking changes:

- Add `!` in header (`feat(core)!: ...`).
- Add a `BREAKING CHANGE:` paragraph with migration steps.

Reverts:

```
revert: <original header>

This reverts commit <hash>.
```

## Gate 2: Content (quality)

Length should follow how much needs explaining, not how big or important the commit feels. Most of
the guidance below applies when a body is needed; it does not make a body mandatory.

- Header only: the change is obvious from the header and the reason is clear or unimportant
  (typo fixes, dependency bumps, small renames, straightforward cleanups).
- One or two sentences: the change is simple, but the reason is not obvious from the header.
- Longer body: the motivation, constraints, trade-offs, or risks are non-obvious. Even a one-line
  diff can deserve this if the reason behind it is subtle.

Do not pad a short message to make it look thorough. Restating the diff, explaining obvious
motivation, or adding sections with nothing new to say makes the important commits harder to spot.

### Primary Principles

- **Inverted Pyramid First**

  Start the body with the most important context in the first 1-3 lines. State the outcome and
  stakes before details, so a reader scanning history gets the key point immediately.

- **Name Replaced Behavior Before New Behavior**

  When a change fixes, speeds up, or replaces existing behavior, open the body with the old behavior,
  symptom, or cost that made the change necessary. Then describe the new behavior as the resolution.
  This gives readers the problem before the answer.

  Avoid opening with only "X now does Y" unless the old behavior is obvious from the header or diff.
  A stronger shape is: "The previous validation accepted blank names, which let users create records
  that were hard to identify later. We reject blank names before saving, so every record has a
  readable label."

- **Keep Context In The Commit**

  If a reviewer needs context to understand the change, write that context in the commit message
  itself. Do not rely on side channels (chat, DM, meeting notes, ad-hoc comments) because they are
  not durable.

  Describe only the final change in the commit, not temporary implementation states, review
  iterations, or other history that existed only inside the PR. If a commit is amended, its message
  must still make sense as if the final diff was written directly.

- **Prefer Prose, Use Bullets Sparingly**

  Write short natural paragraphs by default. Use bullets only when they improve structure and
  readability, such as command lists, risk lists, alternatives, or verification steps.

- **Use Active Voice Without Mechanical Repetition**

  Prefer active voice when describing deliberate changes, but vary sentence shape so commit bodies
  do not read like a sequence of identical openings. Passive or result-state phrasing is fine when
  the configured state matters more than the actor.

  Scan sentence and paragraph openings across the whole body. A cluster that repeatedly starts with
  `We`, `This`, the same tool name, or the same grammatical frame sounds mechanical. Vary it with an
  accurate context-first opening, named person or tool, time or condition clause, or result-state
  sentence. Keep deliberate repetition when it improves emphasis, and do not introduce false agency
  just to create variety.

- **Avoid False Agency**

  Do not make technical containers sound like actors. Configs, setup files, docs, commits, and
  projects usually contain or describe changes; they do not decide or perform them. Prefer active
  voice with a real actor when the actor matters, or passive/result-state phrasing when the actor is
  not important.

  Use technical objects as subjects when they actually perform runtime behavior or when the verb is
  about containment or state. For example, "the runner resolves modules", "the compiler reports an
  error", and "the config includes Vitest globals" are fine. Avoid phrasing where a container takes
  an action that belongs to us, a tool, or the runtime.

- **Use Plain, Natural Wording**

  Write commit bodies as durable prose, not internal shorthand. Avoid compressed implementation
  phrases such as adjective-stacked labels, slash-heavy nouns, or invented terms that only make
  sense while the diff is fresh.

  Prefer a short plain phrase over a compact technical label. For example, write "when vote labels
  were formatted separately from the rendered timestamp" instead of "formatted-label path".

  Avoid unexplained continuation language. Do not use words such as "still", "continues", "keeps",
  "remains", or "preserves" unless the message first explains the original behavior, contract, or
  state being continued. If that history is not needed, prefer current-state wording that describes
  the final behavior directly.

- **Use Proper Markdown**

  Treat commit bodies as Markdown. Wrap code identifiers and literals in backticks, including DOM
  attributes, ARIA attributes, component names, function names, commands, file paths, and exact
  error strings. Do not wrap ordinary prose.

- **Do Not Add Verification By Default**

  Do not add a `Testing:` or `Verification:` section automatically. Include verification only when
  it explains a non-obvious manual scenario, risky migration, cross-environment check, or other
  decision-relevant validation. Routine command runs such as `lint`, `test`, and `typecheck` do not
  belong in commit messages.

Optional structured template (for longer commit bodies):

```
<header>

Impact:
<1-3 lines of prose with highest-value context first>

Motivation:
<prose on problem, constraints, and trade-offs>

Alternatives:
<optional; only for non-obvious decisions>

Limitations:
<optional; known gaps, risk boundaries, follow-up constraints>

Surprising constraints / what was learned:
<optional; non-obvious facts future maintainers should know>

Testing:
<optional; include only non-trivial verification scenarios>

Related to <JIRA-ID>
```

When relevant, include:

- User-visible behavior changes or guarantees.
- Failure symptom and trigger conditions.
- Constraint/trade-off that shaped the solution.
- Alternatives considered when choice is non-obvious.
- Explicit migration/revert notes for risky changes.
- Known limitations or follow-up work.
- Surprising constraints or non-obvious learned facts.
- Searchable artifact strings (error text/signature).

Visual/media guidance (compressed):

- If behavior change is primarily visual, add a short screenshot/video link.
- Keep media supplemental; key facts still go in text.
- Prefer stable locations (PR discussion) over fragile long-term URLs.

Keep durable references:

- Include ticket IDs and short context summary.
- If the commit fixes or closes the Jira task, put it at the bottom as `Fixes <JIRA-ID>` or
  `Closes <JIRA-ID>`.
- If the commit does not fix or close the task and is only related to it, put it at the bottom as
  `Related to <JIRA-ID>` or `References <JIRA-ID>`.
- Do not rely on links alone; summarize the key point in text.

## What To Exclude

- Diff-obvious details ("renamed X to Y", file-by-file narration).
- Intermediate PR history that is not present in the final diff.
- Temporary review chatter or personal notes.
- Expiring preview/build artifact URLs in permanent history.
- Long implementation walkthroughs better suited for code comments/docs.
- When rewriting a commit stack, describe the final commit history only. Do not mention that changes
  were moved between commits, split out, folded, or adjusted during review.
- For mechanical move commits, say what was copied or moved and which small integration edits were
  included.

## Practical Workflow

1. Inspect staged diff (`git status`, `git diff --staged`) and split it first if it mixes
   mechanical moves, behavior changes, tests, or style-only edits.
2. Pick type and valid scope (or omit scope).
3. Write effect-focused header.
4. Start body with the replaced behavior or failure mode when the change fixes an existing state;
   otherwise use inverted-pyramid prose with impact first, then motivation.
5. Add alternatives/limitations only when they reduce future ambiguity.
6. Add non-trivial verification notes only when they add unique context; skip routine command lists.
7. Add references, media links (if useful), and breaking/migration notes.
8. Final pass: message should make sense without opening diff. Cut sentences that only restate the
   header or diff; a short message is fine when nothing else needs explaining.

## Quick Review Checklist

- Header matches Conventional Commit format.
- Type is allowed; scope is valid Nx project name if present.
- Summary is effect-focused and specific.
- Diff matches the message: no style-only edits, reorderings, or remove-then-restore changes unless
  they are part of the commit.
- Body starts with highest-value context (inverted pyramid).
- When replacing behavior, body names the old behavior, symptom, or cost before the new state.
- Body explains impact and motivation for non-trivial changes.
- Length matches what needs explaining: simple changes with clear motivation stay short or
  header-only; no padding.
- Body uses natural prose; bullets are used only when they improve clarity.
- Sentence and paragraph openings vary naturally; repeated `We`, `This`, or tool-name openings are
  deliberate rather than mechanical.
- Body avoids false agency: technical containers do not act unless the sentence describes real
  runtime behavior, containment, or state.
- Body avoids compressed implementation shorthand and uses plain wording a future reader can
  understand without the current PR context.
- Continuation language is grounded: any "still", "continues", "keeps", "remains", or "preserves"
  wording first names the previous behavior or has been rewritten as current-state prose.
- Body uses proper Markdown formatting for code identifiers, DOM/ARIA attributes, commands, paths,
  and exact literals.
- Alternatives and limitations are present when decision/risk is non-obvious.
- Surprising constraints/learned facts are captured when relevant.
- Testing/verification is not added by default and is included only when non-trivial and
  decision-relevant.
- Breaking changes are explicitly marked and actionable.
