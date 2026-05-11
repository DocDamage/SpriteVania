# First Milestone Build Tasks

This document turns the first milestone production spec into implementation-sized
tasks. It is intentionally practical: every section should map to scenes,
scripts, assets, tests, or playtest checks.

## Scope

The milestone starts at New Game and ends when the player reaches Sakuramori
Court with a three-character active party.

Included:

- Character creation for the three starters.
- Modern opening route.
- Swamp route cleanup.
- Castle Gate arrival.
- Black Witch recruitment.
- Two-character tag-swap tutorial.
- Samurai Castle Wing.
- Shadow rescue.
- Three-character party handoff.
- Masakiro boss.
- Rising Torii Seal pickup.
- Sakuramori Court hub shell.

Not included:

- Full final roster.
- Full affinity system.
- Final dialogue.
- Full equipment economy.
- Full World Break implementation.
- Final art for every playable character.

## Milestone Definition Of Done

The milestone is complete when:

- A fresh New Game reaches Sakuramori Court without debug setup.
- Continue reloads the most recent milestone save.
- Load Game can reach the correct save path, even if the slot UI is basic.
- The player cannot disappear off the left edge of the first screen.
- Screen framing fills the intended viewport without exposed void areas.
- The player can attack enemies clearly with keyboard and controller.
- Enemies can damage the player.
- Room enemies respawn when the player leaves and re-enters.
- Double jump, dash, air dash, wall jump, wall hang, slide attack, and dive
  bomb are testable in controlled milestone rooms.
- The familiar follows, attacks, levels, and preserves state through saves.
- The Witch joins the party and can tag in.
- The Shadow joins the party and can tag in.
- Masakiro can be defeated without softlocks.
- The Rising Torii Seal unlocks a vertical ascent test.
- Sakuramori Court loads with save shrine and party-management placeholders.

## Scene Naming

Use stable scene IDs before building more rooms.

Opening route:

- `ModernOutskirts_Start`
- `ModernOutskirts_StreetBreak`
- `ModernOutskirts_ExitRoad`
- `RuralRoad_Approach`
- `RuralRoad_Sink`
- `RuralRoad_SwampEntry`

Swamp route:

- `Swamp_Start`
- `Swamp_MovementTutorial`
- `Swamp_EnemyTutorial`
- `Swamp_Checkpoint`
- `Swamp_Hazard`
- `Swamp_Shortcut`
- `Swamp_MinibossGate`
- `Swamp_CastleExit`

Castle Gate route:

- `CastleGate_Causeway`
- `CastleGate_BrokenPortcullis`
- `CastleGate_DamagedShrineApproach`
- `CastleGate_DamagedShrine`
- `CastleGate_TagTutorial`

Samurai Castle Wing:

- `SamuraiCastle_OuterWall`
- `SamuraiCastle_PatrolHall`
- `SamuraiCastle_Watchpost`
- `SamuraiCastle_PrisonApproach`
- `SamuraiCastle_ShadowPrison`
- `SamuraiCastle_AlarmEscape`
- `SamuraiCastle_BossAntechamber`
- `SamuraiCastle_MasakiroArena`
- `SamuraiCastle_RisingToriiSeal`
- `SamuraiCastle_AscentTest`

Hub:

- `SakuramoriCourt_Entrance`
- `SakuramoriCourt_SaveShrine`
- `SakuramoriCourt_PartyShrine`
- `SakuramoriCourt_MoonpetalPassage`

## Workstream 1: Screen Bounds And Camera

Problem to solve: the player can leave the first screen and disappear.

Tasks:

- Define room bounds for every milestone room.
- Clamp the player or block exits unless a valid room transition exists.
- Add visible collision to all hard room edges during debug builds.
- Ensure the camera never reveals unloaded void outside the current room.
- Add transition handoff positions for every doorway.
- Add a first-screen regression test for the left boundary.

Acceptance:

- Walking left from `ModernOutskirts_Start` or `Swamp_Start` never loses the
  player.
- Returning from a left-edge test restores normal control.
- The camera fills the viewport at 1280x720 and the project's target test
  viewport.

## Workstream 2: Swamp Visual Completion

Problem to solve: the first-stage trees look unfinished.

Tasks:

- Audit current tree tiles and parallax layers.
- Replace placeholder tree chunks with finished tile compositions.
- Add foreground canopy and trunk depth where it does not block gameplay.
- Add collision only to readable trunks, roots, and terrain.
- Keep walkable foreground clear.
- Add subtle fog, depth tint, or parallax if assets support it.

Acceptance:

- Trees have trunks, canopy, roots, and readable grounding.
- No decorative tree tile looks like a floating cutout.
- Player, enemies, projectiles, and pickups remain readable in front of trees.

## Workstream 3: Core Movement

Tasks:

- Replace teleport dash feel with velocity-based dash movement.
- Add dash trail or afterimage effect.
- Add ground dash and air dash.
- Add double jump.
- Add wall hang.
- Add wall jump.
- Add slide.
- Add slide attack.
- Add dive bomb attack with enemy bounce.
- Add controller bindings for every movement action.

Acceptance:

- Dash has visible travel over time.
- Dash cannot place the player through solid collision.
- Air dash works once per airtime unless reset by landing or allowed pickup.
- Double jump works once per airtime.
- Wall hang can hold briefly and then slide or release.
- Wall jump pushes away from the wall.
- Slide attack has a hitbox and clear recovery.
- Dive bomb triggers with down plus attack in air, damages an enemy, and bounces
  the player upward on a successful hit.

## Workstream 4: Attack Clarity And Combo Basics

Problem to solve: attack input is unclear and enemies cannot be attacked
reliably.

Tasks:

- Add input glyphs or a controls hint in the first combat tutorial.
- Support keyboard, Xbox-style, PlayStation-style, and Switch-style controller
  labels through the input display layer.
- Add a three-hit starter combo for melee characters.
- Add clear projectile attack handling for Arc-Gunner.
- Add attack hitbox debug drawing in dev builds.
- Add hit sparks and enemy flash on successful hits.
- Add combo timer and combo count to HUD or combat feedback layer.
- Add cooldown and cancel windows as data.

Acceptance:

- A new player can identify attack within the first enemy room.
- Regular attacks damage standard enemies.
- Combo attacks chain in order and reset after timeout.
- Enemies show hit feedback immediately.
- Attack behavior works with keyboard and modern controllers.

## Workstream 5: Enemy Combat And AI

Problem to solve: monsters do not attack and their travel paths are weak.

Tasks:

- Add enemy patrol path nodes for milestone rooms.
- Add aggro radius and leash radius.
- Add melee attack windup, active, recovery, and cooldown states.
- Add ranged attack support where assets justify it.
- Add contact damage only when readable and fair.
- Add ledge and wall handling.
- Add stuck detection and recovery.
- Add room re-entry respawn reset.
- Add enemy test fixtures for patrol, chase, attack, and reset.

Acceptance:

- Standard enemies patrol before seeing the player.
- Enemies chase when the player enters aggro range.
- Enemies attack when in range.
- Enemies can damage the player.
- Enemies return or reset when leashed.
- Re-entering a room respawns non-persistent enemies.

## Workstream 6: Familiar Milestone

Tasks:

- Keep familiar follow behavior stable through room transitions.
- Add familiar target selection.
- Add familiar attack cooldown and hitbox/projectile.
- Add familiar XP and level state.
- Add familiar evolution state.
- Add ability upgrades.
- Save familiar level, XP, evolution, and upgrades.
- Add HUD feedback for familiar level and upgrade readiness.

Acceptance:

- Familiar follows without blocking player movement.
- Familiar attacks enemies in range.
- Familiar gains XP from enemy defeats.
- Familiar evolution changes behavior, reach, or attack effect.
- Familiar state survives save, continue, room transitions, and respawn.

## Workstream 7: Recruitment And Party

Tasks:

- Add Witch recruitment trigger at damaged shrine.
- Add Witch name input and save data fields.
- Add two-character active party state.
- Add tag swap between starter and Witch.
- Add Shadow rescue trigger in prison room.
- Add Shadow name input and save data fields.
- Expand active party to three characters.
- Add minimal party HUD with HP, resource, and Momentum rings.

Acceptance:

- Witch can be named and recruited once.
- Shadow can be named and recruited once.
- Active party order persists in save data.
- Swapping changes the controlled character without losing position, camera, or
  collision state.

## Workstream 8: Masakiro Boss

Tasks:

- Build arena bounds.
- Add boss intro trigger.
- Add phase 1 sword pattern.
- Add phase 2 commander pattern with limited adds.
- Add phase 3 oni escalation.
- Add defeat state.
- Add post-boss safe state and seal pickup unlock.
- Add checkpoint before boss.

Acceptance:

- Boss restarts cleanly from checkpoint after death.
- Adds cannot softlock the fight.
- Boss defeat saves once.
- Seal pickup appears only after boss defeat.

## Workstream 9: Sakuramori Court Shell

Tasks:

- Build entrance hub scene.
- Add Harune placeholder NPC.
- Add save shrine.
- Add party-management shrine.
- Add shop, blacksmith, inn, quest board, training room placeholders.
- Add Moonpetal Passage locked shrine.
- Add return transition to prior route or world map placeholder.

Acceptance:

- Hub loads after Rising Torii Seal pickup.
- Save shrine writes valid progress.
- Party shrine opens placeholder management UI.
- No hub placeholder blocks player movement.

## Test Plan

Headless tests:

- Scene instantiation for every milestone room.
- Save migration and load for milestone state.
- Room transition graph has no missing target.
- Player left-boundary clamp.
- Enemy respawn on room re-entry.
- Enemy attack state damages player.
- Attack hitbox damages enemy.
- Dash does not tunnel through collision.
- Double jump count resets on landing.
- Dive bomb bounces after enemy hit.
- Familiar state serializes.
- Recruitment flags serialize.
- Party active order serializes.

Manual playtests:

- Keyboard complete route.
- Xbox controller complete route.
- PlayStation controller complete route.
- Reduced-motion title and gameplay settings.
- First-time player attack readability.
- Camera and graphics fill check at supported resolutions.

## Open Questions

- Should Modern City Outskirts be built now or temporarily represented by an
  intro staging room?
- Should the Witch tutorial force a swap once or allow player-driven discovery?
- Which exact tree and swamp tiles are final for milestone one?
- Which enemy sprite becomes the standard patrol enemy?
- Should wall hang be unlimited, stamina-limited, or timer-limited?
- Should air dash reset after enemy bounce or only after landing?
