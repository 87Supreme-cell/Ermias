# Locked decisions

Agreed in design review on 2026-11-10. Change only with the owner's approval, and record the change here with its date and reason.

## Principles
- **Data sovereignty.** The person owns the data, the compute and the decisions.
- **Local first.** Local models and local files are the default. Anything that leaves the machine is visible, approved and logged.
- **Human decides, machine executes.** The person sets goals, ranks sources and approves benchmarks and cloud calls.
- **Every claim carries its source.** Answers cite the database and chunk each sentence came from.
- **External answers are data, never instructions.** Cloud model output is stored as the lowest-ranked source and passes the gate like everything else.
- **The author is never the auditor.** Checks are independent of what they check.
- **Security and reliability over speed.**

## Interface
- **Layout principle: edge tool strips with overlay panels** on both sides (progressive disclosure, focus + context). Built into the app as the standard pattern, not a setting.
  - Left strip: Databases, Audit log. Right strip: Task chain, Project grade.
  - One panel open per side. Panels overlay the center and do not push it.
  - New panels are added as tabs on a strip, never as new columns.
- **PRIMARY FOCUS** (title in bold capitals) fills the center between the strips. The chat area below it keeps a fixed size.
- **Header:** row 1 holds the name, session state and resource tracking (model identity with hash check, memory, CPU, network, date and time). Row 2 holds the theme switch, Briefing room button and Settings gear, with the **connections box centered**.
- **Connections box** uses the theme's inverted colors for high contrast.
- **Themes:** Blues (default), Cyberpunk, Sunburst, Earth tones. Glass (translucent, blurred) for the header, strips and side panels. Solid for PRIMARY FOCUS and chat. Defined in `Code/shared/themes.json`; custom themes are added there later.
- **Color meaning:** accent = verified or active; warning color = needs a human. Risk tiers also use shapes (circle, diamond, triangle) so color is never the only signal.
- **Icons:** thin outline style. Settings is a gear icon.
- **One-off documents** are attached with the + button, stay unranked, and are labeled as one-off in Files in context.
- **Sign-in page:** logo, motto "Your work, your way", username and password, then three tiles: Review (finished projects), Resume (in progress), Research (new project, opens kickoff).
- **Project kickoff:** a short series of questions, each with recommended answers plus a free-text option, and a live AI synthesis panel. The person approves every benchmark before grading starts.

## Connections monitor tiers
- **Green, Local:** loopback or local processes only. Not openable.
- **Orange, Hybrid:** internet access allowed but not active, or metadata-only calls such as update checks. Openable.
- **Red, Exposed:** an active connection sending content (prompts, documents, answers). Openable.
- Scope: pings from apps and connected folders, plus API and MCP connections. Released as beta.

## Build
- **Handoff format:** specs plus data definitions per section (Option A). Production code is written in the chosen stack. Questions come back to the owner.
- **Build 1.0:** local app; local folders as databases; connections monitor in beta.
- **Build 2.0:** PWA deploy, OS-specific dependencies, a full database engine, dependency review.
- **Sign-in:** username and password for now, checked locally.
- **Cloud models:** API keys only. Subscription sign-in is excluded: Anthropic's terms (updated February 2026) do not allow consumer-plan sign-in in third-party apps.
- **Local model providers:** LM Studio, Ollama and llama.cpp, with editable endpoints.

## Changes
Each change to a decision above, with its date and reason. Full trail in `DECISION_LOG.md`.

- **2026-11-10 · Warning color (Blues, Earth tones) → yellow.** Owner decision (D-013). The original warning colors could not be told from the accent in grayscale (Earth tones ratio 1.00, Blues 1.28), failing the 01_themes acceptance test. New values in `Code/shared/themes.json`; text on a warning fill uses the theme's dark ink (D-014).
- **2026-11-10 · Font → Monaco**, replacing Inter and JetBrains Mono. Owner decision (D-015). Monaco is supplied by the operating system and never bundled, because its license does not permit redistribution; fallbacks are Menlo, Consolas and DejaVu Sans Mono (D-016). Nothing is fetched at runtime.
