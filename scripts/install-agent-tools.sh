#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
. "${ROOT_DIR}/scripts/lib/common.sh"

usage() {
  cat <<'USAGE'
Usage: install-agent-tools.sh [--dry-run]

Prepares Agent tooling. Phase 1 intentionally does not install optional third-party Agent tools by default.
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

log "agent tools installer is reserved for explicit Phase 2 tool migrations"
is_dry_run && log "dry-run complete"
