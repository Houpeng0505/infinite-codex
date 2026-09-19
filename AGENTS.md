# Infinite Codex entry point

When substantial repository development is performed from Chat, read `.agents/skills/infinite-codex/SKILL.md` before making substantial changes.

For this repository pattern:

- Chat owns reasoning, coding, and repository edits.
- GitHub is the durable source of repository state and history.
- GitHub Actions is the disposable execution computer used for real builds, tests, scripts, and verification.


For each engineering task, prefer a dedicated `infinite-codex/<task>` branch. Commit the source change together with a focused `.infinite-codex/mission.sh`; pushes to that branch trigger the execution loop. Diagnose the returned result before making the next change.

The repository's own engineering requirements remain authoritative. Infinite Codex supplies the execution loop; it does not replace the project's runtime, dependency manager, architecture, tests, or coding conventions.
