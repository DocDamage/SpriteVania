# Combat And Movement Spec

This spec defines the first production pass for player actions, combo attacks,
special attacks, controller support, and traversal feel.

## Goals

- Make attack input obvious.
- Make dash feel like motion, not teleportation.
- Support modern controller layouts.
- Give every starter a clear combat identity.
- Ensure movement abilities are testable in milestone rooms.
- Keep action values data-driven so tuning does not require script rewrites.

## Input Actions

Required actions:

- Move left.
- Move right.
- Move up.
- Move down.
- Jump.
- Attack.
- Special attack.
- Dash.
- Slide or crouch.
- Swap left.
- Swap right.
- Swap direct slot 1.
- Swap direct slot 2.
- Swap direct slot 3.
- Familiar command.
- Interact.
- Pause.
- Open map.
- Open menu.

Controller support:

- Xbox-style controller labels.
- PlayStation-style controller labels.
- Switch-style controller labels.
- Generic gamepad fallback labels.
- Remapping support through settings.
- Dead-zone settings for sticks.
- Separate menu navigation and gameplay bindings.

## Movement Values

First-pass tuning targets:

- Walk speed: 120 px/s.
- Run speed: 190 px/s.
- Ground acceleration: 1200 px/s/s.
- Ground deceleration: 1600 px/s/s.
- Air acceleration: 850 px/s/s.
- Air deceleration: 500 px/s/s.
- Jump velocity: -360 px/s.
- Double-jump velocity: -330 px/s.
- Gravity: 980 px/s/s.
- Max fall speed: 540 px/s.
- Coyote time: 0.10 s.
- Jump buffer: 0.12 s.

These values are starting points only. They should be exposed as character or
movement profile data.

## Dash

Dash should move the player visibly over time.

First-pass values:

- Ground dash speed: 520 px/s.
- Air dash speed: 470 px/s.
- Dash duration: 0.16 s.
- Dash recovery: 0.10 s.
- Ground dash cooldown: 0.35 s.
- Air dash uses: 1 before landing.
- Invulnerability: none by default.
- Enemy pass-through: off by default.

Visual requirements:

- Afterimage or trail.
- Short dust burst on ground dash.
- Small air streak on air dash.
- Character remains visible during dash.

Collision requirements:

- Dash must not tunnel through solid tiles.
- Dash should stop early on wall hit.
- Dash should preserve vertical velocity only after the dash ends unless a
  character-specific profile overrides it.

## Double Jump

Rules:

- Available after initial milestone tuning room, or available from start if the
  project chooses modern baseline movement.
- One extra jump before landing.
- Resets on ground contact.
- Resets after valid wall jump.
- Optional reset on dive-bomb enemy bounce.

Feedback:

- Small burst under feet.
- Distinct sound from first jump.
- Animation or frame swap if the sprite supports it.

## Wall Hang, Wall Slide, And Wall Jump

Wall contact:

- Player must face or press toward a valid wall.
- Wall must be tagged as hangable.
- Hazard walls are not hangable unless specifically marked.

Wall hang:

- Hang duration: 1.0 s first pass.
- Hang fall speed: 0 px/s while duration remains.
- After duration, convert to wall slide.

Wall slide:

- Slide fall speed: 110 px/s.
- Player can release by pressing away.
- Player can drop by pressing down.

Wall jump:

- Horizontal push: 260 px/s away from wall.
- Vertical push: -330 px/s.
- Input lock: 0.10 s.
- Resets double jump.
- Does not reset air dash unless later approved.

## Slide And Slide Attack

Slide:

- Triggered by down plus dash, or slide action where remapped.
- Slide speed: 300 px/s.
- Duration: 0.35 s.
- Low profile can pass under narrow gaps.
- Cancels into jump after minimum 0.12 s.

Slide attack:

- Triggered by attack during slide.
- Low forward hitbox.
- Strong against small ground enemies.
- Cannot be spammed while holding slide.
- Recovery: 0.20 s.

## Dive Bomb

Input:

- Press down plus attack while airborne.

Behavior:

- Player accelerates downward.
- Dive hitbox activates after a short startup.
- On enemy hit, enemy takes damage and player bounces upward.
- On ground hit, player lands with recovery and optional small shockwave.

First-pass values:

- Startup: 0.08 s.
- Dive speed: 720 px/s.
- Enemy bounce velocity: -300 px/s.
- Ground recovery: 0.25 s.
- Enemy-hit recovery: 0.05 s.
- Damage: 1.5 times light attack.

Failure safety:

- Dive bomb must not push the player through floors.
- Dive bomb must not trap the player in enemy collision.
- Bounce should restore control quickly.

## Basic Combo System

Combo rules:

- Light attack chains up to three hits.
- Combo step advances if the next attack input lands inside the combo window.
- Combo resets after timeout, taking damage, or entering a blocked action.
- Attack cancel windows are data-driven.
- Hitstop is short and adjustable in settings.

First-pass timing:

- Attack 1 startup: 0.08 s.
- Attack 1 active: 0.08 s.
- Attack 1 recovery: 0.18 s.
- Attack 2 startup: 0.09 s.
- Attack 2 active: 0.08 s.
- Attack 2 recovery: 0.20 s.
- Attack 3 startup: 0.12 s.
- Attack 3 active: 0.12 s.
- Attack 3 recovery: 0.30 s.
- Combo input buffer: 0.20 s.
- Combo reset timer: 0.70 s after last attack recovery.

Feedback:

- Hit sparks.
- Enemy flash.
- Small camera impulse on heavy hit only.
- Damage numbers optional through settings.
- Combo count appears after second hit.

## Starter Combat Identities

The Ronin:

- Fast melee.
- Three-hit sword combo.
- Air slash.
- Slide slash.
- Dive-bomb blade drop.
- Perfect-swap bonus window slightly easier.

The Arc-Gunner:

- Ranged basic shot.
- Reload or heat resource.
- Close strike for slide attack.
- Aerial downward burst for dive bomb.
- Ground dash can have recoil styling.

The Iron Knight:

- Slower melee.
- Guard or shield bash.
- Strong slide shoulder.
- Heavy dive impact.
- More hitstop, less launch vulnerability.

The Black Witch of Ash:

- Midrange spell.
- Ash field tag attack.
- Short hover or ash-lift traversal expression.
- Dive bomb becomes falling ash seal.

The Shadow:

- Fast dagger or bow attack.
- Stealth strike.
- Rope or perch traversal expression.
- Dive bomb becomes shadow pounce.

## Special Attack Skills

Every playable character should learn at least one attack skill beyond regular
attacks.

First milestone skills:

- Starter: receives first class skill during Swamp or Castle Gate.
- Witch: Ashen Hexburst tag skill at recruitment.
- Shadow: Silent Arrowfall tag skill at rescue.

Skill requirements:

- Clear pickup or recruitment unlock.
- HUD notification.
- Save-state persistence.
- Controller-accessible input.
- Settings-accessible description.

## Hitboxes And Hurtboxes

Rules:

- Hitboxes should be authored per attack frame or timing segment.
- Hurtboxes should stay readable and consistent.
- Low-profile slide must change hurtbox only during the slide.
- Dive bomb hitbox should not activate before startup ends.
- Projectiles must belong to a source character for XP, familiar, and combo
  rules.

Dev tools:

- Toggle hitbox display.
- Toggle hurtbox display.
- Log attack state and combo step.
- Freeze action frames for attack debugging.

## Accessibility And Settings Hooks

Required hooks:

- Screen shake intensity.
- Hit flash intensity.
- Particle amount.
- Damage numbers on/off.
- Combo timing preset.
- Input remapping.
- Hold-to-repeat menu navigation.
- Reduced motion.
- Dash effect intensity.

## Tests

Automated tests:

- Attack input creates an active hitbox.
- Enemy loses HP when hitbox overlaps hurtbox.
- Combo progresses through three steps.
- Combo resets after timeout.
- Dash moves over multiple frames.
- Dash stops on collision.
- Double jump cannot exceed allowed uses.
- Air dash cannot exceed allowed uses.
- Wall jump pushes away from wall.
- Slide attack creates low hitbox.
- Dive bomb bounces on enemy hit.
- Controller actions map to gameplay actions.

Manual tests:

- Keyboard attack clarity.
- Xbox controller route.
- PlayStation controller route.
- Switch controller route if hardware is available.
- Reduced-motion combat effects.
