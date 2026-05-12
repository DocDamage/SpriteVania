# Test Strategy

This document defines how The Black Keep should be verified as systems grow.
It complements the milestone verification plan with a broader engineering test
approach.

## Goals

- Catch save and room-transition regressions early.
- Keep movement and combat changes measurable.
- Make controller support verifiable.
- Separate headless tests, dev scenes, and manual playtests.
- Keep warnings from hiding real failures.

## Test Layers

Headless tests:

- Fast tests for resources, save data, movement logic, room graph, CharacterCreator2D manifests, recipes, export profiles, and state.

Dev scenes:

- Playable import scene.
- Movement sandbox.
- Combat sandbox.
- Enemy AI sandbox.
- Hub service sandbox.

Manual playtests:

- Full route checks.
- Controller checks.
- Visual checks.
- Accessibility checks.

Release-candidate checks:

- Full milestone route.
- Save and continue across checkpoints.
- No blocker list.

## Headless Test Areas

Save tests:

- Save version exists.
- Global settings save without game save.
- Save slots list correctly.
- Corrupt save does not crash.
- Legacy save migrates or fails safely.
- Room and checkpoint IDs validate.

Room tests:

- Every room instantiates.
- Every exit target exists.
- Every spawn marker exists.
- Locked exits remain locked.
- Unlocked exits route correctly.
- First-room left edge is safe.

Movement tests:

- Dash moves over multiple frames.
- Dash stops on collision.
- Air dash count is enforced.
- Double jump count is enforced.
- Wall hang duration works.
- Wall jump pushes away from wall.
- Dash-strike creates the expected forward hitbox.
- Dive bomb bounces on enemy hit.

CharacterCreator2D tests:

- Source manifest preserves the full imported package payload.
- Runtime assets load without importing raw Unity-only reference files.
- Export profile exposes complete base and aim animation inventory.
- Bulk export sets expose first-slice, movement, combat, all-base, and all-aim checklists.
- Recipes validate selected parts, palettes, morph values, content-pack versions, and fallbacks.
- Generated or imported `SpriteFrames` load and can be assigned to the player.
- Missing animations and invalid recipes fail with actionable validation messages.

Combat tests:

- Attack creates hitbox.
- Hitbox damages enemy.
- Enemy attack damages player.
- Combo advances and resets.
- Damage ownership records player or familiar source.
- XP awards once on enemy death.

Enemy tests:

- Patrol follows path.
- Aggro detects player.
- Attack state has windup, active, and recovery.
- Leash returns or resets.
- Room re-entry respawns standard enemies.
- Persistent defeats stay defeated.

Party tests:

- Starter save creates one active character.
- Witch recruitment creates second active character.
- Shadow recruitment creates third active character.
- Swap changes visible character.
- KO auto-switch selects living character.
- Party order saves and loads.

Familiar tests:

- Familiar follows after transition.
- Familiar attacks enemy.
- Familiar gains XP.
- Familiar level saves and loads.
- Familiar evolution saves and loads.
- Familiar abilities save and load.

Settings tests:

- Accessibility opens correct tab.
- Invalid setting values clamp.
- Input conflicts are detected.
- Reduced motion affects title and gameplay effects.
- Controller glyph style can be set.

## Dev Scene Requirements

Playable import scene:

- Shows candidate sprites.
- Checks animation availability.
- Tests scale.
- Tests movement actions.

Movement sandbox:

- Ground dash lane.
- Air dash gap.
- Double-jump ledge.
- Wall hang and wall jump wall.
- Dash-strike target lane.
- Dive-bomb dummy.

Character creator sandbox:

- Layered rig preview.
- Part and palette selection.
- Morph controls.
- Animation checklist preview.
- Sheet bake and `SpriteFrames` generation.
- Validation report display.

Combat sandbox:

- Stationary dummy.
- Moving dummy.
- Armored dummy.
- Ranged target.
- Hitbox debug toggle.

Enemy AI sandbox:

- Patrol path.
- Ledge path.
- Aggro zone.
- Attack range.
- Leash boundary.

Hub service sandbox:

- Save shrine.
- Party shrine.
- Training dummy.
- Placeholder services.

## Manual Playtest Matrix

Input devices:

- Keyboard and mouse.
- Xbox-style controller.
- PlayStation-style controller.
- Generic controller fallback.

Routes:

- New Game to Swamp.
- Swamp to Castle Gate.
- Castle Gate to Witch recruitment.
- Witch tutorial to Samurai Castle.
- Shadow rescue to Masakiro.
- Masakiro to Sakuramori Court.

Settings:

- Default settings.
- Reduced motion.
- High contrast.
- Large text.
- Screen shake off.
- Damage numbers off.

## Failure Severity

Blocker:

- Prevents route completion.
- Corrupts saves.
- Crashes.
- Loses player control.
- Makes player disappear or softlock.

High:

- Core action unreliable.
- Enemy or boss cannot be completed fairly.
- Continue loads wrong state.
- Controller cannot complete route.

Medium:

- Visual readability issue.
- Tuning issue.
- Placeholder art too confusing.
- Non-critical UI issue.

Low:

- Cosmetic issue.
- Minor copy issue.
- Non-blocking polish issue.

## Warning Policy

Warnings should not be ignored forever.

Rules:

- Known non-fatal warnings must be documented.
- New warnings should be reviewed before marking test pass.
- Cleanup warnings after PASS should get a tracked issue if not fixed.
- Warnings that hide failures should be treated as high severity.

## Continuous Verification Order

Before merging major gameplay work:

1. Run targeted tests for touched systems.
2. Run full headless suite.
3. Run relevant dev scene.
4. Run manual route segment.
5. Update known issues.

Before milestone candidate:

1. Full headless suite.
2. Full keyboard route.
3. Full controller route.
4. Save/continue from every checkpoint.
5. Visual screen-fill review.
6. Reduced-motion review.
