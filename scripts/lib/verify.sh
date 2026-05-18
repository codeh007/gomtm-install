#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "${SCRIPT_DIR}/common.sh"

verify_command() {
  local name="$1"
  if have_cmd "${name}"; then
    log "verified command: ${name}"
    return 0
  fi
  die "missing command after install: ${name}"
}

verify_any_command() {
  local name
  for name in "$@"; do
    if have_cmd "${name}"; then
      log "verified command: ${name}"
      return 0
    fi
  done
  die "none of the expected commands are available: $*"
}
