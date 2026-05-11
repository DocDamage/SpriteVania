# Enemy AI Spec

This spec defines the first reliable enemy behavior layer for The Black Keep.
It is based on the current playtest problems: enemies need to attack, be
attackable, respawn on room re-entry, and travel along better paths.

## Goals

- Make standard enemies readable and fair.
- Let enemies patrol without walking into walls forever.
- Let enemies attack and damage the player.
- Let player attacks reliably damage enemies.
- Reset non-persistent enemies when rooms are re-entered.
- Support future boss and miniboss patterns without rewriting standard AI.

## Enemy State Machine

Standard enemy states:

- Spawn.
- Idle.
- Patrol.
- Alert.
- Chase.
- Attack windup.
- Attack active.
- Attack recovery.
- Hurt.
- Stagger.
- Leash return.
- Dead.
- Despawn.

State rules:

- Spawn initializes room-local state.
- Idle can transition to patrol after delay.
- Patrol follows path nodes.
- Alert plays a short reaction before chase.
- Chase follows player until attack range or leash limit.
- Attack windup must be visible.
- Attack active is the only damaging attack window unless contact damage is
  enabled.
- Attack recovery prevents instant repeated hits.
- Hurt interrupts most standard states.
- Stagger is optional for heavier attacks.
- Leash return moves enemy back toward path or spawn anchor.
- Dead awards XP and can notify familiar progression.

## Room Ownership

Every enemy belongs to a room instance.

Room enemy data:

- Enemy ID.
- Enemy scene.
- Spawn position.
- Spawn facing.
- Patrol path ID.
- Respawn policy.
- Persistent defeated flag, if needed.
- Drop table ID.
- XP value.

Respawn policies:

- `room_reentry`: respawn whenever the player leaves and re-enters.
- `checkpoint_reset`: respawn after respawn from checkpoint.
- `persistent_defeat`: stay defeated after save flag.
- `boss_defeat`: stay defeated after boss flag.
- `never_respawn`: scripted enemies only.

Default policy for normal milestone enemies: `room_reentry`.

## Patrol Paths

Patrol paths should be explicit nodes, not guessed movement.

Path node fields:

- Position.
- Wait time.
- Facing override.
- Jump allowed.
- Drop allowed.
- Turnaround allowed.
- Alert radius multiplier.

Path behavior:

- Enemy moves toward the next node.
- Enemy waits at node if configured.
- Enemy turns at path ends unless path loops.
- Enemy should not walk off ledges unless drop is allowed.
- Enemy should not jump unless jump is allowed.
- Enemy stuck detection should attempt reverse, return, or teleport reset only
  in dev-safe conditions.

## Sensing

Sensing values:

- Vision range.
- Vision height.
- Hearing range.
- Aggro radius.
- Attack range.
- Leash radius.
- Field-of-view angle, if used.

First-pass defaults:

- Ground melee vision range: 220 px.
- Ground melee attack range: 34 px.
- Ground melee leash radius: 360 px.
- Flying enemy vision range: 260 px.
- Ranged enemy vision range: 320 px.
- Boss leash radius: arena bounds.

Line of sight:

- Use simple ray checks for walls when practical.
- Platforms may or may not block sight depending on enemy type.
- Hidden or stealth tutorial sections can override sight rules.

## Attack Rules

Melee attack timing:

- Windup: 0.35 s.
- Active: 0.14 s.
- Recovery: 0.45 s.
- Cooldown: 0.80 s.

Contact damage:

- Disabled by default for intelligent weapon enemies.
- Enabled for body-hazard enemies only when visual design communicates it.
- Contact damage should have invulnerability cooldown.

Ranged attack timing:

- Aim/windup: 0.45 s.
- Projectile spawn at windup end.
- Recovery: 0.35 s.
- Cooldown: 1.20 s.

Attack fairness:

- Attack windup must be readable.
- Enemy cannot turn instantly during active frames unless designed for it.
- Attacks should not begin from offscreen in normal rooms.
- Projectile speed should allow reaction in tutorial rooms.

## Enemy Archetypes

Milestone standard enemy:

- Patrols between two or more nodes.
- Chases on sight.
- Uses melee windup attack.
- Respawns on room re-entry.

Small crawler:

- Lower profile.
- Slower patrol.
- Contact or short lunge attack.
- Vulnerable to slide attack.

Flying scout:

- Patrols air nodes.
- Dives or fires a simple projectile.
- Must not block required jumps unfairly.

Cursed samurai:

- Patrols Samurai Castle Wing.
- Uses sword windup.
- Can block or stagger from heavy hits in later tuning.

Oni brute:

- Slower.
- Larger attack range.
- Clear heavy windup.
- Staggerable by dive bomb or tag attack.

Ranged guard:

- Holds position or patrols small route.
- Fires after visible aim.
- Can be interrupted by fast attack.

## Samurai Castle Wing AI

Patrol guards:

- Follow fixed path nodes.
- Raise alarm on detection after alert delay.
- Do not instantly fail the rescue route.

Alarm rules:

- First alarm changes nearby guard states.
- Repeated alarms add extra guards or close an optional treasure route.
- Story route must remain completable.

Shadow prison guards:

- One guard should patrol away from prison door.
- One guard can be stationary to teach timing.
- Alarm escape shifts AI from stealth patrol to pursuit.

## Boss AI: Masakiro First Pass

Phase 1: Duel.

- Sword slash combo.
- Backstep.
- Dash slash.
- Short recovery windows.

Phase 2: Commander.

- Calls limited soldier or samurai adds.
- Uses longer arena movement.
- Adds have capped count.

Phase 3: Oni escalation.

- Adds stop or reduce.
- Masakiro gains heavier attacks.
- Arena hazards or oni visual pressure appears.

Defeat:

- Boss enters defeated state.
- Oni-consumption scene triggers.
- Defeat flag saves.
- Rising Torii Seal becomes available.

## Damage And XP Ownership

Damage source fields:

- Source type: player, familiar, enemy, hazard, boss, environment.
- Character ID, if player controlled.
- Familiar ID, if familiar.
- Attack ID.
- Damage value.
- Knockback vector.
- Stagger value.

XP rules:

- Player party gains XP from enemies defeated by player or familiar.
- Familiar gains XP from enemies it damages or helps defeat.
- Boss XP should be awarded once.
- Respawned enemies can award normal XP unless farming limits are later added.

## Tests

Automated tests:

- Enemy enters patrol from idle.
- Enemy follows path nodes.
- Enemy detects player inside aggro range.
- Enemy returns or leashes after losing player.
- Enemy attack active frame damages player.
- Player hitbox damages enemy.
- Enemy death awards XP.
- Familiar damage contributes to enemy death.
- Room re-entry respawns normal enemies.
- Persistent defeated enemies do not respawn.
- Patrol enemy does not leave allowed room bounds.

Manual playtests:

- First enemy room teaches attack clearly.
- Crawler can be hit with slide attack.
- Flying enemy does not create unfair jump blocks.
- Samurai patrols feel readable.
- Alarm escape is tense but not a softlock.
- Masakiro can be beaten with all three starters.
