# Ermias

**Your work, your way.** A local research and build app: the person sets the goal, ranks the sources and approves each step; the model does the processing on the person's own machine.

This repository currently holds the **handoff specification** for Build 1.0: the approved interface design, the locked decisions, and a spec for each section. No production code exists yet.

## Repository map
```
CLAUDE.md                  operating rules for Claude Code (read first)
DESIGN_DECISIONS.md        locked decisions
OPEN_QUESTIONS.md          undecided items; ask the owner, do not guess
Code/
  shared/
    themes.json            the 4 themes as data (single source of truth)
    contracts/             draft data formats; they also define the gate's allowlist
  build-1.0-local-app/     one folder per section: README spec + reference code
  build-2.0-pwa/           deferred scope
  reference/               complete approved design source and logo
```

## Screens in Build 1.0
1. **Sign in and projects** (`12_sign_in`): username and password, then Review / Resume / Research.
2. **Project kickoff** (`10_project_kickoff`): goal, deliverable, sources, benchmarks, confirm.
3. **Workbench** (`00`–`09`, `11`): header, edge tool strips, PRIMARY FOCUS, chat.
4. **Settings: model providers** (`13_settings`): local runtimes and cloud API keys.

## Build order
1. Interface on clearly labeled mock data, built so each mock can be replaced without changing the interface.
2. The gate (`11_gate`).
3. Local folders as the source databases (`06_databases`). A full database engine is Build 2.0.
4. Connections monitor (`03_connections`), released as beta.
5. Grading (`09_project_grade` with `10_project_kickoff`). A core function, not an add-on.

## Status
Specification draft. Every section README has a **Decision and why** field for the owner to complete during audit.

## License
MIT. See `LICENSE`.
