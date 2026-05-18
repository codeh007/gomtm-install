# gomtm-install

`gomtm-install` is the standalone installer and Agent bootstrap project for gomtm-adjacent host setup.

The gomtm core repository should stay focused on runtime, server, control-plane, and database behavior. Host provisioning, development machine setup, Agent tooling, VNC/browser setup, and base image assembly belong here.

## Repository Layout

```text
bin/       Thin CLI dispatcher for humans and agents.
scripts/   Idempotent installer and diagnostic scripts.
skills/    Installable Agent-facing skill entrypoint.
tests/     Smoke tests for routing, syntax, and dry-run behavior.
```

## Commands

```bash
bin/gomtm-install doctor
bin/gomtm-install doctor --json
bin/gomtm-install install base --dry-run
bin/gomtm-install install dev --dry-run
bin/gomtm-install install runtime-languages --dry-run
bin/gomtm-install install docker --dry-run
bin/gomtm-install install agent-tools --dry-run
bin/gomtm-install install vnc --dry-run
bin/gomtm-install remote bootstrap --dry-run user@host
```

`install dev` delegates to `install base`, `install runtime-languages`, and `install docker`.

## Install Skills

`npx skills` clones source repositories with git. It does not expose a separate token flag; credentials must be available to git through normal git authentication paths.

List skills from the public repository:

```bash
npx skills add https://github.com/codeh007/gomtm-install --list
```

Install the canonical installer skill globally:

```bash
npx skills add https://github.com/codeh007/gomtm-install --skill gomtm-installer --global --yes
```

Install from a local checkout while developing:

```bash
npx skills add . --skill gomtm-installer --global --yes
```

## Agent Entry

Use `skills/gomtm-installer/SKILL.md` as the Agent-facing entrypoint.

## Migration Boundary

This repository is now the canonical home for new host provisioning work. The existing `gomtm install` command remains in gomtm core for compatibility while callers and Dockerfile/base-image behavior are migrated. Do not add new installer responsibilities to `gomtm/pkg/mtinstall/installers`.

Currently migrated here:

- base OS package list
- development host package list
- Go 1.26.2, Node.js 22, Bun, uv 0.9.17, Python 3.12
- Docker and docker-compose
- Agent CLI tools: Claude Code, Gemini CLI, OpenClaw, Wrangler, Playwright, pre-commit
- KasmVNC desktop dependency setup

## Verification

```bash
tests/smoke.sh
```
