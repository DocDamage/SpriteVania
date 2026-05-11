# Balance Tuning Plan

This document collects first-pass numeric targets for movement, combat, XP,
enemy stats, familiar progression, economy, and boss tuning. Values are
starting points and must be adjusted after playtests.

## Tuning Rules

- Prefer data values over hardcoded constants.
- Tune for readability before difficulty.
- Story and Normal modes must be completable without mastery.
- Technical and Expert modes can reward precision but should not gate story.
- Record every major tuning change with playtest notes.

## Player Movement

Baseline values:

- Walk speed: 120 pixels per second.
- Run speed: 190 pixels per second.
- Ground acceleration: 1200 pixels per second squared.
- Ground deceleration: 1600 pixels per second squared.
- Air acceleration: 850 pixels per second squared.
- Air deceleration: 500 pixels per second squared.
- Jump velocity: negative 360 pixels per second.
- Double-jump velocity: negative 330 pixels per second.
- Gravity: 980 pixels per second squared.
- Max fall speed: 540 pixels per second.
- Coyote time: 0.10 seconds.
- Jump buffer: 0.12 seconds.

Dash values:

- Ground dash speed: 520 pixels per second.
- Air dash speed: 470 pixels per second.
- Dash duration: 0.16 seconds.
- Dash recovery: 0.10 seconds.
- Ground dash cooldown: 0.35 seconds.
- Air dash uses before landing: 1.

Wall values:

- Wall hang duration: 1.00 second.
- Controlled wall fall speed: 110 pixels per second.
- Wall jump horizontal push: 260 pixels per second.
- Wall jump vertical push: negative 330 pixels per second.
- Wall jump input lock: 0.10 seconds.

## Player Combat

Light combo:

- Attack 1 damage: 10.
- Attack 2 damage: 12.
- Attack 3 damage: 18.
- Attack 1 startup: 0.08 seconds.
- Attack 2 startup: 0.09 seconds.
- Attack 3 startup: 0.12 seconds.
- Combo buffer: 0.20 seconds.
- Combo reset: 0.70 seconds after recovery.

Dash strike:

- Damage: 12.
- Startup: 0.06 seconds.
- Active: 0.16 seconds.
- Recovery: 0.20 seconds.
- Best target: small ground enemies.

Dive bomb:

- Damage: 18.
- Startup: 0.08 seconds.
- Dive speed: 720 pixels per second.
- Enemy bounce velocity: negative 300 pixels per second.
- Ground recovery: 0.25 seconds.
- Enemy-hit recovery: 0.05 seconds.

Arc-Gunner first-pass ranged values:

- Shot damage: 8.
- Shot cooldown: 0.22 seconds.
- Projectile speed: 520 pixels per second.
- Reload or heat recovery: 0.60 seconds.

Iron Knight first-pass values:

- Heavy attack damage: 22.
- Guard mitigation: 60 percent.
- Guard resource drain: 12 per blocked hit.
- Movement speed modifier: 0.92.

## Momentum

Use values from [Momentum Tuning](momentum_tuning.md) as the source of truth.

First implementation should expose:

- Momentum max.
- Swap cost.
- Combo hit refund.
- Perfect-swap refund.
- Combo timer.
- Perfect-swap window.
- Tag attack cooldown.
- Bench recovery tick.

## Player Stats

Starter baseline:

- Level: 1.
- HP: 100.
- Resource: 100.
- Attack: 10.
- Defense: 0.

Level-up targets:

- HP gain per level: 8.
- Resource gain every two levels: 5.
- Attack gain per level: 1.
- Defense gain every three levels: 1.

XP curve first pass:

- Level 2: 100 XP.
- Level 3: 240 XP.
- Level 4: 420 XP.
- Level 5: 650 XP.
- Level 6: 930 XP.
- Level 7: 1260 XP.
- Level 8: 1640 XP.
- Level 9: 2070 XP.
- Level 10: 2550 XP.

Formula candidate:

- Next level XP equals 80 plus level squared times 20.

## Enemy Stats

Standard patrol enemy:

- HP: 35.
- Contact damage: 0 unless body-hazard enemy.
- Attack damage: 12.
- XP: 15.

Small crawler:

- HP: 24.
- Contact damage: 6.
- Lunge damage: 10.
- XP: 10.

Ranged guard:

- HP: 30.
- Projectile damage: 10.
- Projectile cooldown: 1.20 seconds.
- XP: 18.

Cursed samurai:

- HP: 60.
- Attack damage: 16.
- Heavy attack damage: 24.
- XP: 35.

Oni brute:

- HP: 120.
- Attack damage: 24.
- Slam damage: 32.
- XP: 70.

## Masakiro First-Pass Stats

Boss HP:

- Phase 1: 220.
- Phase 2: 260.
- Phase 3: 300.

Damage:

- Slash: 18.
- Dash slash: 24.
- Commander strike: 20.
- Oni slam: 32.

Adds:

- Maximum active adds: 2.
- Add respawn delay: 8 seconds.
- Stop add spawning below 20 percent final phase HP.

Rewards:

- XP: 250.
- Rising Torii Seal unlock.

## Familiar Progression

Familiar level targets:

- Level 2: 80 XP.
- Level 3: 200 XP.
- Level 4: 380 XP.
- Level 5: 620 XP.

Familiar attack:

- Base damage: 6.
- Attack cooldown: 1.25 seconds.
- Range: 220 pixels.
- Target switch cooldown: 0.50 seconds.

Evolution:

- First evolution target: level 3.
- Second evolution target: level 5 or milestone later.

Ability upgrades:

- Upgrade level 1: baseline ability.
- Upgrade level 2: damage or range increase.
- Upgrade level 3: behavior change or secondary effect.

## Economy

Milestone currency:

- Keep currency optional until shops are functional.
- Avoid requiring purchase for critical progression.

First-pass costs:

- Basic heal item: 25.
- Basic resource item: 30.
- Early upgrade material: 60.
- Basic weapon upgrade: 100.

Rules:

- Shops should not sell required traversal unlocks.
- Prices should be low enough to test economy without farming.
- Economy can remain placeholder in milestone one.

## Difficulty Multipliers

Story:

- Player damage taken: 0.75.
- Enemy HP: 0.85.
- Combo timer: generous.

Normal:

- Player damage taken: 1.00.
- Enemy HP: 1.00.
- Default tuning.

Technical:

- Player damage taken: 1.10.
- Enemy HP: 1.05.
- Tighter combo timer.

Expert:

- Player damage taken: 1.25.
- Enemy HP: 1.10.
- Strict combo timer.

## Playtest Questions

- Does dash feel like motion instead of teleporting?
- Can a new player identify attack before taking unfair damage?
- Does the first enemy die too quickly or too slowly?
- Does dive bomb bounce feel reliable?
- Does wall hang feel too sticky?
- Does familiar attack too often or too rarely?
- Does Masakiro last long enough to show phases without dragging?
