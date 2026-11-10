# Open questions

Claude Code: do not decide these. Ask the owner, then record the answer in `DESIGN_DECISIONS.md`.

| # | Question | Notes |
|---|---|---|
| 1 | **Stack** | Owner preference: Dart (Flutter) for the interface, Rust core, JSON for data, Python for database integrations. Suggestion under review: limit Python to offline ingestion (chunking and indexing in a sandbox) so the running app stays Dart + Rust with fewer dependencies. Flutter can target desktop and web; Rust on the web needs WebAssembly. |
| 2 | **Grading formula** | Direction agreed: grading is derived from the benchmarks approved at kickoff and worked backward. The components shown in the design (source quality, claims with a source, sample agreement, gate calls passed, external data share) and their weights are not final. |
| 3 | **Drift flag definitions** | Design assumes three flags: samples disagreed (same question asked several times, answers compared by meaning), scope (work leaving the agreed task), sources (any uncited claim). Number of samples per check is open. |
| 4 | **Retrieval over local folders** | Build 1.0 uses local folders. Keyword search, embeddings, or both, and which embedding model, is open. |
| 5 | **Connections monitor implementation** | How the app observes per-process network activity on each OS. Beta scope. |
| 6 | **Briefing room** | Now a button. What it opens, and whether collaboration involves other people or machines (which adds network access and keys). |
| 7 | **Review screen** | The sign-in page links to finished projects; that screen is not designed. |
| 8 | **Theme persistence and custom themes** | Where the chosen theme is saved; how users add their own. |
| 9 | **Audit log tamper evidence** | Recommendation: append-only with each entry hashing the previous one. Not yet agreed. |
| 10 | **Other settings sections** | Themes, Connections, Databases, Account and security are listed but not designed. |
| 11 | **Logo** | A transparent-background export (PNG or SVG) would sit cleanly on every theme. |
| 12 | **Security-key unlock** | Username and password is "for now". When a hardware key returns is open. |
| 13 | **Cloud providers** | Anthropic and OpenAI API keys are shown. Others are open. |
| 14 | **Password recovery** | Not designed. Must not depend on an online service. |
