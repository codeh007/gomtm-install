#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
. "${ROOT_DIR}/scripts/lib/common.sh"
# shellcheck source=lib/verify.sh
. "${ROOT_DIR}/scripts/lib/verify.sh"

usage() {
  cat <<'USAGE'
Usage: install-agent-tools.sh [--dry-run]

Installs low-coupling Agent CLI tools migrated from gomtm pkg/mtinstall:
Claude Code, Gemini CLI, OpenClaw, Wrangler, Playwright, and pre-commit.
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

install_npm_global_if_missing() {
  local command_name="$1"
  local package_name="$2"
  if have_cmd "${command_name}"; then
    log "${command_name} already installed for ${package_name}"
    return
  fi
  need_cmd npm
  log "installing ${package_name}"
  run_cmd npm install -g "${package_name}"
}

install_openclaw() {
  if have_cmd openclaw; then
    log "openclaw already installed"
    return
  fi
  if have_cmd bun; then
    log "installing openclaw@latest with bun"
    run_cmd bun install -g openclaw@latest
  elif have_cmd npm; then
    log "installing openclaw@latest with npm"
    run_cmd npm install -g openclaw@latest
  elif have_cmd pnpm; then
    log "installing openclaw@latest with pnpm"
    run_cmd pnpm add -g openclaw@latest
  else
    die "missing package manager for openclaw: install bun, npm, or pnpm first"
  fi
}

install_playwright() {
  if have_cmd bun; then
    log "installing Playwright with bun"
    run_cmd bun install -g playwright
  else
    install_npm_global_if_missing playwright playwright
  fi
  run_cmd playwright install --with-deps
  run_cmd playwright install chrome
}

install_pre_commit() {
  if have_cmd pre-commit; then
    log "pre-commit already installed"
    return
  fi
  if have_cmd uv; then
    log "installing pre-commit with uv tool"
    run_cmd uv tool install pre-commit
  elif have_cmd pip3; then
    log "installing pre-commit with pip3"
    run_cmd pip3 install --user pre-commit
  elif have_cmd pip; then
    log "installing pre-commit with pip"
    run_cmd pip install --user pre-commit
  else
    die "missing Python package manager for pre-commit"
  fi
}

install_npm_global_if_missing claude "@anthropic-ai/claude-code"
install_npm_global_if_missing gemini "@google/gemini-cli"
install_openclaw
install_npm_global_if_missing wrangler wrangler
install_playwright
install_pre_commit

if ! is_dry_run; then
  verify_command claude
  verify_command gemini
  verify_command openclaw
  verify_command wrangler
  verify_command playwright
  verify_command pre-commit
fi

log "agent tools install complete"
