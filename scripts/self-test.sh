#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

required=(
  README.md
  AGENTS.md
  llms.txt
  LICENSE
  DISCLAIMER.md
  SECURITY.md
  CONTRIBUTING.md
  LAUNCH.md
  .agents/skills/infinite-codex/SKILL.md
  .agents/skills/infinite-codex/references/ARCHITECTURE.md
  .agents/skills/infinite-codex/references/ACTIONS_LOOP.md
  .agents/skills/infinite-codex/references/SECURITY.md
  .github/workflows/infinite-codex.yml
  .infinite-codex/runner.sh
  .infinite-codex/mission.sh
)

for file in "${required[@]}"; do
  [[ -f "$file" ]] || { echo "missing required file: $file" >&2; exit 1; }
done

bash -n .infinite-codex/runner.sh
bash -n .infinite-codex/mission.sh
bash -n install.sh
bash -n examples/python.mission.sh
bash -n examples/node.mission.sh
bash -n examples/generic.mission.sh

grep -q '^name: infinite-codex$' .agents/skills/infinite-codex/SKILL.md
grep -q '^description:' .agents/skills/infinite-codex/SKILL.md
grep -q 'contents: read' .github/workflows/infinite-codex.yml
grep -q "'infinite-codex/\*\*'" .github/workflows/infinite-codex.yml
grep -q 'actions/checkout@v7' .github/workflows/infinite-codex.yml
grep -q 'actions/upload-artifact@v7' .github/workflows/infinite-codex.yml
grep -q 'include-hidden-files: true' .github/workflows/infinite-codex.yml
grep -q '.agents/skills/infinite-codex/SKILL.md' AGENTS.md

if grep -Eqi 'uses:.*(codex|claude|aider|openhands)|OPENAI_API_KEY|ANTHROPIC_API_KEY' .github/workflows/infinite-codex.yml; then
  echo 'workflow unexpectedly references a model/second coding agent' >&2
  exit 1
fi

echo 'Infinite Codex self-test passed.'
