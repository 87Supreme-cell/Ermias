# 12 · Sign in and projects

> Build 1.0 · Spec draft for owner audit · Reference code is the approved visual design, not production code.

## What it is
The first screen: logo, motto, sign-in, then the project tiles.

## Impact on the build
It is the entry to every session and protects the encrypted settings.

## Decision and why
_Owner to fill in before audit._

## Locked
Do not change without owner approval.
- Logo (`Code/reference/assets/ermias-logo.png`) and motto **"Your work, your way"**.
- Username and password, checked on the machine. Nothing is sent anywhere.
- After sign-in: three tiles. **Review** (finished projects, read-only), **Resume** (in progress, opens the workbench), **Research** (new project, accent color, opens kickoff). Sign out button.

## Behavior and states
- Wrong password shows a short message and is logged.

## Data
None yet.

## Security rules
- Recommended, pending owner approval: store passwords only as a salted hash using Argon2id.
- Recommended, pending owner approval: the password unlocks the encryption for saved API keys, so key files are useless without it.
- No online recovery.

## Acceptance tests
- [ ] A correct password opens the tiles; a wrong one does not.
- [ ] Saved API keys cannot be read without signing in.
- [ ] Research opens kickoff; Resume opens the workbench.

## Escalate to owner when
- Anything this README does not answer.
- Adding, upgrading or replacing any dependency.
- Any network access not listed in `DESIGN_DECISIONS.md`.
- Changing anything under **Locked**.
- Designing password recovery (open question 14) or the Review screen (open question 7).

## Reference code
- `../../reference/Splash.dc.html`
