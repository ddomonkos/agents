# Evidence review

Read this before reviewing an attempt. A fresh reviewer checks whether the saved
evidence supports each case outcome. It reviews the evidence, not the whole test,
and it doesn't repeat the test.

## Run the reviewer

Run a fresh, read-only reviewer subagent for each attempt. Use a different model
family when available, but don't require one to proceed. Don't give the reviewer
credentials, authenticated browser access, or permission to modify the product,
fixtures, or saved evidence.

Save a `review-input.json` packet containing:

- References to the brief and saved context, including the sources of expected
  results.
- The plan, actual setup, substitutions, and tested revisions or deployments.
- The ordered journey per case, evidence references, measurements, and
  limitations.
- This skill's environment rules, so the reviewer judges relevant dependencies,
  not platform-name equality.

Exclude the tester's outcomes, justifications, rendered reports, and earlier
review verdicts from this initial packet. The reviewer derives outcomes first;
compare them with the tester's afterward. Include corrected instructions and
factual setup changes when they exist.

Ask the reviewer to:

- Inspect the saved context and cited artifacts, including screenshots. Don't
  refetch sources or repeat the test.
- Check fidelity to the brief, preconditions, journey, environment substitutions,
  observation accuracy, and whether the evidence distinguishes the outcomes.
- Return an independently derived outcome per case, a verdict, and evidence
  citations for each material objection or limitation.
- For a correctable objection, specify the missing observation or prerequisite,
  corrected test instructions, and the evidence that would resolve it. Don't
  merely say "test again" or demand the original environment without explaining
  why it matters.

Save the response as `review.json`.

| Verdict | Next action |
| --- | --- |
| Accepted | Deliver if its outcomes agree with the tester's and no material objection remains. |
| Accepted with caveat | Deliver with the disclosed non-material caveat if outcomes agree. A material caveat needs a correction or a retest. |
| Retest | Run the targeted corrected test automatically, without asking the human for routine permission. |
| Invalid | Correct and rerun if possible; otherwise stop with the unsupported portion excluded from the conclusion. |

An outcome disagreement is a material objection to resolve, not a vote to take.
If existing evidence resolves a wording or interpretation problem, correct the
record and resubmit that evidence without an unnecessary rerun.

## Targeted retests

Before rerunning, record each material objection, its corrected instructions, and
the evidence expected to resolve it. Follow those instructions rather than
repeating the original steps. Keep the same saved context unless new context is
necessary; save and explain any new fetch. Create a fresh attempt directory that
records its predecessor and correction goals. Preserve earlier evidence and
reviews.

Run the targeted actions, save new evidence, then submit the new attempt to a
fresh reviewer. Include the evidence needed for the full scoped conclusion, with
explicit provenance for anything reused from an earlier attempt. Continue
automatically while each correction offers a concrete way to resolve a remaining
material objection. Usual permissions and safety boundaries still apply; ask only
when human provisioning or another unavailable prerequisite is needed.

Stop when the reviewer accepts the supported outcomes, or when the loop can't
make further useful progress:

- A required prerequisite is unavailable and you can't establish it.
- A corrective rerun leaves the same material objection without new
  discriminating evidence or a verified setup correction, and no different
  corrective action is available.
- Further reruns can't distinguish the competing explanations, or would require
  unsafe actions or changing the behavior under test.

Don't repeat unchanged steps until a reviewer agrees. A no-progress stop doesn't
turn a disputed result into an accepted one. Use blocked for an unavailable
prerequisite, or inconclusive for unresolved setup or evidence objections. Record
the attempts, unresolved objections, and the stopping reason in the record's
Review section.
