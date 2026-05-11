# First Milestone Room Layouts

This document adds layout-level production detail to the milestone room graph.
Room dimensions and coordinates are first-pass targets and should be adjusted in
Godot after collision and camera tests.

## Layout Rules

- Every room needs camera bounds.
- Every exit needs a spawn marker.
- Every combat room needs enemy spawn markers.
- Every tutorial room needs a safe reset path.
- Every hazard room needs a recovery marker.
- Every required traversal challenge must be possible with all available active
  characters.
- Prototype layouts can use blockout tiles before final art is placed.

## Coordinate Assumptions

First-pass blockout assumptions:

- Base tile size: 16 pixels.
- Target viewport: 1280 by 720.
- Small room width: 1280 pixels.
- Medium room width: 1920 pixels.
- Large room width: 2560 pixels.
- Standard floor Y: 560 pixels.
- Spawn markers should leave at least 96 pixels from room edge.

If the current project uses different tile scale or camera zoom, keep the room
intent and adapt the values.

## ModernOutskirts_Start

Size:

- 1280 by 720.

Layout:

- Solid left wall or visible road barrier.
- Flat street floor.
- One low curb or small hop tutorial.
- Right exit at street end.

Markers:

- `spawn_start`
- `spawn_right_return`
- `exit_right`

Camera:

- Clamp to room bounds.

Acceptance:

- Holding left cannot move the player offscreen.
- First spawn is clear of collision.

## ModernOutskirts_StreetBreak

Size:

- 1920 by 720.

Layout:

- Street continuation.
- Background building silhouettes.
- First supernatural crack or portal distortion in midground.
- One jumpable obstacle.
- Optional interactable sign or warning prop.

Markers:

- `spawn_left`
- `spawn_right`
- `exit_left`
- `exit_right`

Acceptance:

- Jump tutorial obstacle is optional or recoverable.
- Portal distortion is visual only and cannot trap the player.

## ModernOutskirts_ExitRoad

Size:

- 1920 by 720.

Layout:

- Road slopes or visually transitions into overgrown roadside.
- First enemy tutorial can be placed here if attack prompt is ready.
- Otherwise keep enemy out and teach attack in Swamp.

Markers:

- `spawn_left`
- `spawn_right`
- `enemy_tutorial_spawn`
- `exit_left`
- `exit_right`

Acceptance:

- If enemy is present, attack prompt appears before enemy aggro range.

## RuralRoad_Approach

Size:

- 1920 by 720.

Layout:

- Broken road pieces.
- Grass and mud edges.
- Distant Keep silhouette.
- One patrol enemy on flat route.

Markers:

- `spawn_left`
- `spawn_right`
- `enemy_patrol_01`
- `patrol_a`
- `patrol_b`
- `exit_left`
- `exit_right`

Acceptance:

- Patrol path avoids exit triggers.
- Enemy can be skipped or defeated.

## RuralRoad_Sink

Size:

- 1920 by 720.

Layout:

- Ground collapse or swamp sink.
- Pit with safe recovery platform.
- Low hazard damage or teleport-back recovery.

Markers:

- `spawn_left`
- `spawn_right`
- `hazard_recovery`
- `exit_left`
- `exit_right`

Acceptance:

- Falling cannot softlock.
- Recovery marker is visible or intuitive.

## RuralRoad_SwampEntry

Size:

- 1280 by 720.

Layout:

- Road disappears into swamp.
- Trees begin framing the route.
- No combat required.

Markers:

- `spawn_left`
- `spawn_right`
- `exit_left`
- `exit_right`

Acceptance:

- Visual handoff to Swamp is clear.

## Swamp_Start

Size:

- 1280 by 720.

Layout:

- Finished trees on background and foreground.
- Solid left transition or blocker.
- Clear ground line.
- No enemy at immediate spawn.

Markers:

- `spawn_left`
- `spawn_start`
- `spawn_right_return`
- `exit_left`
- `exit_right`
- `checkpoint_swamp`

Acceptance:

- Trees look grounded.
- Camera does not show void.

## Swamp_MovementTutorial

Size:

- 2560 by 960.

Layout:

- Low jump ledge.
- Double-jump ledge.
- Dash gap with safe bottom.
- Wall hang and wall jump nook.
- Optional slide tunnel if slide is available.

Markers:

- `spawn_left`
- `spawn_right`
- `fall_recovery`
- `exit_left`
- `exit_right`

Acceptance:

- No movement challenge requires frame-perfect input.
- Failing a challenge loops back safely.

## Swamp_EnemyTutorial

Size:

- 1920 by 720.

Layout:

- Attack prompt before first enemy.
- One standard patrol enemy.
- One optional crawler if slide attack is ready.
- Flat combat lane with no pits.

Markers:

- `spawn_left`
- `spawn_right`
- `enemy_patrol_01`
- `enemy_crawler_01`
- `patrol_a`
- `patrol_b`
- `exit_left`
- `exit_right`

Acceptance:

- Player can damage enemy.
- Enemy can damage player.
- Room re-entry respawns standard enemy.

## Swamp_Checkpoint

Size:

- 1280 by 720.

Layout:

- Safe shrine or checkpoint.
- No hostile enemy aggro at spawn.
- Clear route forward.

Markers:

- `spawn_left`
- `spawn_right`
- `checkpoint_swamp`
- `exit_left`
- `exit_right`

Acceptance:

- Save and continue restore to valid marker.

## Swamp_Hazard

Size:

- 1920 by 720.

Layout:

- Readable spikes, swamp pit, or toxic pool.
- Safe platform after hazard.
- Recovery marker before hazard.

Markers:

- `spawn_left`
- `spawn_right`
- `hazard_recovery`
- `exit_left`
- `exit_right`

Acceptance:

- Hazard damage is readable.
- Recovery does not place player back into damage.

## Swamp_Shortcut

Size:

- 1920 by 960.

Layout:

- Main route across mid-height platform.
- Shortcut door or bridge back to checkpoint route.
- One enemy or hazard guarding shortcut switch.

Markers:

- `spawn_left`
- `spawn_right`
- `spawn_shortcut`
- `shortcut_switch`
- `exit_left`
- `exit_right`
- `exit_shortcut`

Acceptance:

- Shortcut opens persistently.
- Save/load preserves shortcut state.

## Swamp_MinibossGate

Size:

- 1920 by 720.

Layout:

- Gate arena.
- Miniboss or stronger enemy.
- Exit locked until clear.

Markers:

- `spawn_left`
- `spawn_right`
- `miniboss_spawn`
- `gate_lock`
- `exit_left`
- `exit_right`

Acceptance:

- Defeat unlocks exit.
- Defeat persists.

## Swamp_CastleExit

Size:

- 1280 by 720.

Layout:

- Swamp foreground thins.
- Distant Keep or castle gate appears.
- Exit to Castle Gate.

Markers:

- `spawn_left`
- `spawn_right`
- `exit_left`
- `exit_right`

Acceptance:

- Route completion flag sets before Castle Gate.

## CastleGate_Causeway

Size:

- 1920 by 720.

Layout:

- Stone bridge or causeway.
- Castle silhouette.
- Checkpoint near safe entry.

Markers:

- `spawn_left`
- `spawn_right`
- `checkpoint_castle_gate`
- `exit_left`
- `exit_right`

Acceptance:

- First Black Keep arrival reads clearly.

## CastleGate_BrokenPortcullis

Size:

- 1920 by 720.

Layout:

- Broken gate.
- One guard enemy.
- Overhead portcullis decoration.
- Collision matches broken gate.

Markers:

- `spawn_left`
- `spawn_right`
- `enemy_guard_01`
- `patrol_a`
- `patrol_b`
- `exit_left`
- `exit_right`

Acceptance:

- Enemy path does not clip into gate collision.

## CastleGate_DamagedShrineApproach

Size:

- 1280 by 720.

Layout:

- Quiet approach.
- Shrine visible at right edge.
- No enemy aggro.

Markers:

- `spawn_left`
- `spawn_right`
- `exit_left`
- `exit_right`

Acceptance:

- Player reaches recruitment room without interruption.

## CastleGate_DamagedShrine

Size:

- 1280 by 720.

Layout:

- Damaged shrine at center-right.
- Witch reveal marker.
- Interaction point.
- Exit forward locked until recruitment completes.

Markers:

- `spawn_left`
- `spawn_right`
- `witch_spawn`
- `shrine_interact`
- `exit_left`
- `exit_right`

Acceptance:

- Witch recruitment cannot repeat.
- Witch name prompt saves correctly.

## CastleGate_TagTutorial

Size:

- 1920 by 720.

Layout:

- Safe combat lane.
- Two low-risk enemies.
- Swap prompt trigger.
- Exit locked until tutorial clear or fail-safe timeout.

Markers:

- `spawn_left`
- `spawn_right`
- `enemy_tutorial_01`
- `enemy_tutorial_02`
- `swap_prompt`
- `exit_left`
- `exit_right`

Acceptance:

- Player can complete tutorial without softlock.

## SamuraiCastle_OuterWall

Size:

- 1920 by 960.

Layout:

- Outer wall platforms.
- One cursed samurai patrol.
- Vertical movement hint.

Markers:

- `spawn_left`
- `spawn_right`
- `enemy_samurai_01`
- `patrol_a`
- `patrol_b`
- `checkpoint_samurai_castle`
- `exit_left`
- `exit_right`

Acceptance:

- Zone identity is clear.

## SamuraiCastle_PatrolHall

Size:

- 2560 by 720.

Layout:

- Long patrol hall.
- One guard path.
- Optional upper treasure path.

Markers:

- `spawn_left`
- `spawn_right`
- `guard_01`
- `patrol_a`
- `patrol_b`
- `treasure_optional`
- `exit_left`
- `exit_right`

Acceptance:

- Full alarm changes pressure, not story completion.

## SamuraiCastle_Watchpost

Size:

- 1920 by 960.

Layout:

- Elevated watch guard.
- Lower path with cover.
- Optional upper route.

Markers:

- `spawn_left`
- `spawn_right`
- `watch_guard_01`
- `cover_01`
- `cover_02`
- `exit_left`
- `exit_right`

Acceptance:

- Player can approach or defeat watch guard.

## SamuraiCastle_PrisonApproach

Size:

- 2560 by 720.

Layout:

- Two staggered patrols.
- Prison door visible near end.
- Optional locked storage.

Markers:

- `spawn_left`
- `spawn_right`
- `guard_01`
- `guard_02`
- `patrol_01_a`
- `patrol_01_b`
- `patrol_02_a`
- `patrol_02_b`
- `exit_left`
- `exit_right`

Acceptance:

- Fighting through failed stealth remains possible.

## SamuraiCastle_ShadowPrison

Size:

- 1280 by 720.

Layout:

- Prison cell.
- Shadow staging point.
- Rescue interaction.
- Forward exit locked until rescue.

Markers:

- `spawn_left`
- `spawn_right`
- `shadow_spawn`
- `rescue_interact`
- `exit_left`
- `exit_right`

Acceptance:

- Shadow joins once.
- Active party expands to three.

## SamuraiCastle_AlarmEscape

Size:

- 2560 by 960.

Layout:

- Chase lane.
- Two combat pockets.
- One vertical escape segment.
- Safe gate at end.

Markers:

- `spawn_left`
- `spawn_right`
- `chaser_01`
- `chaser_02`
- `combat_pocket_01`
- `combat_pocket_02`
- `exit_left`
- `exit_right`

Acceptance:

- Escape can be completed after repeated alarms.

## SamuraiCastle_BossAntechamber

Size:

- 1280 by 720.

Layout:

- Save/checkpoint shrine.
- Boss door.
- Optional heal.

Markers:

- `spawn_left`
- `spawn_right`
- `checkpoint_masakiro`
- `boss_door`
- `exit_left`
- `exit_right`

Acceptance:

- Death during boss reloads here.

## SamuraiCastle_MasakiroArena

Size:

- 1920 by 720.

Layout:

- Wide flat arena.
- Soft walls during fight.
- Add spawn markers.
- Boss center spawn.

Markers:

- `spawn_left`
- `spawn_post_boss`
- `boss_masakiro`
- `add_spawn_left`
- `add_spawn_right`
- `arena_lock_left`
- `arena_lock_right`
- `exit_right`

Acceptance:

- Boss can be fought without camera clipping.
- Defeat unlocks right exit.

## SamuraiCastle_RisingToriiSeal

Size:

- 1280 by 720.

Layout:

- Safe seal chamber.
- Seal pickup at center.
- Exit forward locked until pickup.

Markers:

- `spawn_left`
- `spawn_right`
- `seal_pickup`
- `exit_left`
- `exit_right`

Acceptance:

- Seal pickup saves.

## SamuraiCastle_AscentTest

Size:

- 1280 by 1200.

Layout:

- Vertical shaft.
- Platforms spaced for Rising Torii Seal.
- Safe fall recovery.
- Exit at top or upper-right.

Markers:

- `spawn_bottom`
- `spawn_left`
- `spawn_top_return`
- `fall_recovery`
- `exit_left`
- `exit_top`

Acceptance:

- All active characters clear ascent.

## SakuramoriCourt_Entrance

Size:

- 1920 by 720.

Layout:

- Arrival gate.
- Harune staging point.
- Paths to save shrine and party shrine.
- Locked Market Walk and Moonpetal Passage hints.

Markers:

- `spawn_left`
- `spawn_hub_entry`
- `harune_spawn`
- `exit_save_shrine`
- `exit_party_shrine`
- `exit_training_yard`

Acceptance:

- Hub checkpoint sets on first arrival.

## SakuramoriCourt_SaveShrine

Size:

- 1280 by 720.

Layout:

- Save shrine.
- Healing area.
- Clear return path.

Markers:

- `spawn_left`
- `save_shrine`
- `exit_left`

Acceptance:

- Manual save restores hub state.

## SakuramoriCourt_PartyShrine

Size:

- 1280 by 720.

Layout:

- Party shrine.
- UI interaction point.
- Return path.

Markers:

- `spawn_entrance`
- `party_shrine`
- `exit_entrance`

Acceptance:

- Party UI opens and closes safely.

## SakuramoriCourt_TrainingYard

Size:

- 1920 by 960.

Layout:

- Training dummy.
- Small wall-jump test.
- Dash lane.
- Dive-bomb target.
- Vertical ascent practice if seal is unlocked.

Markers:

- `spawn_left`
- `training_dummy`
- `dash_lane_start`
- `wall_test`
- `dive_target`
- `ascent_test`
- `exit_left`

Acceptance:

- Player can practice core movement and combat without death pressure.
