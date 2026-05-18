#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
. "${ROOT_DIR}/scripts/lib/common.sh"

OUTPUT_JSON=0

usage() {
  cat <<'USAGE'
Usage: doctor.sh [--json]

Checks the local host for gomtm-install prerequisites.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --json)
      OUTPUT_JSON=1
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

os_name="$(uname -s 2>/dev/null || printf unknown)"
arch_name="$(uname -m 2>/dev/null || printf unknown)"
has_apt=false
has_sudo=false
has_curl=false
has_git=false

have_cmd apt-get && has_apt=true
have_cmd sudo && has_sudo=true
have_cmd curl && has_curl=true
have_cmd git && has_git=true

if [ "${OUTPUT_JSON}" = "1" ]; then
  cat <<JSON
{"ok":true,"os":"$(json_escape "${os_name}")","arch":"$(json_escape "${arch_name}")","commands":{"apt_get":${has_apt},"sudo":${has_sudo},"curl":${has_curl},"git":${has_git}}}
JSON
  exit 0
fi

log "os=${os_name} arch=${arch_name}"
log "apt-get=${has_apt} sudo=${has_sudo} curl=${has_curl} git=${has_git}"
