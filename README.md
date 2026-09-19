# Infinite Codex

> **Turn ChatGPT into Infinite Codex.**
>
> **Chat is the agent. GitHub is the memory. GitHub Actions is the computer.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Infinite Codex Runner](https://github.com/Houpeng0505/infinite-codex/actions/workflows/infinite-codex.yml/badge.svg?branch=infinite-codex%2Fdemo-v2)](https://github.com/Houpeng0505/infinite-codex/actions/workflows/infinite-codex.yml)
[![Agent Skill](https://img.shields.io/badge/Agent%20Skill-SKILL.md-black)](.agents/skills/infinite-codex/SKILL.md)

**Verified end to end:** [live GitHub Actions demo](https://github.com/Houpeng0505/infinite-codex/actions/runs/35410622690) — a committed mission ran on a fresh GitHub-hosted VM, the self-test passed, and the execution artifact was uploaded.

Infinite Codex is a tiny open-source workflow that lets a capable ChatGPT session do repository work in a Codex-like loop **without running a second coding agent inside GitHub Actions**.

Chat reasons and edits. GitHub persists code and history. GitHub Actions executes the real build, test, benchmark, or reproduction commands. Chat reads the result and decides the next edit.

## The idea

~~~text
                  Infinite Codex

                 ChatGPT / Chat
                     AGENT
                       |
              reason · plan · debug
                       |
                       v
                GitHub Repository
               PERSISTENT MEMORY
               read · edit · commit
                       |
                       v
                 GitHub Actions
                    COMPUTER
              install · run · test
                       |
                       v
             logs · artifacts · status
                       |
                       +------------> Chat
                                      |
                                   diagnose
                                      |
                                      +--> next edit
~~~

No agent-in-agent stack. No model call from the runner. No autonomous LLM hidden inside CI.

## Why

A coding agent needs two things:

1. **Intelligence** — understand the task, inspect code, plan changes, and diagnose failures.
2. **A computer** — install dependencies, run tests, build, benchmark, and execute scripts.

A capable Chat session already provides the first part. GitHub Actions can provide the second.

Infinite Codex connects them with ordinary Git state.

## Requirements

The Chat/agent surface must be able to:

- read the target GitHub repository;
- create or update branches and commit file changes;
- inspect GitHub Actions run status and logs, and optionally artifacts.

GitHub Actions must also be enabled for the repository.

If your current Chat surface only has read-only GitHub access, the fully automated loop is not available there.

## 3-minute setup

### 1. Add Infinite Codex to your repository

Copy:

~~~text
AGENTS.md
.agents/skills/infinite-codex/
.github/workflows/infinite-codex.yml
.infinite-codex/runner.sh
.infinite-codex/mission.sh
~~~

Or clone this repository and run:

~~~bash
./install.sh /path/to/your/repository
~~~

### 2. Work on an Infinite Codex branch

Use a branch such as:

~~~text
infinite-codex/add-login-api
~~~

Pushes containing an actual commit on **infinite-codex/** branches trigger the runner. Creating an empty task branch is skipped. A manual workflow dispatch is also available.

### 3. Give Chat a task

A useful instruction is:

~~~text
Use the Infinite Codex skill in this repository.
Implement the requested change on an infinite-codex/* branch.
Keep .infinite-codex/mission.sh focused on commands that prove the change works.
After each commit, inspect the GitHub Actions result and iterate until the mission passes.
Do not delegate coding work to another AI agent.
~~~

That is the product.

## What the runner does

The workflow checks out the committed revision and runs the committed mission through **.infinite-codex/runner.sh**.

Each execution records:

- mission exit code;
- repository, branch, and commit metadata;
- combined execution log;
- Markdown run summary;
- machine-readable result.json.

The four result files are uploaded as a GitHub Actions artifact, including on failed missions. The workflow then propagates the mission exit code so the GitHub check reflects the real result.

The runner receives only:

~~~yaml
permissions:
  contents: read
~~~

It does not commit changes, open pull requests, or call an AI model. Chat owns those decisions.

## Example missions

Python:

~~~bash
#!/usr/bin/env bash
set -euo pipefail
python -m pip install -e '.[dev]'
python -m pytest -q
~~~

Node:

~~~bash
#!/usr/bin/env bash
set -euo pipefail
npm ci
npm test
npm run build --if-present
~~~

Any repository:

~~~bash
#!/usr/bin/env bash
set -euo pipefail
./scripts/install-deps.sh
./scripts/test.sh
./scripts/build.sh
~~~

More examples are in the **examples/** directory.

## Why not put Codex, Claude Code, or another agent inside Actions?

Because that is a different architecture.

~~~text
Agent-in-Actions                 Infinite Codex
----------------                 --------------
Chat                             Chat
  |                                |
second coding agent              GitHub
  |                                |
runner                           Actions runner
~~~

Infinite Codex treats GitHub Actions as a **computer**, not an agent. The reasoning loop stays in the Chat conversation that already understands the user's intent.

## Security model

The committed mission is executable code. Review changes to **.infinite-codex/mission.sh** exactly like changes to any CI workflow.

The default workflow:

- runs only on manual dispatch or committed pushes to **infinite-codex/** branches;
- uses a GitHub-hosted runner;
- grants the token only **contents: read**;
- does not use pull_request_target;
- does not interpolate issue titles, PR bodies, or other untrusted text into shell commands;
- uploads execution evidence even when the mission fails.

Read [SECURITY.md](SECURITY.md) before adding secrets, write permissions, deployment credentials, or self-hosted runners.

## Agent Skill

The canonical skill is [.agents/skills/infinite-codex/SKILL.md](.agents/skills/infinite-codex/SKILL.md). **AGENTS.md** is the lightweight repository entry point.

The non-negotiable rule is:

> **Chat owns reasoning. Actions owns execution. Do not silently insert another coding agent between them.**

## FAQ

### Is the development quota literally infinite?

No. ChatGPT plans and GitHub Actions both have their own limits and policies. “Infinite Codex” is the project name and describes the workflow idea; it does not alter OpenAI quotas or bypass product restrictions.

### Does this require GPT-5.6 Sol?

No. The architecture is model-agnostic. It requires a sufficiently capable Chat/agent host with the repository and Actions capabilities listed above.

### Does the Actions VM persist between runs?

No. GitHub-hosted runners are disposable. Persistent state belongs in Git; run-only evidence belongs in artifacts.

## Trademark & affiliation

Infinite Codex is an independent open-source project and is not affiliated with, endorsed by, sponsored by, or produced by OpenAI. OpenAI, ChatGPT, Codex, and related names and marks belong to their respective owner(s). See [DISCLAIMER.md](DISCLAIMER.md) for the full notice.

The name **Infinite Codex** does not mean this project grants unlimited OpenAI Codex usage, changes OpenAI quotas, or bypasses product restrictions.

## License

MIT. See [LICENSE](LICENSE).

---

**Chat is the agent. GitHub is the memory. GitHub Actions is the computer.**
