#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

scripts=(
  "${ROOT_DIR}/bin/gomtm-install"
  "${ROOT_DIR}/scripts/lib/common.sh"
  "${ROOT_DIR}/scripts/lib/apt.sh"
  "${ROOT_DIR}/scripts/lib/verify.sh"
  "${ROOT_DIR}/scripts/doctor.sh"
  "${ROOT_DIR}/scripts/install-base.sh"
  "${ROOT_DIR}/scripts/install-dev.sh"
  "${ROOT_DIR}/scripts/install-agent-tools.sh"
  "${ROOT_DIR}/scripts/install-vnc.sh"
  "${ROOT_DIR}/scripts/remote-bootstrap.sh"
)

for script in "${scripts[@]}"; do
  bash -n "${script}"
done

"${ROOT_DIR}/bin/gomtm-install" --help | grep -q "gomtm-install install dev"
"${ROOT_DIR}/bin/gomtm-install" doctor --json | grep -q '"ok":true'
"${ROOT_DIR}/bin/gomtm-install" install base --dry-run >/tmp/gomtm-install-base.out 2>/tmp/gomtm-install-base.err
"${ROOT_DIR}/bin/gomtm-install" install dev --dry-run >/tmp/gomtm-install-dev.out 2>/tmp/gomtm-install-dev.err
"${ROOT_DIR}/bin/gomtm-install" install agent-tools --dry-run >/tmp/gomtm-install-agent-tools.out 2>/tmp/gomtm-install-agent-tools.err
"${ROOT_DIR}/bin/gomtm-install" install vnc --dry-run >/tmp/gomtm-install-vnc.out 2>/tmp/gomtm-install-vnc.err
"${ROOT_DIR}/bin/gomtm-install" remote bootstrap --dry-run code@example.com >/tmp/gomtm-install-remote.out 2>/tmp/gomtm-install-remote.err

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "${scripts[@]}"
fi

printf 'gomtm-install smoke tests passed\n'
