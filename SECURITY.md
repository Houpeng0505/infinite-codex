# Security Policy

## Supported version

The current `main` branch is the supported version of Infinite Codex.

## Reporting a vulnerability

Please report security issues privately to the repository maintainer rather than publishing a working exploit in a public issue.

Until a dedicated security contact is configured, use GitHub's private vulnerability reporting feature if it is enabled for the repository.

## Important security properties

Infinite Codex executes committed repository code on GitHub Actions. The default template therefore keeps the runner read-only with respect to repository contents and avoids privileged pull-request triggers.

Before adding secrets, write permissions, deployment credentials, self-hosted runners, or `pull_request_target`, read [`.agents/skills/infinite-codex/references/SECURITY.md`](.agents/skills/infinite-codex/references/SECURITY.md).
