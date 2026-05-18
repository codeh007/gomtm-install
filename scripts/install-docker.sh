#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
. "${ROOT_DIR}/scripts/lib/common.sh"
# shellcheck source=lib/apt.sh
. "${ROOT_DIR}/scripts/lib/apt.sh"
# shellcheck source=lib/verify.sh
. "${ROOT_DIR}/scripts/lib/verify.sh"

DOCKER_COMPOSE_VERSION="v2.29.0"

usage() {
  cat <<'USAGE'
Usage: install-docker.sh [--dry-run]

Installs Docker and docker-compose for gomtm-compatible Linux hosts.
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

distro_id=""
if [ -r /etc/os-release ]; then
  distro_id="$(. /etc/os-release && printf '%s' "${ID:-}")"
fi

install_docker_engine() {
  if have_cmd docker; then
    log "docker already installed"
    return
  fi

  log "installing Docker"
  case "${distro_id}" in
    debian|ubuntu)
      apt_update
      apt_install_if_missing docker.io
      ;;
    *)
      apt_update
      apt_install_if_missing apt-transport-https ca-certificates curl gnupg lsb-release
      codename="$(lsb_release -cs 2>/dev/null || true)"
      if [ "${distro_id}" = "debian" ] && { [ "${codename}" = "trixie" ] || [ "${codename}" = "sid" ]; }; then
        codename="bookworm"
      fi
      run_shell "curl -fsSL \"https://download.docker.com/linux/${distro_id}/gpg\" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes"
      sudo_shell "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${distro_id} ${codename} stable\" > /etc/apt/sources.list.d/docker.list"
      apt_update
      apt_install_if_missing docker-ce docker-ce-cli containerd.io
      ;;
  esac
}

install_compose() {
  if have_cmd docker-compose; then
    log "docker-compose already installed"
    return
  fi

  arch_name="$(uname -m)"
  case "${arch_name}" in
    x86_64|amd64) compose_arch="x86_64" ;;
    aarch64|arm64) compose_arch="aarch64" ;;
    *) die "unsupported docker-compose architecture: ${arch_name}" ;;
  esac

  log "installing docker-compose ${DOCKER_COMPOSE_VERSION}"
  url="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${compose_arch}"
  tmp_file="/tmp/docker-compose-install"
  run_cmd curl -fsSL "${url}" -o "${tmp_file}"
  sudo_cmd install -m 0755 "${tmp_file}" /usr/local/bin/docker-compose
  run_cmd rm -f "${tmp_file}"
}

start_docker_if_possible() {
  if is_dry_run; then
    log "would start Docker service when available"
    return
  fi
  if docker info >/dev/null 2>&1; then
    return
  fi
  if have_cmd service; then
    sudo service docker start || true
  elif have_cmd systemctl; then
    sudo systemctl start docker || true
  fi
}

ensure_user_access() {
  target_user="${SUDO_USER:-${USER:-}}"
  if [ -z "${target_user}" ] || [ "${target_user}" = "root" ]; then
    return
  fi
  sudo_shell "getent group docker >/dev/null || groupadd docker"
  sudo_cmd usermod -aG docker "${target_user}"
  if [ -S /var/run/docker.sock ]; then
    sudo_cmd chmod 666 /var/run/docker.sock
  fi
}

install_docker_engine
install_compose
start_docker_if_possible
ensure_user_access

if ! is_dry_run; then
  verify_command docker
  verify_command docker-compose
fi

log "docker install complete"
