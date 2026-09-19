#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

OUT_DIR="$ROOT/.infinite-codex/out"
MISSION="$ROOT/.infinite-codex/mission.sh"
mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR/run.log" "$OUT_DIR/result.json" "$OUT_DIR/summary.md" "$OUT_DIR/exit-code.txt"

if [[ ! -f "$MISSION" ]]; then
  printf '127\n' > "$OUT_DIR/exit-code.txt"
  printf '# Infinite Codex\n\nMission file not found: `.infinite-codex/mission.sh`\n' > "$OUT_DIR/summary.md"
  exit 0
fi

started_at="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
repo="${GITHUB_REPOSITORY:-$(basename "$ROOT")}" 
ref="${GITHUB_REF_NAME:-$(git branch --show-current 2>/dev/null || echo unknown)}"
sha="${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || echo unknown)}"
run_id="${GITHUB_RUN_ID:-local}"
run_attempt="${GITHUB_RUN_ATTEMPT:-1}"

{
  echo '=== Infinite Codex mission ==='
  echo "repository: $repo"
  echo "ref:        $ref"
  echo "sha:        $sha"
  echo "started:    $started_at"
  echo
} | tee "$OUT_DIR/run.log"

set +e
bash "$MISSION" 2>&1 | tee -a "$OUT_DIR/run.log"
mission_code=${PIPESTATUS[0]}
set -e

finished_at="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
printf '%s\n' "$mission_code" > "$OUT_DIR/exit-code.txt"

STATUS="passed"
if [[ "$mission_code" -ne 0 ]]; then
  STATUS="failed"
fi

IC_STATUS="$STATUS" \
IC_EXIT_CODE="$mission_code" \
IC_REPOSITORY="$repo" \
IC_REF="$ref" \
IC_SHA="$sha" \
IC_RUN_ID="$run_id" \
IC_RUN_ATTEMPT="$run_attempt" \
IC_STARTED_AT="$started_at" \
IC_FINISHED_AT="$finished_at" \
python3 - "$OUT_DIR/result.json" <<'PY'
import json
import os
import sys

path = sys.argv[1]
data = {
    "project": "Infinite Codex",
    "status": os.environ["IC_STATUS"],
    "exit_code": int(os.environ["IC_EXIT_CODE"]),
    "repository": os.environ["IC_REPOSITORY"],
    "ref": os.environ["IC_REF"],
    "sha": os.environ["IC_SHA"],
    "run_id": os.environ["IC_RUN_ID"],
    "run_attempt": os.environ["IC_RUN_ATTEMPT"],
    "started_at": os.environ["IC_STARTED_AT"],
    "finished_at": os.environ["IC_FINISHED_AT"],
}
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY

cat > "$OUT_DIR/summary.md" <<EOF2
# Infinite Codex

| Field | Value |
| --- | --- |
| Status | **$STATUS** |
| Exit code | \`$mission_code\` |
| Repository | \`$repo\` |
| Ref | \`$ref\` |
| Commit | \`$sha\` |
| Started | \`$started_at\` |
| Finished | \`$finished_at\` |

The complete execution output is stored in \`run.log\` in the uploaded Infinite Codex artifact.
EOF2

{
  echo
  echo '=== Infinite Codex result ==='
  echo "status:     $STATUS"
  echo "exit code:  $mission_code"
  echo "finished:   $finished_at"
} | tee -a "$OUT_DIR/run.log"

# Always return success here. The workflow's final step reads exit-code.txt and
# propagates the mission result after logs/artifacts have been published.
exit 0
