# Risk Register

This document lists the main production risks for The Black Keep and how to
reduce them.

## Risk Levels

High:

- Can block the milestone or force major rework.

Medium:

- Can slow development or reduce quality if ignored.

Low:

- Can be handled during polish or content lock.

## High Risks

Asset mismatch:

- Risk: mixed asset packs may not feel coherent.
- Impact: high.
- Mitigation: use art pipeline gates, contact sheets, and in-engine motion tests.
- Owner area: art pipeline.

Playable sprite coverage:

- Risk: selected characters may lack dash, dash-strike, wall, or special animations.
- Impact: high.
- Mitigation: accept prototype fakes early, document missing frames, and plan
  cleanup.
- Owner area: asset integration.

Save migration complexity:

- Risk: current save data may not map cleanly into party roster state.
- Impact: high.
- Mitigation: add versioned save data, migration helpers, and fallback load
  rules before party work.
- Owner area: save foundation.

Party system scope:

- Risk: three-character active party can destabilize player, HUD, save, combat,
  and camera code.
- Impact: high.
- Mitigation: implement one-character, two-character, then three-character
  phases with tests.
- Owner area: party system.

Movement collision bugs:

- Risk: dash, air dash, wall jump, and dive bomb can tunnel through collision or
  softlock rooms.
- Impact: high.
- Mitigation: movement sandbox, collision tests, and room-bound regression.
- Owner area: movement.

Enemy AI reliability:

- Risk: patrols can get stuck or enemies may fail to attack.
- Impact: high.
- Mitigation: explicit patrol nodes, leash rules, attack state tests, and
  respawn tests.
- Owner area: enemy AI.

## Medium Risks

Controller support ambiguity:

- Risk: actions may work on keyboard but not modern controllers.
- Impact: medium.
- Mitigation: controller glyph settings and controller route playtests.
- Owner area: input.

Title and settings persistence:

- Risk: settings stored only in save data cannot apply before New Game.
- Impact: medium.
- Mitigation: global settings file.
- Owner area: settings.

Room graph drift:

- Risk: docs, room IDs, and scenes can diverge.
- Impact: medium.
- Mitigation: room graph tests and stable ID conventions.
- Owner area: room management.

World Break scope:

- Risk: post-break variants can multiply content requirements.
- Impact: medium.
- Mitigation: state-driven variants first, separate scenes only for large layout
  changes.
- Owner area: world state.

Final dungeon asset risk:

- Risk: tower, organic horror, and core assets may not support final vision.
- Impact: medium.
- Mitigation: keep final dungeon planning data-driven and delay room build until
  asset review.
- Owner area: final dungeon.

## Low Risks

Exact names for non-first seals:

- Risk: seal names may change.
- Impact: low.
- Mitigation: use stable IDs and allow display names to change.
- Owner area: traversal.

Credits completeness:

- Risk: asset credits may be incomplete during prototype.
- Impact: low now, high before release.
- Mitigation: track source pack credits during asset classification.
- Owner area: production.

Extras content:

- Risk: Extras screen can grow too large.
- Impact: low for milestone.
- Mitigation: ship clean locked placeholders first.
- Owner area: UI.

## Risk Review Cadence

During milestone development:

- Review high risks weekly.
- Review medium risks before each feature merge.
- Update mitigation when a risk becomes a bug.
- Close risks only after tests or playtests prove mitigation.

Before merge to main:

- No unresolved high risk should remain without an explicit known-issue note.
- Save and controller risks must be tested, not assumed.
- Asset risks must identify prototype versus final-art status.
