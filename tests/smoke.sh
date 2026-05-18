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
  "${ROOT_DIR}/scripts/install-runtime-languages.sh"
  "${ROOT_DIR}/scripts/install-docker.sh"
  "${ROOT_DIR}/scripts/install-agent-tools.sh"
  "${ROOT_DIR}/scripts/install-vnc.sh"
  "${ROOT_DIR}/scripts/remote-bootstrap.sh"
)

for script in "${scripts[@]}"; do
  bash -n "${script}"
done

"${ROOT_DIR}/bin/gomtm-install" --help | grep -q "gomtm-install install dev"
"${ROOT_DIR}/bin/gomtm-install" --help | grep -q "gomtm-install install runtime-languages"
"${ROOT_DIR}/bin/gomtm-install" --help | grep -q "gomtm-install install docker"
"${ROOT_DIR}/bin/gomtm-install" doctor --json | grep -q '"ok":true'
"${ROOT_DIR}/bin/gomtm-install" install base --dry-run >/tmp/gomtm-install-base.out 2>/tmp/gomtm-install-base.err
"${ROOT_DIR}/bin/gomtm-install" install dev --dry-run >/tmp/gomtm-install-dev.out 2>/tmp/gomtm-install-dev.err
"${ROOT_DIR}/bin/gomtm-install" install runtime-languages --dry-run >/tmp/gomtm-install-runtime.out 2>/tmp/gomtm-install-runtime.err
"${ROOT_DIR}/bin/gomtm-install" install docker --dry-run >/tmp/gomtm-install-docker.out 2>/tmp/gomtm-install-docker.err
"${ROOT_DIR}/bin/gomtm-install" install agent-tools --dry-run >/tmp/gomtm-install-agent-tools.out 2>/tmp/gomtm-install-agent-tools.err
"${ROOT_DIR}/bin/gomtm-install" install vnc --dry-run >/tmp/gomtm-install-vnc.out 2>/tmp/gomtm-install-vnc.err
"${ROOT_DIR}/bin/gomtm-install" remote bootstrap --dry-run code@example.com >/tmp/gomtm-install-remote.out 2>/tmp/gomtm-install-remote.err

grep -q "go1.26.2" /tmp/gomtm-install-runtime.err
grep -q "Node.js 22" /tmp/gomtm-install-runtime.err
grep -q "uv 0.9.17" /tmp/gomtm-install-runtime.err
grep -q "docker-compose" /tmp/gomtm-install-docker.err
grep -q "@anthropic-ai/claude-code" /tmp/gomtm-install-agent-tools.err
grep -q "@google/gemini-cli" /tmp/gomtm-install-agent-tools.err
grep -q "KasmVNC" /tmp/gomtm-install-vnc.err

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "${scripts[@]}"
fi

printf 'gomtm-install smoke tests passed\n'
