# Infinite Codex

> **Turn ChatGPT into Infinite Codex.**
>
> **Chat is the agent. GitHub is the memory. GitHub Actions is the computer.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-runner-2088FF?logo=githubactions&logoColor=white)](.github/workflows/infinite-codex.yml)
[![Agent Skill](https://img.shields.io/badge/Agent%20Skill-SKILL.md-black)](.agents/skills/infinite-codex/SKILL.md)

Infinite Codex is a tiny open-source workflow that lets a capable ChatGPT session do repository work in a Codex-like loop **without running a second coding agent inside GitHub Actions**.

Chat reasons. GitHub persists the code. GitHub Actions executes the real build/test commands. The results come back to Chat, which decides the next edit.

## Why this exists

A coding agent needs two things:

1. **Intelligence** — understand the task, inspect code, plan changes, debug failures.
2. **A computer** — install dependencies, run tests, build, benchmark, and execute scripts.

ChatGPT already provides the first part. GitHub Actions can provide the second.

```text
                       Infinite Codex

                    ChatGPT / Chat
                         AGENT
                           │
               reason · plan · debug
                           │
                           ▼
                    GitHub Repository
                   PERSISTENT MEMORY
                 read · edit · commit
                           │
                           ▼
                    GitHub Actions
                       COMPUTER
              install · run · build · test
                           │
                           ▼
              logs · artifacts · status
                           │
                           └──────────────► Chat
                                              │
                                           diagnose
                                              │
                                              └── next edit
```

No agent-in-agent stack. No model call from the runner. No autonomous LLM hidden inside CI.

## Requirements

Infinite Codex needs a Chat/agent surface that can:

- read the target GitHub repository;
- create or update branches and commit file changes;
- inspect GitHub Actions run status and logs (and optionally artifacts).

GitHub Actions must also be enabled for the repository. Different ChatGPT plans, surfaces, and GitHub integrations may expose different repository operations; if the current Chat can only read GitHub, the fully automated loop is not available in that surface.

## The loop

```text
Understand task
    ↓
Inspect repository
    ↓
Edit code + verification mission
    ↓
Commit to infinite-codex/<task>
    ↓
GitHub Actions starts a fresh VM
    ↓
Run the mission
    ↓
Read status / logs / artifact
    ↓
Diagnose and edit again
    ↓
Repeat until green
```

The runner is intentionally disposable. Persistent state belongs in Git: source, configuration, commits, and anything else that should survive the VM.

## 3-minute setup

### 1. Copy Infinite Codex into your repository

Copy these files/directories:

```text
AGENTS.md
.agents/skills/infinite-codex/
.github/workflows/infinite-codex.yml
.infinite-codex/runner.sh
.infinite-codex/mission.sh
```

Or, from a clone of this repository:

```bash
./install.sh /path/to/your/repository
```

### 2. Let Chat work on a dedicated branch

Use a branch such as:

```text
infinite-codex/add-login-api
```

Pushes to `infinite-codex/**` automatically trigger the runner. `workflow_dispatch` is also enabled as a manual fallback.

### 3. Give Chat a task

A useful first instruction is:

```text
Use the Infinite Codex skill in this repository.
Implement the requested change on an infinite-codex/* branch.
Keep .infinite-codex/mission.sh focused on the commands that prove the change works.
After each commit, inspect the GitHub Actions result and iterate until the mission passes.
Do not delegate the coding work to another AI agent.
```

That is the product.

## What the runner actually does

The workflow checks out the committed revision and executes:

```bash
bash .infinite-codex/mission.sh
```

`runner.sh` records:

- the mission exit code;
- repository / branch / commit metadata;
- a combined execution log;
- a Markdown run summary;
- a machine-readable `result.json`.

The `.infinite-codex/out/` directory is uploaded as a GitHub Actions artifact on every run, including failures.

The Action receives only `contents: read` permission by default. It does **not** commit changes, open PRs, or call an AI model. Chat owns those decisions.

## Example missions

### Python / pytest

```bash
#!/usr/bin/env bash
set -euo pipefail
python -m pip install -e '.[dev]'
python -m pytest -q
```

### Node

```bash
#!/usr/bin/env bash
set -euo pipefail
npm ci
npm test
npm run build --if-present
```

### Any repository

```bash
#!/usr/bin/env bash
set -euo pipefail
./scripts/install-deps.sh
./scripts/test.sh
./scripts/build.sh
```

More examples are in [`examples/`](examples/).

## Why not put Codex / Claude Code / another agent inside Actions?

Because that is a different architecture.

```text
Agent-in-Actions approach             Infinite Codex
─────────────────────────             ──────────────
Chat                                  Chat
  ↓                                     ↓
second coding agent                   GitHub
  ↓                                     ↓
runner                                Actions runner
```

Infinite Codex treats GitHub Actions as a **computer**, not an agent. The reasoning loop stays in the Chat conversation that already understands the user's intent.

## What this is good for

- implementation that needs real tests rather than guessed correctness;
- dependency installation that does not fit the Chat sandbox;
- Linux-only reproduction;
- builds, linters, formatters, type checks, benchmarks, and integration tests;
- preserving an auditable Git history while Chat iterates;
- using a disposable clean environment to catch “works on my machine” assumptions.

## What this is not

- an OpenAI Codex quota bypass;
- a way to obtain unlimited model usage;
- a replacement for GitHub Actions security controls;
- a persistent VM;
- an agent running unattended forever;
- a reason to put secrets into prompts, commits, or logs.

## Security model

The committed mission is executable code. Treat changes to `.infinite-codex/mission.sh` exactly like changes to any CI workflow.

The default workflow therefore:

- runs only on `workflow_dispatch` or pushes to `infinite-codex/**`;
- uses a GitHub-hosted runner;
- grants `GITHUB_TOKEN` only `contents: read`;
- does not use `pull_request_target`;
- does not interpolate issue titles, PR bodies, or other untrusted text into shell commands;
- uploads execution artifacts even when the mission fails.

Read [`SECURITY.md`](SECURITY.md) and the skill security reference before adding repository secrets or expanding permissions.

## Agent Skill

[`.agents/skills/infinite-codex/SKILL.md`](.agents/skills/infinite-codex/SKILL.md) follows the portable Agent Skills convention: YAML metadata plus concise operational instructions. `AGENTS.md` is the lightweight repository entry point, and detailed material stays beside the skill in its `references/` directory.

The skill has one non-negotiable rule:

> **Chat owns reasoning. Actions owns execution. Do not silently insert another coding agent between them.**

## Design principles

1. **One brain.** The active Chat session remains the sole reasoning agent.
2. **Git is memory.** Anything important enough to survive a run should be committed or stored as an artifact.
3. **Actions is disposable compute.** Never depend on runner-local state surviving the job.
4. **Verification over confidence.** A commit is not proof. A relevant successful mission is evidence.
5. **Small missions.** Each run should answer a concrete engineering question.
6. **Least privilege.** The runner should need very little authority because it does not own repository decisions.
7. **Readable history.** Commits should describe meaningful checkpoints, not hide the loop.

## Repository layout

```text
.
├── README.md
├── AGENTS.md
├── llms.txt
├── LICENSE
├── DISCLAIMER.md
├── SECURITY.md
├── CONTRIBUTING.md
├── LAUNCH.md
├── install.sh
├── .agents/
│   └── skills/
│       └── infinite-codex/
│           ├── SKILL.md
│           └── references/
│               ├── ACTIONS_LOOP.md
│               ├── ARCHITECTURE.md
│               └── SECURITY.md
├── .github/
│   └── workflows/
│       └── infinite-codex.yml
├── .infinite-codex/
│   ├── mission.sh
│   └── runner.sh
├── examples/
│   ├── generic.mission.sh
│   ├── node.mission.sh
│   └── python.mission.sh
└── scripts/
    └── self-test.sh
```

## FAQ

### Is the development quota literally infinite?

No. ChatGPT plans and GitHub Actions both have their own limits and policies. The name describes the workflow idea: move execution into GitHub Actions so a Chat session can keep doing verified repository work without making Codex the execution layer.

### Does this require GPT-5.6 Sol?

No. The architecture is model-agnostic. Any sufficiently capable Chat/agent host that can read and write the repository and inspect Actions results can use the loop.

### Does GitHub Actions remember previous runs?

No. GitHub-hosted runners are disposable. Persist source/state in Git and persist run outputs as artifacts when needed.

### Why a dedicated branch prefix?

It gives the execution boundary a visible, auditable trigger. Ordinary pushes elsewhere do not start the Infinite Codex runner.

### Can I use a self-hosted runner?

Technically yes, but it changes the threat model substantially. This template intentionally defaults to GitHub-hosted `ubuntu-latest`.

## Trademark & affiliation

Infinite Codex is an independent open-source project and is not affiliated with, endorsed by, sponsored by, or produced by OpenAI. OpenAI, ChatGPT, Codex, and related names and marks belong to their respective owners. See [`DISCLAIMER.md`](DISCLAIMER.md) for the full notice.

The name **Infinite Codex** does not mean this project grants unlimited OpenAI Codex usage, changes OpenAI quotas, or bypasses product restrictions.

## License

MIT. See [`LICENSE`](LICENSE).

---

**Chat is the agent. GitHub is the memory. GitHub Actions is the computer.**
