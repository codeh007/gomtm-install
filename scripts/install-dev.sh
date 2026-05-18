#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
. "${ROOT_DIR}/scripts/lib/common.sh"
# shellcheck source=lib/apt.sh
. "${ROOT_DIR}/scripts/lib/apt.sh"
# shellcheck source=lib/verify.sh
. "${ROOT_DIR}/scripts/lib/verify.sh"

usage() {
  cat <<'USAGE'
Usage: install-dev.sh [--dry-run]

Installs development-host prerequisites. Phase 1 keeps this conservative and installs only OS packages.
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

base_args=()
if is_dry_run; then
  base_args+=(--dry-run)
fi

"${ROOT_DIR}/scripts/install-base.sh" "${base_args[@]}"

dev_packages=(
  build-essential
  make
  pkg-config
  libssl-dev
  libpq-dev
  ripgrep
)

apt_install_if_missing "${dev_packages[@]}"

if ! is_dry_run; then
  verify_command make
  verify_command rg
fi

log "dev install complete"
