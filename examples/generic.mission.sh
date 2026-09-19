#!/usr/bin/env bash
set -euo pipefail

# Replace these with the repository's real reproducible commands.
./scripts/install-deps.sh
./scripts/test.sh
./scripts/build.sh
