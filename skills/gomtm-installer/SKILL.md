---
name: gomtm-installer
description: Use when initializing a Linux host for gomtm-adjacent work, preparing a development machine, diagnosing installer prerequisites, or deciding whether a host setup task belongs in gomtm-install instead of gomtm core.
---

# gomtm Installer

## Core Rules

- Prefer `gomtm-install` for host provisioning, development environment setup, Agent tooling, VNC/browser setup, and future base image assembly.
- Treat the existing `gomtm install` command as legacy/current gomtm-core compatibility during migration. Do not add new installer responsibilities to `pkg/mtinstall/installers`.
- Use scripts first. The CLI is a thin dispatcher over scripts.
- Keep scripts idempotent, readable, and independently runnable.
- Use `--dry-run` before changing a host when a dry-run mode exists.
- For remote hosts, verify local command behavior before connecting.

## Commands

```bash
bin/gomtm-install doctor
bin/gomtm-install doctor --json
bin/gomtm-install install base --dry-run
bin/gomtm-install install dev --dry-run
bin/gomtm-install install agent-tools --dry-run
bin/gomtm-install install vnc --dry-run
bin/gomtm-install remote bootstrap --dry-run user@host
```

## Workflow

1. Run `bin/gomtm-install doctor --json`.
2. Choose the smallest install target:
   - `install base` for runtime host prerequisites.
   - `install dev` for a development host.
   - `install agent-tools` for optional Agent tools after Phase 2 migrations exist.
   - `install vnc` for VNC setup after Phase 2 migration exists.
3. Run the command with `--dry-run`.
4. Run the command without `--dry-run` only after the dry-run output matches the target.
5. Run `tests/smoke.sh` after changing scripts or CLI routing.

## Boundaries

- Do not copy OpenCLI or CLI-Anything skills into this project by default. Treat them as references for Agent-native CLI design.
- Do not install optional third-party Agent tools in Phase 1 scripts unless a later task explicitly migrates that tool.
- Do not delete `gomtm install` until gomtm core callers and Dockerfile users are migrated in later phases.

## Verification

```bash
tests/smoke.sh
```
