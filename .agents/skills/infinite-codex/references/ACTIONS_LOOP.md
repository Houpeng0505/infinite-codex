# Actions Loop

## Recommended task branch

Use one branch per task:

```text
infinite-codex/<task-slug>
```

Examples:

```text
infinite-codex/fix-auth-timeout
infinite-codex/add-rag-reranker
infinite-codex/reproduce-issue-42
```

## Recommended iteration

### Iteration 1 — establish reality

Before large edits, run or preserve the relevant baseline when practical. The first mission can reproduce the bug or verify existing tests.

### Iteration 2 — smallest coherent fix

Commit the focused implementation plus a mission that exercises the changed behavior.

### Iteration 3+ — evidence-driven repair

Use the Action output to choose the next change. Avoid broad “maybe this helps” modifications when a narrower diagnostic can resolve uncertainty.

## Mission design

Good missions answer one concrete question.

Good:

```bash
python -m pytest tests/test_auth.py -q
```

Then, after the focused test passes:

```bash
python -m pytest -q
```

Less useful:

```bash
make everything || true
```

The second form hides failure and makes diagnosis harder.

## Dependency installation

Prefer repository-native lockfiles and commands:

- `npm ci` over an unconstrained `npm install` when `package-lock.json` exists;
- locked Python tooling when the repo provides it;
- `cargo test --locked` when appropriate;
- `go test ./...` for ordinary Go modules.

Do not add new dependency managers solely for Infinite Codex unless the project genuinely needs them.

## Manual reruns

`workflow_dispatch` can rerun the committed mission without creating another commit. This is useful for suspected transient infrastructure failures.

Do not use repeated reruns to hide a deterministic failure.

## Finish state

Before declaring success:

1. The requested behavior exists in committed source.
2. The relevant Action run is green.
3. The mission did not suppress meaningful errors.
4. Any intentionally unverified area is stated.
5. The branch remains understandable to a human reviewer.
