# Security Reference

Infinite Codex intentionally executes repository-controlled shell code on a GitHub Actions runner. That is powerful and should be treated like CI code.

## Default threat boundary

The shipped workflow minimizes privilege:

```yaml
permissions:
  contents: read
```

It runs only on:

- pushes to `infinite-codex/**`;
- explicit `workflow_dispatch` requests.

It does not use `pull_request_target`.

## Untrusted content

Do not copy untrusted text directly into shell syntax. Issue titles, PR bodies, branch names, commit messages, and user-generated files may contain shell metacharacters.

Prefer committed scripts and pass data through files/environment variables with appropriate quoting.

## Secrets

Assume anything printed by the mission may become visible in:

- Actions logs;
- artifacts;
- debugging output.

Do not echo secrets. Do not commit them. Use repository/environment secrets only when the verification genuinely requires them.

If a mission needs a production credential, reconsider whether the test can use a scoped test credential or a mock instead.

## Public repositories

A public repository increases the importance of execution controls. Review who has write access and who can trigger Actions. Keep the dedicated branch boundary and least-privilege token unless there is a clear reason to change them.

## Self-hosted runners

A self-hosted runner can expose long-lived infrastructure, local credentials, network access, or other machines. Infinite Codex defaults to GitHub-hosted runners specifically to keep the compute disposable.

If you switch to self-hosted, perform a separate threat-model review.

## Dependency execution

Installing dependencies executes third-party code. Pin or lock dependencies when the project supports it. Be especially careful when testing untrusted dependency changes.

## Permission changes

Treat any change from `contents: read` to a write permission as security-sensitive. The default architecture does not need the runner to commit, push, open PRs, or modify repository settings.
