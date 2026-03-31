#!/usr/bin/env bash
set -euo pipefail
FLAKE_DIR="$(cd "$(dirname "$0")" && pwd)"
HOST="$(hostname -s)"
sudo darwin-rebuild switch --flake "${FLAKE_DIR}#${HOST}"
