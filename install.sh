#!/usr/bin/env bash
set -euo pipefail

SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 /path/to/target-repository" >&2
  exit 2
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Target directory does not exist: $TARGET" >&2
  exit 2
fi

TARGET="$(cd "$TARGET" && pwd)"

mkdir -p \
  "$TARGET/.github/workflows" \
  "$TARGET/.infinite-codex" \
  "$TARGET/.agents/skills/infinite-codex/references"

copy_file() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" ]]; then
    echo "Refusing to overwrite existing file: $dst" >&2
    exit 3
  fi
  cp "$src" "$dst"
}

copy_file "$SOURCE/.agents/skills/infinite-codex/SKILL.md" "$TARGET/.agents/skills/infinite-codex/SKILL.md"
copy_file "$SOURCE/.agents/skills/infinite-codex/references/ARCHITECTURE.md" "$TARGET/.agents/skills/infinite-codex/references/ARCHITECTURE.md"
copy_file "$SOURCE/.agents/skills/infinite-codex/references/ACTIONS_LOOP.md" "$TARGET/.agents/skills/infinite-codex/references/ACTIONS_LOOP.md"
copy_file "$SOURCE/.agents/skills/infinite-codex/references/SECURITY.md" "$TARGET/.agents/skills/infinite-codex/references/SECURITY.md"
copy_file "$SOURCE/.github/workflows/infinite-codex.yml" "$TARGET/.github/workflows/infinite-codex.yml"
copy_file "$SOURCE/.infinite-codex/runner.sh" "$TARGET/.infinite-codex/runner.sh"
copy_file "$SOURCE/.infinite-codex/mission.sh" "$TARGET/.infinite-codex/mission.sh"

chmod +x "$TARGET/.infinite-codex/runner.sh" "$TARGET/.infinite-codex/mission.sh"

# Local executions generate transient evidence here. Preserve an existing
# .gitignore and append the rule only when it is not already present.
touch "$TARGET/.gitignore"
if ! grep -Fxq '.infinite-codex/out/' "$TARGET/.gitignore"; then
  printf '\n.infinite-codex/out/\n' >> "$TARGET/.gitignore"
fi

if [[ ! -e "$TARGET/AGENTS.md" ]]; then
  copy_file "$SOURCE/AGENTS.md" "$TARGET/AGENTS.md"
  agents_note='Created AGENTS.md entry point.'
else
  agents_note='Existing AGENTS.md preserved. Merge the Infinite Codex entry-point instruction into it manually.'
fi

cat <<EOF2
Infinite Codex installed into:
  $TARGET

$agents_note

Next:
  1. Review and adapt .infinite-codex/mission.sh
  2. Commit the installed files
  3. Work on an infinite-codex/<task> branch
  4. Let Chat inspect the resulting GitHub Actions run and iterate
EOF2
