#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "${SCRIPT_DIR}/common.sh"

apt_update() {
  need_cmd apt-get
  sudo_cmd apt-get update
}

apt_install_if_missing() {
  local pkg
  need_cmd dpkg
  need_cmd apt-get
  for pkg in "$@"; do
    if dpkg -s "${pkg}" >/dev/null 2>&1; then
      log "apt package already installed: ${pkg}"
      continue
    fi
    sudo_cmd apt-get install -y "${pkg}"
  done
}
