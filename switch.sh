#!/usr/bin/env bash
# Dispatch to the per-machine switch script based on hostname.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
HOST="$(hostname -s)"

case "$HOST" in
  mac4|mac10) MACHINE=macOS ;;
  bee)        MACHINE=bee ;;
  logicLHR)   MACHINE=logicLHR ;;
  caracas)    MACHINE=caracas ;;
  *) echo "switch.sh: no machine config for host '$HOST'" >&2; exit 1 ;;
esac

exec "$DIR/machines/$MACHINE/switch.sh" "$@"
