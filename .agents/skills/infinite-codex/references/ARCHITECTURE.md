# Architecture

Infinite Codex separates reasoning, persistence, and execution.

## 1. Chat owns reasoning

The active Chat session owns reasoning and repository edits. It:

- interprets user intent;
- reads the repository;
- plans changes;
- edits source and tests;
- chooses verification commands;
- diagnoses runner output;
- decides whether another iteration is required.

This keeps the user's intent and the engineering loop in one continuous context.

## 2. GitHub owns durable state

GitHub is the persistent workspace:

- source code;
- tests;
- configuration;
- `.infinite-codex/mission.sh`;
- branches;
- commits and review history.

A GitHub-hosted runner is ephemeral, so runner-local filesystem state is never treated as durable.

## 3. GitHub Actions owns execution

Actions is a remote computer. The default runner does exactly one important thing:

```bash
bash .infinite-codex/mission.sh
```

The mission is committed code, not a natural-language prompt. It should make the desired engineering claim falsifiable: “these tests pass”, “this build succeeds”, “this reproduction no longer fails”, and so on.

## Why the trigger is a branch prefix

The default workflow runs on pushes to:

```text
infinite-codex/**
```

That creates an explicit execution boundary. A normal branch push does not invoke Infinite Codex. Chat can create a task branch, commit a checkpoint, and the push itself becomes the run request.

`workflow_dispatch` exists as a manual rerun path.

## Why the runner is read-only

The runner gets:

```yaml
permissions:
  contents: read
```

The runner does not need repository write access because Chat owns edits and commits. This sharply narrows the blast radius of a faulty mission.

## Result protocol

Every run attempts to leave these files in `.infinite-codex/out/`:

- `run.log` — combined stdout/stderr;
- `exit-code.txt` — raw mission exit code;
- `result.json` — machine-readable metadata;
- `summary.md` — human-readable summary.

The workflow uploads that directory even on failure, then propagates the mission exit code so the GitHub check accurately reflects the result.

## What “Infinite” means

It is a project name, not a quota guarantee. Infinite Codex does not alter OpenAI or GitHub limits. The design moves executable verification out of a specialized coding-agent runtime and into GitHub Actions, allowing a Chat session to drive repeated repository iterations with normal Git state as the handoff layer.
