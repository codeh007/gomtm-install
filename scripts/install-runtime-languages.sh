#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
. "${ROOT_DIR}/scripts/lib/common.sh"
# shellcheck source=lib/apt.sh
. "${ROOT_DIR}/scripts/lib/apt.sh"
# shellcheck source=lib/verify.sh
. "${ROOT_DIR}/scripts/lib/verify.sh"

GO_VERSION="1.26.2"
GO_TOOLCHAIN="go${GO_VERSION}+auto"
NODE_VERSION="22"
UV_VERSION="0.9.17"
PYTHON_VERSION="3.12"

usage() {
  cat <<'USAGE'
Usage: install-runtime-languages.sh [--dry-run]

Installs the low-coupling runtime language toolchain migrated from gomtm pkg/mtinstall:
Go 1.26.2, Node.js 22 through nvm, Bun, uv 0.9.17, and Python 3.12 through uv.
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

arch_name="$(uname -m)"
case "${arch_name}" in
  x86_64|amd64)
    go_arch="amd64"
    uv_arch="x86_64"
    ;;
  aarch64|arm64)
    go_arch="arm64"
    uv_arch="aarch64"
    ;;
  *)
    die "unsupported architecture: ${arch_name}"
    ;;
esac

install_go() {
  log "installing Go go${GO_VERSION}"
  if [ -x /usr/local/go/bin/go ] && /usr/local/go/bin/go version 2>/dev/null | grep -q "go${GO_VERSION}"; then
    log "Go go${GO_VERSION} already installed"
  else
    tarball="go${GO_VERSION}.linux-${go_arch}.tar.gz"
    url="https://go.dev/dl/${tarball}"
    tmp_file="/tmp/${tarball}"
    run_cmd curl -fsSL "${url}" -o "${tmp_file}"
    sudo_cmd rm -rf /usr/local/go
    sudo_cmd tar -C /usr/local -xzf "${tmp_file}"
    run_cmd rm -f "${tmp_file}"
  fi

  sudo_cmd ln -sf /usr/local/go/bin/go /usr/local/bin/go
  sudo_cmd ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
  sudo_cmd mkdir -p /go/bin /go/pkg/mod /go/src
  sudo_cmd chmod -R u+rwX,go+rX /go
  sudo_shell "cat > /etc/profile.d/go.sh <<'EOF'
# >>> gomtm go env >>>
export GOROOT=/usr/local/go
export GOPATH=/go
export GOMODCACHE=/go/pkg/mod
export GOTOOLCHAIN=${GO_TOOLCHAIN}
export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH
export GOMAXPROCS=8
# <<< gomtm go env <<<
EOF
chmod 644 /etc/profile.d/go.sh"

  if ! is_dry_run; then
    verify_command go
  fi
}

install_node_and_bun() {
  log "installing Node.js ${NODE_VERSION}, pnpm, and Bun"
  sudo_cmd apt-get remove -y nodejs npm libnode-dev
  sudo_cmd apt-get autoremove -y
  sudo_cmd mkdir -p /usr/local/nvm
  sudo_cmd chmod 777 /usr/local/nvm

  if [ ! -s /usr/local/nvm/nvm.sh ]; then
    run_shell "export NVM_DIR=/usr/local/nvm && curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash"
  fi
  sudo_shell "cat > /etc/profile.d/nvm.sh <<'EOF'
export NVM_DIR=/usr/local/nvm
[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"
[ -s \"\$NVM_DIR/bash_completion\" ] && . \"\$NVM_DIR/bash_completion\"
EOF
chmod 644 /etc/profile.d/nvm.sh"

  run_shell "export NVM_DIR=/usr/local/nvm && . /usr/local/nvm/nvm.sh && nvm install ${NODE_VERSION} && nvm alias default ${NODE_VERSION} && nvm use default"
  node_bin="$(run_shell 'export NVM_DIR=/usr/local/nvm && . /usr/local/nvm/nvm.sh && dirname "$(nvm which default)"' 2>/dev/null || true)"
  node_bin="${node_bin:-/usr/local/nvm/versions/node/v${NODE_VERSION}/bin}"
  if [ -d "${node_bin}" ]; then
    node_version_dir="$(dirname "${node_bin}")"
    sudo_cmd ln -sfn "${node_version_dir}" /usr/local/nvm/current
    for cmd in node npm npx corepack; do
      if [ -e "${node_bin}/${cmd}" ]; then
        sudo_cmd ln -sf "${node_bin}/${cmd}" "/usr/local/bin/${cmd}"
      fi
    done
  fi

  run_shell "npm install -g pnpm"
  run_shell "export BUN_INSTALL=/usr/local/bun && curl -fsSL https://bun.com/install | bash"
  sudo_cmd ln -sf /usr/local/bun/bin/bun /usr/local/bin/bun
  sudo_cmd ln -sf /usr/local/bun/bin/bunx /usr/local/bin/bunx

  if ! is_dry_run; then
    verify_command node
    verify_command npm
    verify_command pnpm
    verify_command bun
    verify_command bunx
  fi
}

install_uv_and_python() {
  log "installing uv ${UV_VERSION} and Python ${PYTHON_VERSION}"
  python_deps=(
    python3-dev
    python3-pip
    python3-venv
    build-essential
    libssl-dev
    libffi-dev
    zlib1g-dev
    libbz2-dev
    libsqlite3-dev
  )
  apt_install_if_missing "${python_deps[@]}"

  if ! have_cmd uv; then
    filename="uv-${uv_arch}-unknown-linux-gnu.tar.gz"
    tmp_tar="/tmp/${filename}"
    tmp_dir="/tmp/gomtm-install-uv"
    run_cmd curl -fsSL "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/${filename}" -o "${tmp_tar}"
    run_cmd rm -rf "${tmp_dir}"
    run_cmd mkdir -p "${tmp_dir}"
    run_cmd tar -xzf "${tmp_tar}" -C "${tmp_dir}"
    sudo_cmd install -m 0755 "${tmp_dir}/uv-${uv_arch}-unknown-linux-gnu/uv" /usr/local/bin/uv
    sudo_cmd install -m 0755 "${tmp_dir}/uv-${uv_arch}-unknown-linux-gnu/uvx" /usr/local/bin/uvx
    run_cmd rm -rf "${tmp_tar}" "${tmp_dir}"
  fi

  run_cmd uv python install "${PYTHON_VERSION}"
  if have_cmd python3; then
    python3_path="$(command -v python3)"
    sudo_cmd ln -sf "${python3_path}" /usr/local/bin/python
  fi
  if have_cmd pip3; then
    pip3_path="$(command -v pip3)"
    sudo_cmd ln -sf "${pip3_path}" /usr/local/bin/pip
  fi

  if ! is_dry_run; then
    verify_command uv
    verify_command uvx
    verify_command python
  fi
}

apt_update
install_go
install_node_and_bun
install_uv_and_python

log "runtime languages install complete"
