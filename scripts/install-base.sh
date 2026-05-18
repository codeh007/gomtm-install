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
Usage: install-base.sh [--dry-run]

Installs the minimal base packages expected on a gomtm-compatible Linux host.
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

base_packages=(
  sudo
  curl
  wget
  ca-certificates
  tar
  git
  jq
  unzip
  rsync
  openssh-client
)

apt_update
apt_install_if_missing "${base_packages[@]}"

if ! is_dry_run; then
  verify_command curl
  verify_command git
  verify_command jq
fi

log "base install complete"
