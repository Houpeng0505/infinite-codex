# Contributing

Infinite Codex is intentionally small. Contributions should preserve the core architecture:

> Chat is the agent. GitHub is the memory. GitHub Actions is the computer.

## Good contributions

- make the Chat → Git → Actions → evidence loop easier to use;
- improve portability of the `SKILL.md`;
- improve security without adding unnecessary infrastructure;
- add focused mission examples;
- improve documentation and onboarding;
- make execution results easier for an agent or human to inspect.

## Usually out of scope

- embedding a second autonomous coding agent in the workflow;
- building an orchestration platform around multiple LLM workers;
- adding repository write permissions to the runner by default;
- replacing Git with a custom persistent state service;
- hiding execution behind a hosted proprietary backend.

## Pull requests

Keep PRs narrow. Explain the problem, the change, and how you verified it.
