# Launch Checklist

This file is for the repository maintainer and does not need to be copied into downstream projects.

## GitHub identity

**Repository name**

```text
infinite-codex
```

**Display name**

```text
Infinite Codex
```

**GitHub About / description**

```text
Turn ChatGPT into a Codex-like coding agent: Chat reasons, GitHub remembers, GitHub Actions runs the code. No second coding agent in CI.
```

**Website**

Leave blank until there is a real project page.

**Suggested topics**

```text
chatgpt
codex
github-actions
coding-agent
ai-coding
agent-skills
chatgpt-coding
codex-alternative
developer-tools
automation
ci
github
```

## First release

Suggested tag:

```text
v0.1.0
```

Suggested release title:

```text
Infinite Codex v0.1 — Chat is the agent. Actions is the computer.
```

Suggested launch copy:

```text
I built Infinite Codex: a tiny Agent Skill that turns an ordinary ChatGPT conversation into a verified GitHub development loop.

Chat is the agent.
GitHub is the memory.
GitHub Actions is the computer.

No second coding agent runs inside CI. Chat edits and commits; Actions runs the real tests; Chat reads the evidence and iterates.
```

## Before making the repository public

- Run `./scripts/self-test.sh`.
- Confirm `.github/workflows/infinite-codex.yml` has `contents: read` only.
- Confirm the workflow contains no API key or model call.
- Confirm `DISCLAIMER.md` is present and README keeps the short trademark/affiliation notice near the bottom rather than in the hero section.
- Mark the repository as a **Template repository** in GitHub settings.
- Add the suggested topics and the GitHub About description.
- Add a 1280×640 social preview image before external launch.
- Run one real public demo branch such as `infinite-codex/demo` so visitors can inspect an actual green Actions run.
- Add the run link or a short GIF to the README after the first public demo exists.
