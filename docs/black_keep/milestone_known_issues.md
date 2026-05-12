# First Milestone Known Issues

Date: 2026-05-12

Verification completed:

- Full headless `tests/test_*.gd` suite.
- Automated keyboard route load through Sakuramori Court save shrine.
- Automated controller binding check for movement, jump, dash, attack, special, class action, interact, and pause.
- Automated reduced-motion title/world settings check.
- Automated save/continue check from each current milestone checkpoint.
- Asset integration and milestone visual checklist checks.
- Focused checks for HUD party KO display, in-game creator readiness reports,
  Party Shrine atomic rename/reorder commits, and overwrite-safe New Game
  confirmation.

Blocking status:

- No automated release blockers are currently known.

Known limitations:

- Manual keyboard and controller playthroughs still need human playtest confirmation for feel, route timing, and combat readability.
- Controller prompts have selectable Generic, Xbox, PlayStation, and Switch text labels, but not final platform-specific glyph art.
- Milestone room art remains prototype/blockout quality with derived backdrop art, not final tile-by-tile production art.
- Derived character, enemy, and boss resources are prototype frame selections and do not yet represent final animation sets.
- Masakiro phase escalation uses a prototype oni overlay instead of a full alternate boss sprite.
- Moonpetal Passage is intentionally locked as a milestone placeholder.

Commands used for this verification pass:

- `godot --headless --path . --script tests\test_milestone_verification.gd`
- Full PowerShell loop over `tests/test_*.gd`.
- `godot --headless --path . --quit`
- `git diff --check`
- `.\tools\run_tests.ps1 -Tests tests/test_hud.gd,tests/test_character_creation.gd,tests/test_main_title_menu.gd,tests/test_sakuramori_services.gd,tests/test_shadow_recruitment.gd,tests/test_witch_recruitment.gd -KeepGoing`
