# WO-2 · Workbench panels on mock data — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Status:** In progress · **Branch:** `wo-2/panels` · **PR:** one, into `main` (D-047)

**Goal:** Fill the workbench with sections 03–09 on clearly labeled MOCK data: connections windows, PRIMARY FOCUS with cited answers, chat input, databases, audit log, task chain and project grade. Every control works against one in-memory workspace, and every action that the spec says is logged appears in the audit log.

**Architecture:** One immutable `WorkspaceState` (models shaped like `Code/shared/contracts/*.schema.json`) held by a `WorkspaceController` (`ValueNotifier`). Widgets read state and call controller intents; the controller is also the app's `AuditSink`, so every logged action lands in the audit panel. The seed data is the reference design's mock data, in one file. Strip figures are derived from state, not hard-coded.

**Tech stack:** unchanged from WO-1. No new dependencies.

**Spec:** `Code/build-1.0-local-app/03_connections` … `09_project_grade` READMEs; visuals `Code/reference/Main.dc.html`, `Code/reference/screenshots/04–08`.

## Global constraints
- Everything from WO-1's constraints still applies (no network, pinned deps, no hard-coded colors, Monaco, immutability, 44 px targets).
- All seed data and every simulated outcome is labeled `MOCK` in the UI and lives in `lib/src/mock/`.
- No dependency is added. Where a section needs one (a native file picker for 05), the control is mocked and a drift flag is raised.

## File structure
```
lib/src/workspace/models.dart          DatabaseEntry, Connection, ContextFile, Sentence, Turn, TaskStage, GradeSnapshot
lib/src/workspace/workspace_state.dart WorkspaceState (immutable) + derived figures
lib/src/workspace/workspace_controller.dart  intents; implements AuditSink and ShellFigures
lib/src/mock/mock_workspace.dart       MOCK seed from the reference design
lib/src/panels/databases_panel.dart    06
lib/src/panels/audit_log_panel.dart    07 (+ full log screen)
lib/src/panels/task_chain_panel.dart   08
lib/src/panels/project_grade_panel.dart 09
lib/src/focus/primary_focus.dart       04 (conversation, chips, side column)
lib/src/focus/chat_input.dart          05 (message, model, tools, send, approval)
lib/src/header/connection_window.dart  03 drill-down windows
```

## Tasks

### Task 1 · Workspace model and controller
Tests first (`test/workspace/workspace_controller_test.dart`):
- toggling a database flips `active`, updates the Databases strip figure (`4/5` → `3/5`) and logs `setting_change`;
- moving a database up/down swaps ranks; ranks stay 1..n;
- weight changes clamp to 0..1 in 0.1 steps and are logged;
- revoking a hybrid connection removes it immediately and logs `connection_change`;
- ending the exposed connection removes it immediately and logs `connection_change`;
- attaching a one-off document adds it to Files in context as `one-off · unranked` and never to a ranked database (05);
- sending with the local model appends the question and a MOCK answer;
- selecting the external model with **Ask me before every call** on creates a pending approval; approving logs `approval` + `left_machine`; declining logs `approval` and sends nothing;
- audit entries are newest first; every intent returns a new state (the old one is unchanged).

### Task 2 · 06 Databases panel
Rows: rank, name, grade `n/10` (rubric sum), on/off toggle, weight bar + value. `external.db` last, dashed warning border, "data only", off by default, note line. "Adjust ranks and weights" switches to edit mode (move up/down, weight −/+). Tests: toggle and figure; external styling; edit mode reorders.

### Task 3 · 07 Audit log panel + full log
Rows: time (mono) + summary, newest first; gate rejections and anything that left the machine in the warning color with a triangle; a row expands to its detail; "Open full log" opens a full-screen list. Tests: new entry appears at the top; warning rows; expand; full log route.

### Task 4 · 08 Task chain and 09 Project grade
08: stages done/current/waiting (current in accent), tab figure from state. 09: total `/ 10`, change since milestone, components, **Needs you** box with **Review now** (opens the audit log). Grade components are MOCK (formula is open question 2). Tests: figures derive from state; Review now opens the audit panel.

### Task 5 · 04 PRIMARY FOCUS
Title with icon, context bar `used of window tokens`, question bubble, answer card ("model · every sentence carries its source"), a citation chip per sentence that opens its source preview, the disagreeing sentence highlighted with `▲ samples disagreed 2 of 5`, side column (250 px): Files in context with weights and one-off label, Drift flags, Steps. Tests: every sentence has a chip; a chip opens its source; an uncited sentence raises a Sources drift flag; one-off appears labeled.

### Task 6 · 05 Chat input
`+` (attach one-off, MOCK), message box (`EditableText`), Model select (Local default / External · data only), Tools select (allowlist only: `search, get_source` / `search only`), Send. Fixed height. Tests: attach → Files in context one-off; external model + Send asks for approval first; tools list matches the allowlist.

### Task 7 · 03 Connections windows
Centered inverted window (560 px) under the connections box for Hybrid and Exposed; one at a time; rows with name, destination, process, sent/received, approved by/when, encryption; actions Revoke / End connection / Open in audit log. Counts in the box come from state. Tests: Local not openable; actions remove the connection and log; Open in audit log opens the panel.

### Task 8 · Smoke, screenshots, docs, one PR
Extend the smoke test (every panel, a connection revoked and seen in the audit log, approval flow), refresh screenshots, update README status and this file, code review, functional verification, one PR to `main`.

## Drift flags
| ID | Found | Drift | Status |
|---|---|---|---|
| F2-1 | 2026-11-10 | `CLAUDE.md` says "One section per pull request"; owner now wants one PR per work order (D-047). | Followed owner's latest instruction; **owner to update `CLAUDE.md`** (Claude does not edit the operating rules). |
| F2-2 | 2026-11-10 | Attaching a real document (05) needs a native file dialog, i.e. a new dependency (`file_selector`). | `+` attaches a MOCK document in WO-2; dependency to be proposed with local folders (WO-5). |
| F2-3 | 2026-11-10 | Sending produces a MOCK answer; real answers need a model runtime (WO-3) and the gate (WO-4). | Labeled MOCK. |
| F2-4 | 2026-11-10 | Grade components and weights are open question 2; drift flag rules are open question 3. | Display only, MOCK values from the reference. |

## Smoke test results
_Recorded at the end of WO-2._
