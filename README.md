# Infinite Codex

> **Turn ChatGPT into Infinite Codex.**
>
> **Chat is the agent. GitHub is the memory. GitHub Actions is the computer.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Infinite Codex Runner](https://github.com/Houpeng0505/infinite-codex/actions/workflows/infinite-codex.yml/badge.svg?branch=infinite-codex%2Fdemo-v2)](https://github.com/Houpeng0505/infinite-codex/actions/workflows/infinite-codex.yml)
[![Agent Skill](https://img.shields.io/badge/Agent%20Skill-SKILL.md-black)](.agents/skills/infinite-codex/SKILL.md)

**Verified end to end:** [live GitHub Actions demo](https://github.com/Houpeng0505/infinite-codex/actions/runs/35410622690) â€” the committed mission ran on a fresh GitHub-hosted VM, the self-test passed, and the execution artifact was uploaded.

Infinite Codex is a tiny open-source workflow that lets a capable ChatGPT session do repository work in a Codex-like loop **without running a second coding agent inside GitHub Actions**.

Chat reasons. GitHub persists the code. GitHub Actions executes the real build/test commands. The results come back to Chat, which decides the next edit.

## Why this exists

A coding agent needs two things:

1. **Intelligence** â€” understand the task, inspect code, plan changes, debug failures.
2. **A computer** â€” install dependencies, run tests, build, benchmark, and execute scripts.

ChatGPT already provides the first part. GitHub Actions can provide the second.

```text
                       Infinite Codex

                    ChatGPT Chat
                         Agent
                           â”‚
               reason Â· plan Â· debug
                           â”‚
                           â–¼
                    GitHub Repository
                   Persistent Memory
                 read Â· edit Â· commit
                           â”‚
                           â–¼
                    GitHub Actions
                        Computer
             install Â» run Â· build Â· test
                           â”‚
                           â– 
              logs Â· artifacts Â· status
                           â”‚
                           â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–º Chat
                                                  â”‚
                                             diagnose
                                                  â”‚
                                                â””â”€ next edit
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
    â†“
Inspect repository
    â†“
Edit code + verification mission
    â†“
Commit to infinite-codex/<task>
    â†“
GitHub Actions starts a fresh VM
    â†“
Run the mission
    â†“
Read status / logs / artifact
    â†“
Diagnose and edit again
    â†“
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

The Action receives only `contents: read` permission by default. It does **not** commit changes, open PRs, crc call an AI model. Chat owns those decisions.

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
set -euo pipefall
./scripts/install-deps.sh
./scripts/test.sh
./scripts/build.sh
```

More examples are in [`examples/`](examples/).

## Why not put Codex / Claude Code / another agent inside Actions?

Because that is a different architecture.

```text
Agent-in-Actions approach            Infinite Codex
â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€              â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€)¡…Ğ€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€¡…Ğ(€ƒŠL€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ƒŠL)Í•½¹½‘¥¹œ…•¹Ğ€€€€€€€€€€€€€€€€€€¥Ñ!Õˆ(€ƒŠL€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€ƒŠL)ÉÕ¹¹•È€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€Ñ¥½¹ÌÉÕ¹¹•È)€()%¹™¥¹¥Ñ”½‘•àÑÉ•…ÑÌ¥Ñ!ÕˆÑ¥½¹Ì…Ì„€¨©½µÁÕÑ•È¨¨°¹½Ğ…¸…•¹Ğ¸Q¡”É•…Í½¹¥¹œ±½½ÀÍÑ…åÌ¥¸Ñ¡”¡…Ğ½¹Ù•ÉÍ…Ñ¥½¸Ñ¡…Ğ…±É•…‘äÕ¹‘•ÉÍÑ…¹‘ÌÑ¡”ÕÍ•ÈÌ¥¹Ñ•¹Ğ¸((ŒŒ]¡…ĞÑ¡¥Ì¥Ì½½™½È((´¥µÁ±•µ•¹Ñ…Ñ¥½¸Ñ¡…Ğ¹••‘ÌÉ•…°Ñ•ÍÑÌÉ…Ñ¡•ÈÑ¡…¸Õ•ÍÍ•½ÉÉ•Ñ¹•ÍÌì(´‘•Á•¹‘•¹ä¥¹ÍÑ…±±…Ñ¥½¸Ñ¡…Ğ‘½•Ì¹½Ğ™¥ĞÑ¡”¡…ĞÍ…¹‘‰½àì(´1¥¹Õàµ½¹±äÉ•ÁÉ½‘ÕÑ¥½¸ì(´‰Õ¥±‘Ì°±¥¹Ñ•ÉÌ°™½Éµ…ÑÑ•ÉÌ°ÑåÁ”¡•­Ì°‰•¹¡µ…É­Ì°…¹¥¹Ñ•É…Ñ¥½¸Ñ•ÍÑÌì(´ÁÉ•Í•ÉÙ¥¹œ…¸…Õ‘¥Ñ…‰±”¥Ğ¡¥ÍÑ½Éäİ¡¥±”¡…Ğ¥Ñ•É…Ñ•Ìì(´ÕÍ¥¹œ„‘¥ÍÁ½Í…‰±”±•…¸•¹Ù¥É½¹µ•¹ĞÑ¼…Ñ ƒŠqİ½É­Ì½¸µäµ…¡¥¹—Št…ÍÍÕµÁÑ¥½¹Ì¸((ŒŒ]¡…ĞÑ¡¥Ì¥Ì¹½Ğ((´…¸=Á•¹$½‘•àÅÕ½Ñ„‰åÁ…ÍÌì(´„İ…äÑ¼½‰Ñ…¥¸Õ¹±¥µ¥Ñ•µ½‘•°ÕÍ…”ì(´„É•Á±…•µ•¹Ğ™½È¥Ñ!ÕˆÑ¥½¹ÌÍ•ÕÉ¥Ñä½¹ÑÉ½±Ìì(´„Á•ÉÍ¥ÍÑ•¹ĞY4ì(´…¸…•¹ĞÉÕ¹¹¥¹œÕ¹…ÑÑ•¹‘•™½É•Ù•Èì(´„É•…Í½¸Ñ¼ÁÕĞÍ•É•ÑÌ¥¹Ñ¼ÁÉ½µÁÑÌ°½µµ¥ÑÌ°½È±½Ì¸((ŒŒM•ÕÉ¥Ñäµ½‘•°()Q¡”½µµ¥ÑÑ•µ¥ÍÍ¥½¸¥Ì•á•ÕÑ…‰±”½‘”¸QÉ•…Ğ¡…¹•ÌÑ¼€¹¥¹™¥¹¥Ñ”µ½‘•à½µ¥ÍÍ¥½¸¹Í¡€•á…Ñ±ä±¥­”¡…¹•ÌÑ¼…¹ä$İ½É­™±½Ü¸()Q¡”‘•™…Õ±Ğİ½É­™±½ÜÑ¡•É•™½É”è((´ÉÕ¹Ì½¹±ä½¸İ½É­™±½İ}‘¥ÍÁ…Ñ¡€½ÈÁÕÍ¡•ÌÑ¼¥¹™¥¹¥Ñ”µ½‘•à¼¨©€ì(´ÕÍ•Ì„¥Ñ!Õˆµ¡½ÍÑ•ÉÕ¹¹•Èì(´É…¹ÑÌ%Q!U	}Q=-9€½¹±ä½¹Ñ•¹ÑÌèÉ•…‘€ì(´‘½•Ì¹½ĞÕÍ”ÁÕ±±}É•ÅÕ•ÍÑ}Ñ…É•Ñ€ì(´‘½•Ì¹½Ğ¥¹Ñ•ÉÁ½±…Ñ”¥ÍÍÕ”Ñ¥Ñ±•Ì°AH‰½‘¥•Ì°½È½Ñ¡•ÈÕ¹ÑÉÕÍÑ•Ñ•áĞ¥¹Ñ¼Í¡•±°½µµ…¹‘Ìì(´ÕÁ±½…‘Ì•á•ÕÑ¥½¸…ÉÑ¥™…ÑÌ•Ù•¸İ¡•¸Ñ¡”µ¥ÍÍ¥½¸™…¥±Ì¸()I•…mMUI%Qd¹µ‘€¡MUI%Qd¹µ¤…¹Ñ¡”Í­¥±°Í•ÕÉ¥ÑäÉ•™•É•¹”‰•™½É”…‘‘¥¹œÉ•Á½Í¥Ñ½ÉäÍ•É•ÑÌ½È•áÁ…¹‘¥¹œÁ•Éµ¥ÍÍ¥½¹Ì¸((ŒŒ•¹ĞM­¥±°()m€¹…•¹ÑÌ½Í­¥±±Ì½¥¹™¥¹¥Ñ”µ½‘•à½M-%10¹µ‘t ¹…•¹ÑÌ½Í­¥±±Ì½¥¹™¥¹¥Ñ”µ½‘•à½M-%10¹µ¤™½±±½İÌÑ¡”Á½ÉÑ…‰±”•¹ĞM­¥±±Ì½¹Ù•¹Ñ¥½¸èe50µ•Ñ…‘…Ñ„Á±ÕÌ½¹¥Í”½Á•É…Ñ¥½¹…°¥¹ÍÑÉÕÑ¥½¹Ì¸9QL¹µ‘€¥ÌÑ¡”±¥¡Ñİ•¥¡ĞÉ•Á½Í¥Ñ½Éä•¹ÑÉäÁ½¥¹Ğ°…¹‘•Ñ…¥±•µ…Ñ•É¥…°ÍÑ…åÌ‰•Í¥‘”Ñ¡”Í­¥±°¥¸¥ÑÌÉ•™•É•¹•Ì½€‘¥É•Ñ½Éä¸()Q¡”Í­¥±°¡…Ì½¹”¹½¸µ¹•½Ñ¥…‰±”ÉÕ±”è((ø€¨©¡…Ğ½İ¹ÌÉ•…Í½¹¥¹œ¸Ñ¥½¹Ì½İ¹Ì•á•ÕÑ¥½¸¸¼¹½ĞÍ¥±•¹Ñ±ä¥¹Í•ÉĞ…¹½Ñ¡•È½‘¥¹œ…•¹Ğ‰•Ñİ••¸Ñ¡•´¸¨¨((ŒŒ•Í¥¸ÁÉ¥¹¥Á±•Ì((Ä¸€¨©=¹”‰É…¥¸¸¨¨Q¡”…Ñ¥Ù”¡…ĞÍ•ÍÍ¥½¸É•µ…¥¹ÌÑ¡”Í½±”É•…Í½¹¥¹œ…•¹Ğ¸(È¸€¨©¥Ğ¥Ìµ•µ½Éä¸¨¨¹åÑ¡¥¹œ¥µÁ½ÉÑ…¹Ğ•¹½Õ Ñ¼ÍÕÉÙ¥Ù”„ÉÕ¸Í¡½Õ±‰”½µµ¥ÑÑ•½ÈÍÑ½É•…Ì…¸…ÉÑ¥™…Ğ¸(Ì¸€¨©Ñ¥½¹Ì¥Ì‘¥ÍÁ½Í…‰±”½µÁÕÑ”¸¨¨9•Ù•È‘•Á•¹½¸ÉÕ¹¹•Èµ±½…°ÍÑ…Ñ”ÍÕÉÙ¥Ù¥¹œÑ¡”©½ˆ¸(Ğ¸€¨©Y•É¥™¥…Ñ¥½¸½Ù•È½¹™¥‘•¹”¸¨¨½µµ¥Ğ¥Ì¹½ĞÁÉ½½˜¸É•±•Ù…¹ĞÍÕ•ÍÍ™Õ°µ¥ÍÍ¥½¸¥Ì•Ù¥‘•¹”¸(Ô¸€¨©Mµ…±°µ¥ÍÍ¥½¹Ì¸¨¨… ÉÕ¸Í¡½Õ±…¹Íİ•È„½¹É•Ñ”•¹¥¹••É¥¹œÅÕ•ÍÑ¥½¸¸(Ø¸€¨©1•…ÍĞÁÉ¥Ù¥±•”¸¨¨Q¡”ÉÕ¹¹•ÈÍ¡½Õ±¹••Ù•Éä±¥ÑÑ±”…ÕÑ¡½É¥Ñä‰•…ÕÍ”¥Ğ‘½•Ì¹½Ğ½İ¸É•Á½Í¥Ñ½Éä‘•¥Í¥½¹Ì¸(Ü¸€¨©I•…‘…‰±”¡¥ÍÑ½Éä¸¨¨½µµ¥ÑÌÍ¡½Õ±‘•ÍÉ¥‰”µ•…¹¥¹™Õ°¡•­Á½¥¹ÑÌ°¹½Ğ¡¥‘”Ñ¡”±½½À¸((ŒŒI•Á½Í¥Ñ½Éä±…å½ÕĞ()Ñ•áĞ(¸+ŠRsŠRŠR I5¹µ+ŠRsŠRŠR 9QL¹µ+ŠRsŠRŠR ±±µÌ¹ÑáĞ+ŠRsŠRŠR 1%9M+ŠRsŠRŠR %M1%5H¹µ+ŠRsŠRŠR MUI%Qd¹µ+ŠRsŠRŠR =9QI%	UQ%9¹µ+ŠRsŠRŠR 1U9 ¹µ+ŠRsŠRŠR ¥¹ÍÑ…±°¹Í +ŠRsŠRŠR €¹…•¹ÑÌ¼+ŠR€€ƒŠRSŠRŠR Í­¥±±Ì¼+ŠR€€€€€€ƒŠRSŠRŠR ¥¹™¥¹¥Ñ”µ½‘•à¼+ŠR€€€€€€€€€€ƒŠRsŠRŠR M-%10¹µ+ŠR€€€€€€€€€€ƒŠRSŠRŠR É•™•É•¹•Ì¼+ŠR€€€€€€€€€€€€€€ƒŠRsŠRŠR Q%=9M}1==@¹µ+ŠR€€€€€€€€€€€€€€ƒŠRsŠRŠR I!%QQUI¹µ+ŠR€€€€€€€€€€€€€€ƒŠRSŠRŠR MUI%Qd¹µ+ŠRsŠRŠR €¹¥Ñ¡Õˆ¼+ŠR€€ƒŠRSŠRŠR İ½É­™±½İÌ¼+ŠR€€€€€€ƒŠRSŠRŠR ¥¹™¥¹¥Ñ”µ½‘•à¹åµ°+ŠRsŠRŠR €¹¥¹™¥¹¥Ñ”µ½‘•à¼+ŠR€€ƒŠRsŠRŠR µ¥ÍÍ¥½¸¹Í +ŠR€€ƒŠRSŠRŠR ÉÕ¹¹•È¹Í +ŠRsŠRŠR •á…µÁ±•Ì¼+ŠR€€ƒŠRsŠRŠR •¹•É¥Œ¹µ¥ÍÍ¥½¸¹Í +ŠR€€ƒŠRsŠRŠR ¹½‘”¹µ¥ÍÍ¥½¸¹Í +ŠR€€ƒŠRSŠRŠR ÁåÑ¡½¸¹µ¥ÍÍ¥½¸¹Í +ŠRSŠRŠR ÍÉ¥ÁÑÌ¼(€€€ƒŠRSŠRŠR Í•±˜µÑ•ÍĞ¹Í )€((ŒŒD((ŒŒŒ%ÌÑ¡”‘•Ù•±½Áµ•¹ĞÅÕ½Ñ„±¥Ñ•É…±±ä¥¹™¥¹¥Ñ”ü()9¼¸¡…ÑAPÁ±…¹Ì…¹¥Ñ!ÕˆÑ¥½¹Ì‰½Ñ ¡…Ù”Ñ¡•¥È½İ¸±¥µ¥ÑÌ…¹Á½±¥¥•Ì¸Q¡”¹…µ”‘•ÍÉ¥‰•ÌÑ¡”İ½É­™±½Ü¥‘•„èµ½Ù”•á•ÕÑ¥½¸¥¹Ñ¼¥Ñ!ÕˆÑ¥½¹ÌÍ¼„¡…ĞÍ•ÍÍ¥½¸…¸­••À‘½¥¹œÙ•É¥™¥•É•Á½Í¥Ñ½Éäİ½É¬İ¥Ñ¡½ÕĞµ…­¥¹œ½‘•àÑ¡”•á•ÕÑ¥½¸±…å•È¸((ŒŒŒ½•ÌÑ¡¥ÌÉ•ÅÕ¥É”AP´Ô¸ØM½°ü()9¼¸Q¡”…É¡¥Ñ•ÑÕÉ”¥Ìµ½‘•°µ…¹½ÍÑ¥Œ¸¹äÍÕ™™¥¥•¹Ñ±ä…Á…‰±”¡…Ğ½…•¹Ğ¡½ÍĞÑ¡…Ğ…¸É•……¹İÉ¥Ñ”Ñ¡”É•Á½Í¥Ñ½Éä…¹¥¹ÍÁ•ĞÑ¥½¹ÌÉ•ÍÕ±ÑÌ…¸ÕÍ”Ñ¡”±½½À¸((ŒŒŒ½•Ì¥Ñ!ÕˆÑ¥½¹ÌÉ•µ•µ‰•ÈÁÉ•Ù¥½ÕÌÉÕ¹Ìü()9¼¸¥Ñ!Õˆµ¡½ÍÑ•ÉÕ¹¹•ÉÌ…É”‘¥ÍÁ½Í…‰±”¸A•ÉÍ¥ÍĞÍ½ÕÉ”½ÍÑ…Ñ”¥¸¥Ğ…¹Á•ÉÍ¥ÍĞÉÕ¸½ÕÑÁÕÑÌ…Ì…ÉÑ¥™…ÑÌİ¡•¸¹••‘•¸((ŒŒŒ]¡ä„‘•‘¥…Ñ•‰É…¹ ÁÉ•™¥àü()%Ğ¥Ù•ÌÑ¡”•á•ÕÑ¥½¸‰½Õ¹‘…Éä„Ù¥Í¥‰±”°…Õ‘¥Ñ…‰±”ÑÉ¥•È¸=É‘¥¹…ÉäÁÕÍ¡•Ì•±Í•İ¡•É”‘¼¹½ĞÍÑ…ÉĞÑ¡”%¹™¥¹¥Ñ”½‘•àÉÕ¹¹•È¸((ŒŒŒ…¸$ÕÍ”„Í•±˜µ¡½ÍÑ•ÉÕ¹¹•Èü()Q•¡¹¥…±±äå•Ì°‰ÕĞ¥Ğ¡…¹•ÌÑ¡”Ñ¡É•…Ğµ½‘•°ÍÕ‰ÍÑ…¹Ñ¥…±±ä¸Q¡¥ÌÑ•µÁ±…Ñ”¥¹Ñ•¹Ñ¥½¹…±±ä‘•™…Õ±ÑÌÑ¼¥Ñ!Õˆµ¡½ÍÑ•Õ‰Õ¹ÑÔµ±…Ñ•ÍÑ€¸((ŒŒQÉ…‘•µ…É¬€˜…™™¥±¥…Ñ¥½¸()%¹™¥¹¥Ñ”½‘•à¥Ì…¸¥¹‘•Á•¹‘•¹Ğ½Á•¸µÍ½ÕÉ”ÁÉ½©•Ğ…¹¥Ì¹½Ğ…™™¥±¥…Ñ•İ¥Ñ °•¹‘½ÉÍ•‰ä°ÍÁ½¹Í½É•‰ä°½ÈÁÉ½‘Õ•‰ä=Á•¹$¸=Á•¹$°¡…ÑAP°½‘•à°…¹É•±…Ñ•¹…µ•Ì…¹µ…É­Ì‰•±½¹œÑ¼Ñ¡•¥ÈÉ•ÍÁ•Ñ¥Ù”½İ¹•ÉÌ¸M•”m%M1%5H¹µ‘t¡%M1%5H¹µ¤™½ÈÑ¡”™Õ±°¹½Ñ¥”¸()Q¡”¹…µ”€¨©%¹™¥¹¥Ñ”½‘•à¨¨‘½•Ì¹½Ğµ•…¸Ñ¡¥ÌÁÉ½©•ĞÉ…¹ÑÌÕ¹±¥µ¥Ñ•=Á•¹$½‘•àÕÍ…”°¡…¹•Ì=Á•¹$ÅÕ½Ñ…Ì°½È‰åÁ…ÍÍ•ÌÁÉ½‘ÕĞÉ•ÍÑÉ¥Ñ¥½¹Ì¸((ŒŒ1¥•¹Í”()5%P¸M•”m1%9Mt¡1%9M¤¸((´´´((¨©¡…Ğ¥ÌÑ¡”…•¹Ğ¸¥Ñ!Õˆ¥ÌÑ¡”µ•µ½Éä¸¥Ñ!ÕˆÑ¥½¹Ì¥ÌÑ¡”½µÁÕÑ•È¸¨¨(