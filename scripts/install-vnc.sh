#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
. "${ROOT_DIR}/scripts/lib/common.sh"
# shellcheck source=lib/apt.sh
. "${ROOT_DIR}/scripts/lib/apt.sh"
# shellcheck source=lib/verify.sh
. "${ROOT_DIR}/scripts/lib/verify.sh"

KASMVNC_VERSION="1.4.0"

usage() {
  cat <<'USAGE'
Usage: install-vnc.sh [--dry-run]

Installs KasmVNC and desktop dependencies migrated from gomtm pkg/mtinstall/installers/vnc.
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

desktop_packages=(
  dbus-x11
  locales
  pavucontrol
  pulseaudio
  pulseaudio-utils
  x11-xserver-utils
  xfce4
  xfce4-goodies
  xfce4-pulseaudio-plugin
  openssl
  pciutils
  bash-completion
  xorg
  xrdp
  dbus
  xdg-utils
  fbautostart
  at-spi2-core
  xterm
  libswitch-perl
  libtry-tiny-perl
  libyaml-tiny-perl
  libhash-merge-simple-perl
  liblist-moreutils-perl
  libdatetime-perl
  libdatetime-timezone-perl
  xfonts-intl-chinese
  xfonts-wqy
  fcitx
  fcitx-googlepinyin
  fcitx-module-cloudpinyin
  fcitx-config-gtk
)

write_root_file() {
  local path="$1"
  local content="$2"
  sudo_cmd mkdir -p "$(dirname "${path}")"
  if is_dry_run; then
    printf '[dry-run] write %s\n' "${path}" >&2
    return 0
  fi
  printf '%s\n' "${content}" | sudo tee "${path}" >/dev/null
}

install_desktop_base() {
  log "installing VNC desktop dependencies"
  apt_update
  apt_install_if_missing debconf-utils
  apt_install_if_missing "${desktop_packages[@]}"
}

install_kasmvnc() {
  if have_cmd kasmvncserver; then
    log "KasmVNC already installed"
    return
  fi

  distro_name="bullseye"
  if [ -r /etc/os-release ] && . /etc/os-release && [ "${ID:-}" = "ubuntu" ]; then
    distro_name="jammy"
  fi

  deb_url="https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_${distro_name}_${KASMVNC_VERSION}_amd64.deb"
  deb_path="/tmp/kasmvncserver.deb"
  log "installing KasmVNC ${KASMVNC_VERSION} from ${deb_url}"
  run_cmd curl -fsSL "${deb_url}" -o "${deb_path}"
  sudo_cmd dpkg -i "${deb_path}" || sudo_cmd apt-get install -f -y
  if ! is_dry_run && ! have_cmd kasmvncserver; then
    sudo_cmd dpkg -i "${deb_path}"
  fi
  run_cmd rm -f "${deb_path}"
}

configure_fcitx() {
  log "configuring Fcitx desktop input method"
  write_root_file /etc/X11/xinit/xinitrc.d/fcitx.sh '#!/bin/bash
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
fcitx-autostart &'
  sudo_cmd chmod +x /etc/X11/xinit/xinitrc.d/fcitx.sh
  write_root_file /etc/xdg/autostart/fcitx-autostart.desktop '[Desktop Entry]
Name=Fcitx
Exec=fcitx-autostart
Icon=fcitx
Terminal=false
Type=Application
StartupNotify=false
NoDisplay=true
X-GNOME-Autostart-Phase=Applications'
  write_root_file /etc/profile.d/fcitx.sh 'export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx'
}

install_desktop_base
install_kasmvnc
configure_fcitx

if ! is_dry_run; then
  verify_command kasmvncserver
fi

log "vnc install complete"
