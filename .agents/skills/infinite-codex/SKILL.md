---
name: infinite-codex
description: Use Chat as the sole coding agent while GitHub stores persistent repository state and GitHub Actions provides disposable execution for builds, tests, scripts, and verification. Use for repository engineering tasks that need real execution and iterative verification without delegating coding to another LLM or coding agent inside CI.
---

# Infinite Codex

Use this skill to turn the current Chat session into a repository coding agent backed by GitHub Actions compute.

The architecture is deliberately simple:

- **Chat = reasoning agent**
- **GitHub repository = persistent workspace and history**
- **GitHub Actions = disposable computer**

Do not introduce another AI agent unless the user explicitly asks for one.

## Preconditions

Before starting repository work, verify that the current environment can do the operations the task requires:

1. Read the target GitHub repository.
2. Create or update a branch and commit file changes.
3. Inspect GitHub Actions run status and logs, or otherwise retrieve the verification result.

If one of these capabilities is unavailable, do not pretend the loop is complete. Continue with the parts that are possible and state the concrete missing capability.

## Core loop

For implementation tasks:

1. **Understand**
   - Restate the engineering goal internally.
   - Identify acceptance criteria and the smallest verification that can prove them.

2. **Inspect**
   - Read the relevant source, tests, configuration, and existing CI before editing.
   - Prefer the repository's existing tools and conventions.

3. **Branch**
   - Work on `infinite-codex/<short-task-slug>` unless the user specifies another branch.
   - Do not mix unrelated tasks on one branch.

4. **Plan the mission**
   - Edit `.infinite-codex/mission.sh` so it runs the smallest useful set of commands that can verify the current change.
   - A mission may install dependencies, run tests, build, lint, type-check, benchmark, or execute a focused reproduction.
   - Keep the mission deterministic and readable.

5. **Edit**
   - Make the smallest coherent code change.
   - Avoid speculative refactors unrelated to the task.

6. **Persist**
   - Commit source changes and the mission together as a meaningful checkpoint.
   - Git is the durable state between runner invocations.

7. **Execute**
   - A push to `infinite-codex/**` should trigger `.github/workflows/infinite-codex.yml` automatically.
   - Use `workflow_dispatch` only when a manual rerun is useful.

8. **Observe**
   - Inspect the run conclusion and relevant log output.
   - If needed, inspect the uploaded Infinite Codex artifact containing `run.log`, `summary.md`, `result.json`, and `exit-code.txt`.

9. **Diagnose**
   - Distinguish implementation failure from environment/setup failure.
   - Base the next change on execution evidence, not confidence alone.

10. **Iterate**
   - Modify code and/or the mission, commit, and run again.
   - Continue until the acceptance criteria are verified or a concrete external blocker is identified.

11. **Finish**
   - Leave the branch in a coherent state.
   - Summarize what changed, what verification passed, and any remaining limitation.

## Rules

### One agent

Chat owns reasoning, planning, debugging, and implementation decisions.

Never add Codex CLI, Claude Code, Gemini CLI, OpenHands, Aider, or another LLM-driven coding agent to the GitHub Actions job merely to perform the task. That defeats this architecture.

### Actions is a computer

Treat GitHub Actions as a disposable Linux machine:

- filesystem state disappears after the run;
- each job should be reproducible from repository state plus declared dependencies;
- persist durable state in Git;
- persist run-only outputs as artifacts when useful.

### Verification is explicit

Do not treat a commit, successful syntax edit, or visual inspection as proof that code works when executable verification is available.

Prefer focused checks first, then broader checks when the task warrants them.

### Keep permissions minimal

The default workflow needs only `contents: read` because Chat, not the runner, owns repository writes.

Do not increase `GITHUB_TOKEN` permissions unless the task requires it and the user understands why.

### Do not leak secrets

Never write secrets, API keys, tokens, credentials, or sensitive user data into:

- `.infinite-codex/mission.sh`;
- source committed only for a run;
- log statements;
- artifacts;
- workflow inputs that may be retained in run metadata.

Use repository/environment secrets only when necessary and avoid printing them.

### Treat executable repository content as code

The mission is code. Review it before execution.

Do not execute untrusted PR-controlled scripts with privileged credentials. Do not switch this template to `pull_request_target` as a convenience shortcut.

## Mission patterns

Python:

```bash
#!/usr/bin/env bash
set -euo pipefail
python -m pip install -e '.[dev]'
python -m pytest -q
```

Node:

```bash
#!/usr/bin/env bash
set -euo pipefail
npm ci
npm test
npm run build --if-present
```

Focused reproduction:

```bash
#!/usr/bin/env bash
set -euo pipefail
./scripts/setup-test-env.sh
python scripts/reproduce_issue_123.py
```

## Failure handling

When a run fails:

1. Read the first causally useful error, not just the final non-zero exit line.
2. Decide whether the failure is caused by the implementation, dependencies, environment, or the mission itself.
3. Change only what the evidence supports.
4. Preserve useful diagnostic output in the next mission when the problem is uncertain.
5. Re-run.

Do not repeatedly make broad edits without obtaining new evidence.

## Completion standard

A task is complete when:

- the requested behavior is implemented;
- the relevant mission passes on the committed revision;
- the repository history is understandable;
- no known critical failure is being hidden by the mission;
- remaining limitations are stated explicitly.

## References

Read these only when needed:

- [`references/ARCHITECTURE.md`](references/ARCHITECTURE.md) — boundaries and design rationale.
- [`references/ACTIONS_LOOP.md`](references/ACTIONS_LOOP.md) — runner protocol and iteration details.
- [`references/SECURITY.md`](references/SECURITY.md) — threat model and safe workflow changes.
