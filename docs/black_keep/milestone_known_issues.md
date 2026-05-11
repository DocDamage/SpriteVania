# First Milestone Known Issues

Date: 2026-05-11

Verification completed:

- Full headless `tests/test_*.gd` suite.
- Automated keyboard route load through Sakuramori Court save shrine.
- Automated controller binding check for movement, jump, dash, attack, special, class action, interact, and pause.
- Automated reduced-motion title/world settings check.
- Automated save/continue check from each current milestone checkpoint.
- Asset integration and milestone visual checklist checks.

Blocking status:

- No automated release blockers are currently known.

Known limitations:

- Manual keyboard and controller playthroughs still need human playtest confirmation for feel, route timing, and combat readability.
- Controller glyphs are currently covered by generic joypad bindings and fallback labels, not full platform-specific glyph art.
- Milestone room art remains prototype/blockout quality with derived backdrop art, not final tile-by-tile production art.
- Derived character, enemy, and boss resources are prototype frame selections and do not yet represent final animation sets.
- Masakiro phase escalation uses a prototype oni overlay instead of a full alternate boss sprite.
- Moonpetal Passage is intentionally locked as a milestone placeholder.

Commands used for this verification pass:

- `godot --headless --path . --script tests\test_milestone_verification.gd`
- Full PowerShell loop over `tests/test_*.gd`.
- `godot --headless --path . --quit`
- `git diff --check`
