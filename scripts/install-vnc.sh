#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
. "${ROOT_DIR}/scripts/lib/common.sh"

usage() {
  cat <<'USAGE'
Usage: install-vnc.sh [--dry-run]

Prepares VNC dependencies. Phase 1 documents the future boundary and does not replace gomtm's current VNC installer yet.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      GOMTM_INSTALL_DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage_error "unknown argument: $1"
      ;;
  esac
done

log "vnc installer migration is reserved for Phase 2"
is_dry_run && log "dry-run complete"
