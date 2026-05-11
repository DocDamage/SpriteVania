# Enemy Roster Plan

This document defines the first enemy roster needed for The Black Keep
milestone and maps each enemy to gameplay purpose.

## Roster Rules

- Each enemy must teach or test a specific behavior.
- First encounters should be readable before they are difficult.
- Every standard enemy needs patrol, attack, hurt, death, and respawn behavior.
- Boss and miniboss enemies should use persistent defeat flags.
- Enemy art can be prototype if the behavior is being tested.

## Milestone Enemy Roster

Standard Patrol:

- Purpose: first basic enemy.
- Zones: Rural Swamp Road, Swamp, Castle Gate.
- Behavior: patrol, aggro, melee attack, hurt, death.
- Tutorial role: teaches attack and enemy damage.

Small Crawler:

- Purpose: low-profile enemy.
- Zones: Swamp.
- Behavior: crawl, lunge or contact damage, hurt, death.
- Tutorial role: teaches slide attack.

Ranged Watch Guard:

- Purpose: ranged pressure.
- Zones: Samurai Castle Wing.
- Behavior: aim, fire, recover, reposition or hold.
- Tutorial role: teaches approach timing and cover.

Cursed Samurai:

- Purpose: stronger melee guard.
- Zones: Samurai Castle Wing.
- Behavior: patrol, sword windup, slash, recover, stagger.
- Tutorial role: teaches heavier attack timing.

Oni Brute:

- Purpose: heavy threat and story foreshadowing.
- Zones: Samurai Castle Wing and later Oni routes.
- Behavior: slow approach, heavy windup, slam, recovery.
- Tutorial role: teaches dive bomb or tag attack openings.

Alarm Chaser:

- Purpose: pressure during Shadow rescue escape.
- Zones: Samurai Castle Wing.
- Behavior: chase, leash, short attack, reset.
- Tutorial role: tests three-character party under pressure.

Masakiro:

- Purpose: first major boss.
- Zones: Samurai Castle Wing.
- Behavior: multi-phase warlord and oni escalation.
- Tutorial role: tests combat, swaps, adds, and boss checkpoint loop.

## Enemy Stat Targets

Use [Balance Tuning Plan](balance_tuning_plan.md) as source of truth for
first-pass numbers.

Roster-specific guidance:

- Standard Patrol should die in three to five basic hits.
- Small Crawler should die quickly but threaten low space.
- Ranged Watch Guard should be interruptible.
- Cursed Samurai should survive long enough to show windup.
- Oni Brute should be slow, readable, and dangerous.
- Alarm Chaser should pressure movement more than raw damage.
- Masakiro should show all phases without becoming a long damage sponge.

## Spawn Rules

Normal enemies:

- Respawn on room re-entry.

Minibosses:

- Persist defeated after save flag.

Bosses:

- Persist defeated after boss flag.

Tutorial enemies:

- Respawn until tutorial is cleared unless the room requires otherwise.

## Enemy Placement Rules

First enemy:

- Place after attack prompt.
- No pits nearby.
- No overlapping hazards.

Crawler:

- Place in a flat or slightly low tunnel.
- Make slide attack clearly useful but not mandatory.

Ranged guard:

- Place with cover or approach route.
- Avoid offscreen first shots.

Cursed samurai:

- Place with enough space to read windup.

Oni brute:

- Place in larger room with clear retreat space.

Alarm chasers:

- Use leash limits.
- Never spawn directly on player.

## Tests

Automated tests:

- Each enemy definition loads.
- Each standard enemy can enter attack state.
- Each standard enemy can be damaged.
- Death event fires once.
- Respawn policy works.
- Boss defeat persists.

Manual tests:

- Fight each enemy with each starter.
- Verify hit readability.
- Verify enemy attack readability.
- Verify controller combat works.
- Verify reduced-motion hit feedback remains clear.
