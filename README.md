# gomtm-install

`gomtm-install` is now a legacy compatibility/bootstrap repository.

Canonical installer truth has moved to:

- skill: `skills/gomtm-installer/SKILL.md`
- source: `skills/gomtm-installer/src/`
- workflow: repository root `.github/workflows/`
- installer binary: `mtminstaller`

This repository may still carry thin scripts for temporary migration or compatibility, but new installer logic should live in the `mtminstaller` Go codebase and its root workflows.

## Current role

- Keep the legacy shell entry points as thin as possible.
- Redirect new work toward `mtminstaller`.
- Avoid adding new installer responsibilities here.

## Install skills

```bash
npx skills add https://github.com/codeh007/gomtm-install --list
npx skills add https://github.com/codeh007/gomtm-install --skill gomtm-installer --global --yes
```

## Legacy scripts

The shell scripts remain only for migration compatibility and should not be expanded into a second canonical installer path.
