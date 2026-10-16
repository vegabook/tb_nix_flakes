#!/usr/bin/env bash
set -euo pipefail
FLAKE_DIR="$(cd "$(dirname "$0")" && pwd)"
# nix run bootstraps home-manager on first use; -b backs up clashing dotfiles (e.g. Ubuntu's ~/.bashrc)
nix run home-manager/master -- switch -b backup --flake "${FLAKE_DIR}#tbrowne"
