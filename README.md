# gomtm-install

`gomtm-install` is the standalone installer and Agent bootstrap project for gomtm-adjacent host setup.

The gomtm core repository should stay focused on runtime, server, control-plane, and database behavior. Host provisioning, development machine setup, Agent tooling, VNC/browser setup, and base image assembly belong here.

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

## Agent Entry

Use `skills/gomtm-installer/SKILL.md` as the Agent-facing entrypoint.

## Phase 1 Boundary

Phase 1 provides the repository skeleton, CLI dispatcher, dry-run-safe scripts, smoke tests, and CI. It does not delete or replace the existing `gomtm install` command yet.

## Verification

```bash
tests/smoke.sh
```
