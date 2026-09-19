#!/usr/bin/env bash
set -euo pipefail

# This file is the contract between Chat and the disposable GitHub Actions VM.
#
# Chat should rewrite this mission for the current engineering task, commit it
# together with the source change, then use the Action result as evidence for
# the next iteration.
#
# Keep the mission focused: install only what is required and run the smallest
# useful checks that prove the change works.

if [[ -x scripts/self-test.sh ]]; then
  ./scripts/self-test.sh
else
  echo 'Infinite Codex is installed.'
  echo 'Replace .infinite-codex/mission.sh with the verification commands for this repository.'
fi
