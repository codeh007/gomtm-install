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

Installs development-host prerequisites and delegates runtime languages and Docker to migrated scripts.
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
  bc
  cmake
  pkg-config
  libssl-dev
  libpq-dev
  libxml2
  libxmlsec1-dev
  python3-dev
  ca-certificates
  patch
  dbus-x11
  x11-utils
  x11-xserver-utils
  xdg-utils
  at-spi2-core
  ncdu
  postgresql-client
  libpcap-dev
  ripgrep
)

apt_install_if_missing "${dev_packages[@]}"

runtime_args=()
docker_args=()
if is_dry_run; then
  runtime_args+=(--dry-run)
  docker_args+=(--dry-run)
fi

"${ROOT_DIR}/scripts/install-runtime-languages.sh" "${runtime_args[@]}"
"${ROOT_DIR}/scripts/install-docker.sh" "${docker_args[@]}"

if ! is_dry_run; then
  verify_command make
  verify_command rg
  verify_command go
  verify_command node
  verify_command bun
  verify_command uv
  verify_command docker
fi

log "dev install complete"
