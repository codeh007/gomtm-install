#!/usr/bin/env bash

set -euo pipefail

GOMTM_INSTALL_DRY_RUN="${GOMTM_INSTALL_DRY_RUN:-0}"

log() {
  printf '[gomtm-install] %s\n' "$*" >&2
}

die() {
  printf '[gomtm-install] ERROR: %s\n' "$*" >&2
  exit 1
}

usage_error() {
  die "$1"
}

is_dry_run() {
  [ "${GOMTM_INSTALL_DRY_RUN}" = "1" ]
}

run_cmd() {
  if is_dry_run; then
    printf '[dry-run] %s\n' "$*" >&2
    return 0
  fi
  "$@"
}

run_shell() {
  if is_dry_run; then
    printf '[dry-run] bash -lc %s\n' "$1" >&2
    return 0
  fi
  bash -lc "$1"
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

need_cmd() {
  local name="$1"
  if ! have_cmd "${name}"; then
    die "required command not found: ${name}"
  fi
}

sudo_cmd() {
  if [ "$(id -u)" = "0" ]; then
    run_cmd "$@"
    return
  fi
  need_cmd sudo
  run_cmd sudo "$@"
}

sudo_shell() {
  if [ "$(id -u)" = "0" ]; then
    run_shell "$1"
    return
  fi
  need_cmd sudo
  if is_dry_run; then
    printf '[dry-run] sudo bash -lc %s\n' "$1" >&2
    return 0
  fi
  sudo bash -lc "$1"
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

shell_quote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}
