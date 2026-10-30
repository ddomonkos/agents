# Setup help

Read only the entry relevant to a missing capability or failed step. This isn't a
preflight checklist. Use the runtime's available tools and configured access;
don't assume a particular tool name, secret store, or workspace layout.

## Missing prerequisites

| Missing capability | What the human needs to provide |
| --- | --- |
| Private evidence storage | A writable private directory for context, screenshots, and records. Prefer a location outside Git; inside a checkout, verify that Git ignores it. |
| Product automation | Headless browser automation plus screenshot inspection, with access to the target app. Ask permission before installing tools or opening a visible browser. |
| Running a revision locally | The repository's documented prerequisites. Ask before installing system tools; follow the repository's setup docs. |
| Test account | A dedicated account with the permissions and capabilities the cases need, plus a private credential reference. Read the app guide's account section before requesting provisioning. |
| Independent review | A separate agent that can inspect saved context and images without credentials or live product access. If unavailable, finish reachable work and mark the result unreviewed. |

## Explain the blocker

Use the failed operation and, if needed, a targeted check to distinguish a network
failure, missing authentication, denied permission, and missing data. A failed
login doesn't prove an account lacks the feature. Reuse working setup within the
session; revisit only the failed prerequisite or a changed environment/identity.

Tell the human:

- What is missing and which step it prevents.
- What you attempted and the observed failure, without secrets or login tokens.
- The smallest setup action needed, with short instructions from the relevant guide.

Never ask for passwords or tokens in chat. Resume the affected step after setup;
don't repeat the whole workflow or translate a blocker into a negative result.

## Runtime compatibility

The skill uses a `SKILL.md` and linked references.
[Claude Code supports this format and symlinked skill directories](https://code.claude.com/docs/en/skills#where-skills-live).
[ChatGPT supports skill uploads](https://help.openai.com/en/articles/20001066-skills-in-chatgpt)
where Skills is enabled. Include the references when installing or uploading.
Loading instructions doesn't supply tools or access to a local VPN, credential
store, or account inventory. Full product testing in Claude Code and ChatGPT
hasn't been verified; use the workflow only with the required capabilities.
