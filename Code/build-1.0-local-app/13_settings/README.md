# 13 · Settings: model providers

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
Where local runtimes and cloud API keys are configured. Opened from the gear.

## Impact on the build
It decides which models the app can use and keeps cloud use deliberate.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- **Local runtimes** (green, Local): LM Studio, Ollama, llama.cpp. Each has an editable endpoint, a reachable or not-running status, a model picker, Test connection and Make default. Plus Add local endpoint.
- Default endpoints: LM Studio `http://127.0.0.1:1234/v1`, Ollama `http://127.0.0.1:11434`, llama.cpp `http://127.0.0.1:8080/v1`.
- **Cloud models** (orange, Hybrid): API keys only, Anthropic and OpenAI shown. Keys stored encrypted, never shown again after saving. **Ask me before every call** is on by default.
- A banner shows the default model for new projects. Local is the default.
- Other settings sections are listed as later.

## Behavior and states
- Test connection reports reachable or not running.
- Saving a key confirms with only its last four characters.

## Data
`model_provider.schema.json`

## Security rules
- Local endpoints must resolve to this machine. A non-local address is refused.
- Cloud use is never enabled by default.

## Acceptance tests
- [ ] Each local runtime is detected when running and reported as not running when stopped.
- [ ] Default ports match each tool's current documentation at build time.
- [ ] A saved key cannot be displayed again.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- Adding a provider not listed here (open question 13).

## Reference code
- `../../reference/Settings.dc.html`
