#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
. "${ROOT_DIR}/scripts/lib/common.sh"

usage() {
  cat <<'USAGE'
Usage: remote-bootstrap.sh [--dry-run] user@host

Prints or runs the remote bootstrap command. Phase 1 only supports dry-run output.
USAGE
}

target=""

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
      if [ -n "${target}" ]; then
        usage_error "only one target is supported"
      fi
      target="$1"
      shift
      ;;
  esac
done

[ -n "${target}" ] || usage_error "missing target"

case "${target}" in
  *@*) ;;
  *) usage_error "target must look like user@host" ;;
esac

if ! is_dry_run; then
  die "remote bootstrap execution is not enabled in Phase 1; rerun with --dry-run"
fi

log "would bootstrap ${target} with gomtm-install install dev"
