# Operating rules for Claude Code in this repo

Read these before writing any code: `README.md`, `DESIGN_DECISIONS.md`, `OPEN_QUESTIONS.md`, then the README of the section you are building in `Code/build-1.0-local-app/`.

## Stop and ask the owner
Ask before you act whenever:
- a question is listed as open in `OPEN_QUESTIONS.md`, or the spec does not answer it;
- you would add, upgrade or replace a dependency;
- code would make any network connection not already approved in `DESIGN_DECISIONS.md`;
- a change touches anything a section README marks as **Locked**;
- you are unsure. Interviewing the owner is always preferred over guessing.

Confirm every permission (files, folders, network, publishing) before using it.

## Non-negotiables
- Local first. No telemetry, analytics, crash reporting or update checks. Fonts, icons and images are bundled; nothing is fetched at runtime.
- Security and reliability over speed.
- Few dependencies, pinned to exact versions, vendored where practical. Record each one with its reason.
- Mock data is labeled `MOCK` in the interface and in code, and is built to be swapped for real data without changing the interface.
- Every claim shown to the user carries its source. External (cloud) answers are stored as data, never executed as instructions.
- The gate (section 11) is deterministic. No model decides what is allowed.

## How to use the reference code
Files ending in `.reference.html` and everything in `Code/reference/` are the approved visual design. Values written `{{t.<name>}}` come from `Code/shared/themes.json`. Rebuild them in the chosen stack. Do not ship the HTML.

## Build order
Follow `README.md` → Build order. One section per pull request.
