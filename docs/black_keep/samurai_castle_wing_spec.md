# Samurai Castle Wing Spec

The Samurai Castle Wing is the first major identity dungeon and the first full
proof of the Feudal Japan time-fragment direction.

## Goals

- Deliver the first major dungeon after Castle Gate.
- Introduce patrol stealth without creating hard fail states.
- Recruit The Shadow.
- Prove three-character party combat under pressure.
- Stage Lord Masakiro as the first major boss.
- Award the Rising Torii Seal.
- Route the player into Sakuramori Court.

## Stable IDs

Zone ID:

- `samurai_castle_wing`

Rooms:

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

Story flags:

- `samurai_castle_entered`
- `samurai_alarm_triggered`
- `samurai_perfect_stealth_failed`
- `shadow_recruited`
- `samurai_alarm_escape_cleared`
- `masakiro_defeated`
- `rising_torii_seal_unlocked`

Checkpoint IDs:

- `checkpoint_samurai_castle`
- `checkpoint_masakiro`

## Enemy Factions

Human soldiers:

- Basic patrol guards.
- Alarm callers.
- Ranged watch guards.
- Best used in Patrol Hall, Watchpost, Prison Approach, and Alarm Escape.

Cursed samurai:

- Stronger guard units.
- Slower, heavier attacks.
- Better armor and stagger resistance.
- Best used in Watchpost, Boss Antechamber, and Masakiro adds.

Oni forces:

- Rare early visual threat.
- Used as background pressure or phase escalation.
- Should imply Masakiro is being manipulated.

## Room Flow

1. `SamuraiCastle_OuterWall`
2. `SamuraiCastle_PatrolHall`
3. `SamuraiCastle_Watchpost`
4. `SamuraiCastle_PrisonApproach`
5. `SamuraiCastle_ShadowPrison`
6. `SamuraiCastle_AlarmEscape`
7. `SamuraiCastle_BossAntechamber`
8. `SamuraiCastle_MasakiroArena`
9. `SamuraiCastle_RisingToriiSeal`
10. `SamuraiCastle_AscentTest`
11. `SakuramoriCourt_Entrance`

Optional routes can be added later:

- Treasure rafters.
- Oni eavesdrop room.
- Prison storage.
- Hidden lore alcove.

## Room Details

### Outer Wall

Purpose:

- Establish dungeon identity.
- Teach castle patrol enemy.

Gameplay:

- One cursed samurai or soldier patrol.
- Simple ledge or wall movement check.
- No stealth failure yet.

Acceptance:

- Player understands this is a new major zone.
- Enemy is attackable and can attack the player.

### Patrol Hall

Purpose:

- Teach stealth timing.

Gameplay:

- One visible patrol route.
- Warning state before full alarm.
- Optional chest if no alarm.

Acceptance:

- Detection is recoverable.
- Perfect stealth can be tracked without blocking story progress.

### Watchpost

Purpose:

- Introduce elevated or ranged pressure.

Gameplay:

- Watch guard on platform.
- Ranged shot or alarm cone.
- Alternate high path if movement supports it.

Acceptance:

- Player is not hit from offscreen without warning.
- Watch guard can be reached or defeated.

### Prison Approach

Purpose:

- Increase pressure before Shadow rescue.

Gameplay:

- Two staggered patrols.
- One optional shortcut or locked side door.
- Alarm can increase guard count but cannot softlock the player.

Acceptance:

- Fighting through failed stealth remains possible.

### Shadow Prison

Purpose:

- Recruit The Shadow.

Gameplay:

- Rescue interaction.
- Name input.
- Party roster update.
- Shadow tag attack introduction.
- Alarm escape trigger.

Acceptance:

- Shadow recruitment happens once.
- Shadow name saves.
- Active party expands to three.

### Alarm Escape

Purpose:

- Prove three-character party under moving pressure.

Gameplay:

- Chasing guards with leash limits.
- Doors or gates that close behind the player only if safe.
- Short combat pocket where Shadow can be tested.

Acceptance:

- Escape does not become a softlock.
- Three-character swap works under pressure.

### Boss Antechamber

Purpose:

- Recovery, checkpoint, and boss setup.

Gameplay:

- Save/checkpoint.
- Optional shopless heal or shrine.
- Boss door.

Acceptance:

- Death during boss reloads here.
- Boss trigger cannot accidentally fire before entering arena.

### Masakiro Arena

Purpose:

- First major boss.

Gameplay:

- Multi-phase boss.
- Limited adds.
- Arena locks during fight.
- Defeat triggers oni-consumption scene.

Acceptance:

- Boss can be defeated with each starter path.
- Defeat flag saves.
- Arena unlocks after defeat.

### Rising Torii Seal

Purpose:

- Award vertical ascent traversal.

Gameplay:

- Seal pickup.
- Unlock notification.
- Save flag.

Acceptance:

- Seal cannot be collected twice.
- Vertical ascent unlock persists.

### Ascent Test

Purpose:

- Verify seal reward.

Gameplay:

- Safe vertical ascent route.
- Character-specific traversal expression hook.
- Exit to Sakuramori Court.

Acceptance:

- Every current active character can clear the ascent.

## Stealth System

Alarm states:

- `none`
- `warning`
- `alarm`
- `lockdown`

Detection sequence:

1. Player enters vision or sound trigger.
2. Guard enters warning.
3. Warning indicator appears.
4. If player remains detected, alarm triggers.
5. Nearby guards switch to alert or chase.

Recovery:

- Player can leave sight to clear warning.
- Alarm can decay after room clear or remain tracked for rewards.
- Lockdown should only happen in specific scripted rooms.

Perfect stealth failure:

- Any full alarm sets `samurai_perfect_stealth_failed`.
- Warning without alarm does not fail perfect stealth unless later tuned.

## Alarm Outcomes

Perfect:

- No full alarms.
- Best optional reward later.
- Unique Shadow reaction later.

Clean:

- One alarm.
- Normal reward.

Rough:

- Multiple alarms.
- Harder fights.
- Reduced optional treasure.

Forced combat:

- Repeated detection.
- Miniboss guard may appear in later pass.

Story minimum:

- Rescue still succeeds.
- No softlock.

## Shadow Recruitment

Requirements:

- Prison cell or restraint staging.
- Rescue interaction.
- Player naming prompt.
- Party roster update.
- Active slot 3 fill.
- Shadow tag attack intro.
- Save after recruitment.

Do not write final dialogue in this spec.

## Shadow First Combat

Shadow tutorial target:

- One weakened guard or training dummy during alarm escape.
- Silent Arrowfall tag attack prompt.
- Short route that allows Shadow movement read.

Acceptance:

- Player sees Shadow's combat identity before boss.

## Masakiro Boss

Phase 1: Disciplined warlord.

- Sword slash.
- Dash slash.
- Backstep.
- Short punish windows.

Phase 2: Commander.

- Calls limited soldier or cursed samurai adds.
- Uses longer movement pattern.
- Add count is capped.

Phase 3: Oni blessing.

- Heavier attack.
- Oni visual overlay.
- More dangerous but still readable.
- Masakiro appears to lose control.

Defeat:

- Masakiro defeated.
- Oni consume him.
- Boss flag saves.
- Rising Torii Seal room unlocks.

## Oni-Consumption Scene

Purpose:

- Shows Masakiro was not truly in control.
- Foreshadows the Oni-Worn Lord rematch.
- Confirms the oni are older and deeper than The Black Keep's surface politics.

Implementation:

- Keep it short for milestone one.
- Can use animation, VFX, or staged sprites.
- Should not require final dialogue.
- Must set boss defeated flag before or during safe scene completion.

## Rewards

Required:

- Rising Torii Seal.
- Access to Sakuramori Court.
- Boss XP.

Optional later:

- Perfect stealth charm.
- Riftbow Carbine mod.
- Oni lore note.
- Shadow affinity bonus.
- Rare crafting material.

## Tests

Automated tests:

- Every Samurai Castle room instantiates.
- All room exits target valid rooms.
- Alarm warning can transition to alarm.
- Perfect stealth flag fails on full alarm.
- Shadow recruitment updates party state.
- Shadow name saves.
- Alarm escape remains reachable after rescue.
- Masakiro defeat sets flag.
- Rising Torii Seal pickup sets unlock flag.
- Ascent test requires or checks vertical ascent unlock.

Manual tests:

- Enter dungeon from Castle Gate.
- Trigger and avoid alarm.
- Rescue Shadow.
- Use three-character party in escape.
- Defeat Masakiro.
- Collect seal.
- Reach Sakuramori Court.

## Locked Decisions

- The Shadow is recruited in this dungeon.
- Masakiro is the first major boss.
- Oni consume Masakiro after defeat.
- Rising Torii Seal unlocks vertical ascent.
- Dungeon exits to Sakuramori Court.

## Open Questions

- Exact enemy asset selections.
- Whether stealth uses line of sight, sound, light/dark, or simplified trigger
  zones.
- Whether perfect stealth rewards are mechanical in first milestone or tracked
  for later.
- Whether Shadow is playable immediately during alarm escape or after a short
  tag tutorial.
- Whether Masakiro's oni phase uses an overlay or separate sprite.

## Implementation Notes

- Track stealth result separately from room completion.
- Keep boss arena separate from stealth state to avoid broken boss starts.
- Save after Shadow recruitment and after Masakiro defeat.
- Keep optional stealth rewards data-driven even if rewards are deferred.
