# Milestone Room Graph

This document defines the first milestone route as a room graph. It is meant to
prevent missing exits, invalid continue positions, softlocks, and disconnected
rooms before implementation starts.

## Graph Rules

- Every room has a stable room ID.
- Every exit has a named target room and spawn marker.
- Every one-way drop must have a recovery route or checkpoint logic.
- Every required story gate must have a save flag.
- Every room with enemies declares its respawn policy.
- Every checkpoint declares the room and spawn marker it restores.
- Debug builds should expose room bounds, exit triggers, and spawn markers.

## Save Flags

Milestone route flags:

- `new_game_started`
- `starter_selected`
- `starter_named`
- `modern_outskirts_cleared`
- `rural_road_cleared`
- `swamp_route_cleared`
- `castle_gate_reached`
- `witch_recruited`
- `tag_tutorial_cleared`
- `samurai_castle_entered`
- `shadow_recruited`
- `masakiro_defeated`
- `rising_torii_seal_unlocked`
- `sakuramori_court_reached`

Checkpoint IDs:

- `checkpoint_modern_start`
- `checkpoint_swamp`
- `checkpoint_castle_gate`
- `checkpoint_samurai_castle`
- `checkpoint_masakiro`
- `checkpoint_sakuramori_court`

## Opening Route

### ModernOutskirts_Start

Purpose:

- First controllable screen.
- Teaches movement and screen bounds.

Exits:

- Right exit to `ModernOutskirts_StreetBreak` at `spawn_left`.

Bounds:

- Left edge is blocked.
- Top and bottom bounds are camera-safe.

Enemies:

- None.

Checkpoint:

- `checkpoint_modern_start`.

Acceptance:

- Player cannot disappear off the left edge.
- Camera never reveals void outside the room.

### ModernOutskirts_StreetBreak

Purpose:

- Introduces supernatural intrusion.
- Teaches jump and interact prompt.

Exits:

- Left exit to `ModernOutskirts_Start` at `spawn_right`.
- Right exit to `ModernOutskirts_ExitRoad` at `spawn_left`.

Enemies:

- Optional passive hazard or scripted visual only.

Acceptance:

- Player can return to first room.
- Any visual intrusion does not block required movement.

### ModernOutskirts_ExitRoad

Purpose:

- Starts transition out of the real-world opening.

Exits:

- Left exit to `ModernOutskirts_StreetBreak` at `spawn_right`.
- Right exit to `RuralRoad_Approach` at `spawn_left`.

Enemies:

- One optional tutorial enemy if attack is already taught.

Acceptance:

- If enemy exists, attack prompt appears before danger.

## Rural Road Route

### RuralRoad_Approach

Purpose:

- Blends modern road assets with swamp atmosphere.

Exits:

- Left exit to `ModernOutskirts_ExitRoad` at `spawn_right`.
- Right exit to `RuralRoad_Sink` at `spawn_left`.

Enemies:

- One small patrol enemy with `room_reentry` respawn.

Acceptance:

- Patrol path does not cross the room exit trigger.

### RuralRoad_Sink

Purpose:

- Shows ground collapse or portal distortion.

Exits:

- Left exit to `RuralRoad_Approach` at `spawn_right`.
- Right exit to `RuralRoad_SwampEntry` at `spawn_left`.

Hazards:

- One low-risk sink or pit tutorial with recovery platform.

Acceptance:

- Falling cannot softlock.
- Respawn returns to safe marker in the same room or prior checkpoint.

### RuralRoad_SwampEntry

Purpose:

- Hands off to the existing swamp foundation.

Exits:

- Left exit to `RuralRoad_Sink` at `spawn_right`.
- Right exit to `Swamp_Start` at `spawn_left`.

Acceptance:

- Visual transition clearly shifts into swamp terrain.

## Swamp Route

### Swamp_Start

Purpose:

- Reuses current swamp start while fixing bounds and incomplete art.

Exits:

- Left exit to `RuralRoad_SwampEntry` at `spawn_right`.
- Right exit to `Swamp_MovementTutorial` at `spawn_left`.

Checkpoint:

- `checkpoint_swamp`.

Acceptance:

- Left transition works or is visibly blocked.
- Trees look finished and grounded.

### Swamp_MovementTutorial

Purpose:

- Teaches jump, double jump, dash, and wall interaction if available from start.

Exits:

- Left exit to `Swamp_Start` at `spawn_right`.
- Right exit to `Swamp_EnemyTutorial` at `spawn_left`.

Traversal checks:

- Basic jump.
- Double jump ledge.
- Dash gap.
- Wall hang and wall jump nook.

Acceptance:

- No required jump demands frame-perfect movement.

### Swamp_EnemyTutorial

Purpose:

- Makes attack input obvious.

Exits:

- Left exit to `Swamp_MovementTutorial` at `spawn_right`.
- Right exit to `Swamp_Checkpoint` at `spawn_left`.

Enemies:

- One standard patrol enemy.
- One small crawler if dash strike is already available.

Respawn:

- `room_reentry`.

Acceptance:

- Player can damage enemies.
- Enemies can damage player.
- Attack prompt is visible before the first enemy engagement.

### Swamp_Checkpoint

Purpose:

- Proves save, respawn, and continue.

Exits:

- Left exit to `Swamp_EnemyTutorial` at `spawn_right`.
- Right exit to `Swamp_Hazard` at `spawn_left`.

Checkpoint:

- `checkpoint_swamp`.

Acceptance:

- Save and continue restore this room correctly.

### Swamp_Hazard

Purpose:

- Teaches hazard recovery and damage.

Exits:

- Left exit to `Swamp_Checkpoint` at `spawn_right`.
- Right exit to `Swamp_Shortcut` at `spawn_left`.

Hazards:

- Spikes or swamp pit with readable collision.

Acceptance:

- Damage and respawn loop is clear.

### Swamp_Shortcut

Purpose:

- Proves persistent shortcut state.

Exits:

- Left exit to `Swamp_Hazard` at `spawn_right`.
- Right exit to `Swamp_MinibossGate` at `spawn_left`.
- Optional shortcut back to `Swamp_Checkpoint` at `spawn_shortcut`.

Flags:

- `swamp_shortcut_opened`.

Acceptance:

- Shortcut state persists through save and continue.

### Swamp_MinibossGate

Purpose:

- Existing route pressure before Castle Gate.

Exits:

- Left exit to `Swamp_Shortcut` at `spawn_right`.
- Right exit to `Swamp_CastleExit` at `spawn_left` after clear condition.

Enemies:

- Miniboss or stronger patrol group.

Respawn:

- `persistent_defeat` for miniboss.
- `room_reentry` for normal enemies.

Acceptance:

- Gate does not softlock after miniboss defeat.

### Swamp_CastleExit

Purpose:

- Ends swamp route and frames the Keep silhouette.

Exits:

- Left exit to `Swamp_MinibossGate` at `spawn_right`.
- Right exit to `CastleGate_Causeway` at `spawn_left`.

Flags:

- `swamp_route_cleared`.

Acceptance:

- Save progress marks swamp route complete.

## Castle Gate Route

### CastleGate_Causeway

Purpose:

- First true Black Keep arrival.

Exits:

- Left exit to `Swamp_CastleExit` at `spawn_right`.
- Right exit to `CastleGate_BrokenPortcullis` at `spawn_left`.

Checkpoint:

- `checkpoint_castle_gate`.

Acceptance:

- Visual identity changes from swamp to Keep.

### CastleGate_BrokenPortcullis

Purpose:

- Adds first castle enemy and gate traversal.

Exits:

- Left exit to `CastleGate_Causeway` at `spawn_right`.
- Right exit to `CastleGate_DamagedShrineApproach` at `spawn_left`.

Enemies:

- One guard or cursed crawler.

Acceptance:

- Enemy patrol path respects broken gate collision.

### CastleGate_DamagedShrineApproach

Purpose:

- Stages Witch reveal.

Exits:

- Left exit to `CastleGate_BrokenPortcullis` at `spawn_right`.
- Right exit to `CastleGate_DamagedShrine` at `spawn_left`.

Acceptance:

- No enemy can interrupt the recruitment trigger.

### CastleGate_DamagedShrine

Purpose:

- Recruits the Black Witch of Ash.

Exits:

- Left exit to `CastleGate_DamagedShrineApproach` at `spawn_right`.
- Right exit to `CastleGate_TagTutorial` at `spawn_left` after Witch joins.

Flags:

- `witch_recruited`.

Acceptance:

- Witch naming saves.
- Re-entering the room does not repeat recruitment.

### CastleGate_TagTutorial

Purpose:

- Teaches two-character tag swap.

Exits:

- Left exit to `CastleGate_DamagedShrine` at `spawn_right`.
- Right exit to `SamuraiCastle_OuterWall` at `spawn_left` after tutorial clear.

Enemies:

- Low-risk group with enough HP to show a tag attack.

Flags:

- `tag_tutorial_cleared`.

Acceptance:

- Tutorial can be completed even if the player ignores prompts for a while.

## Samurai Castle Route

### SamuraiCastle_OuterWall

Purpose:

- Establishes Feudal Japan dungeon identity.

Exits:

- Left exit to `CastleGate_TagTutorial` at `spawn_right`.
- Right exit to `SamuraiCastle_PatrolHall` at `spawn_left`.

Checkpoint:

- `checkpoint_samurai_castle`.

Enemies:

- Cursed samurai patrol.

Acceptance:

- Patrol is readable and attackable.

### SamuraiCastle_PatrolHall

Purpose:

- Introduces stealth patrol timing.

Exits:

- Left exit to `SamuraiCastle_OuterWall` at `spawn_right`.
- Right exit to `SamuraiCastle_Watchpost` at `spawn_left`.

Stealth:

- One patrol path.
- Optional treasure if no alarm.

Acceptance:

- Detection causes pressure, not instant failure.

### SamuraiCastle_Watchpost

Purpose:

- Adds ranged or elevated guard pressure.

Exits:

- Left exit to `SamuraiCastle_PatrolHall` at `spawn_right`.
- Right exit to `SamuraiCastle_PrisonApproach` at `spawn_left`.

Enemies:

- Ranged guard or watch samurai.

Acceptance:

- Projectile or alert behavior is fair from screen entry.

### SamuraiCastle_PrisonApproach

Purpose:

- Builds toward Shadow rescue.

Exits:

- Left exit to `SamuraiCastle_Watchpost` at `spawn_right`.
- Right exit to `SamuraiCastle_ShadowPrison` at `spawn_left`.

Enemies:

- Two guards with staggered patrol paths.

Acceptance:

- Player can fight through if stealth fails.

### SamuraiCastle_ShadowPrison

Purpose:

- Recruits The Shadow.

Exits:

- Left exit to `SamuraiCastle_PrisonApproach` at `spawn_right`.
- Right exit to `SamuraiCastle_AlarmEscape` at `spawn_left` after rescue.

Flags:

- `shadow_recruited`.

Acceptance:

- Shadow naming saves.
- Active party expands to three.
- Re-entering does not repeat rescue.

### SamuraiCastle_AlarmEscape

Purpose:

- Tests three-character party under pressure.

Exits:

- Left exit to `SamuraiCastle_ShadowPrison` at `spawn_right`.
- Right exit to `SamuraiCastle_BossAntechamber` at `spawn_left`.

Enemies:

- Chasing guards with leash limits.

Acceptance:

- Escape remains possible after multiple alarms.

### SamuraiCastle_BossAntechamber

Purpose:

- Checkpoint, recovery, and boss setup.

Exits:

- Left exit to `SamuraiCastle_AlarmEscape` at `spawn_right`.
- Right exit to `SamuraiCastle_MasakiroArena` at `spawn_left`.

Checkpoint:

- `checkpoint_masakiro`.

Acceptance:

- Player can save before boss.
- Boss entry cannot trigger from the wrong side.

### SamuraiCastle_MasakiroArena

Purpose:

- First major boss.

Exits:

- Left exit locked during fight.
- Right exit to `SamuraiCastle_RisingToriiSeal` at `spawn_left` after boss
  defeat.

Flags:

- `masakiro_defeated`.

Respawn:

- `boss_defeat`.

Acceptance:

- Boss defeat persists.
- Death restarts from boss checkpoint.

### SamuraiCastle_RisingToriiSeal

Purpose:

- Grants first traversal seal.

Exits:

- Left exit to `SamuraiCastle_MasakiroArena` at `spawn_right`.
- Right exit to `SamuraiCastle_AscentTest` at `spawn_left` after pickup.

Flags:

- `rising_torii_seal_unlocked`.

Acceptance:

- Pickup cannot be collected twice.
- Vertical ascent unlock is saved.

### SamuraiCastle_AscentTest

Purpose:

- Verifies vertical ascent after the seal.

Exits:

- Left exit to `SamuraiCastle_RisingToriiSeal` at `spawn_right`.
- Top/right exit to `SakuramoriCourt_Entrance` at `spawn_left`.

Traversal:

- Vertical ascent path.
- Safe fall route.

Acceptance:

- Every active character can clear the ascent with their seal expression.

## Sakuramori Court

### SakuramoriCourt_Entrance

Purpose:

- First hub arrival and milestone endpoint.

Exits:

- Left exit to `SamuraiCastle_AscentTest` at `spawn_hub_exit`.
- Right exit to `SakuramoriCourt_SaveShrine` at `spawn_left`.
- Interior exit to `SakuramoriCourt_PartyShrine` at `spawn_entrance`.

Flags:

- `sakuramori_court_reached`.

Checkpoint:

- `checkpoint_sakuramori_court`.

Acceptance:

- Continue after reaching hub loads safely into hub.

### SakuramoriCourt_SaveShrine

Purpose:

- Manual save, healing, and recovery.

Exits:

- Left exit to `SakuramoriCourt_Entrance` at `spawn_right`.

Acceptance:

- Manual save preserves party, familiar, seal, and hub progress.

### SakuramoriCourt_PartyShrine

Purpose:

- Placeholder party management.

Exits:

- Exit to `SakuramoriCourt_Entrance` at `spawn_party_exit`.

Acceptance:

- Opens placeholder party management without breaking control on close.

## Transition Test Matrix

Each adjacent room pair should be tested both directions unless story locked:

- ModernOutskirts_Start to ModernOutskirts_StreetBreak.
- ModernOutskirts_StreetBreak to ModernOutskirts_ExitRoad.
- ModernOutskirts_ExitRoad to RuralRoad_Approach.
- RuralRoad_Approach to RuralRoad_Sink.
- RuralRoad_Sink to RuralRoad_SwampEntry.
- RuralRoad_SwampEntry to Swamp_Start.
- Swamp_Start to Swamp_MovementTutorial.
- Swamp_MovementTutorial to Swamp_EnemyTutorial.
- Swamp_EnemyTutorial to Swamp_Checkpoint.
- Swamp_Checkpoint to Swamp_Hazard.
- Swamp_Hazard to Swamp_Shortcut.
- Swamp_Shortcut to Swamp_MinibossGate.
- Swamp_MinibossGate to Swamp_CastleExit.
- Swamp_CastleExit to CastleGate_Causeway.
- CastleGate_Causeway to CastleGate_BrokenPortcullis.
- CastleGate_BrokenPortcullis to CastleGate_DamagedShrineApproach.
- CastleGate_DamagedShrineApproach to CastleGate_DamagedShrine.
- CastleGate_DamagedShrine to CastleGate_TagTutorial.
- CastleGate_TagTutorial to SamuraiCastle_OuterWall.
- SamuraiCastle_OuterWall to SamuraiCastle_PatrolHall.
- SamuraiCastle_PatrolHall to SamuraiCastle_Watchpost.
- SamuraiCastle_Watchpost to SamuraiCastle_PrisonApproach.
- SamuraiCastle_PrisonApproach to SamuraiCastle_ShadowPrison.
- SamuraiCastle_ShadowPrison to SamuraiCastle_AlarmEscape.
- SamuraiCastle_AlarmEscape to SamuraiCastle_BossAntechamber.
- SamuraiCastle_BossAntechamber to SamuraiCastle_MasakiroArena.
- SamuraiCastle_MasakiroArena to SamuraiCastle_RisingToriiSeal.
- SamuraiCastle_RisingToriiSeal to SamuraiCastle_AscentTest.
- SamuraiCastle_AscentTest to SakuramoriCourt_Entrance.
