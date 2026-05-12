# Momentum Tuning

Momentum is the core swap resource. These numbers are first-pass planning targets and should be tuned after prototype playtests.

## Goals

- Encourage swapping during combos.
- Prevent constant free swapping without engagement.
- Reward clean combo timing.
- Keep Story mode accessible.
- Make Expert mode rewarding without becoming mandatory.

## First-Pass Values

| Value | Story | Normal | Technical | Expert |
|---|---:|---:|---:|---:|
| Momentum max | 100 | 100 | 100 | 100 |
| Swap cost | 20 | 25 | 30 | 35 |
| Combo hit refund | 8 | 6 | 5 | 4 |
| Perfect-swap refund | 25 | 25 | 30 | 35 |
| Combo timer | 2.0s | 1.5s | 1.1s | 0.85s |
| Perfect-swap window | 0.35s | 0.25s | 0.18s | 0.12s |
| Tag attack cooldown | 5.0s | 6.0s | 6.5s | 7.0s |
| Bench recovery tick | 2 HP/s | 1.5 HP/s | 1 HP/s | 0.75 HP/s |

## Momentum Sources

- Combo hit refunds.
- Perfect-swap refunds.
- Enemy defeat bonus.
- Boss phase break bonus.
- Specific skills or equipment.
- Hub training upgrades, if later approved.

## Momentum Sinks

- Character swap.
- Certain high-power tag attacks.
- Emergency recovery actions, if later approved.

## KO Auto-Switch Behavior

First-pass behavior:

- Auto-switch costs no Momentum if the active character is KO'd.
- Incoming character does not perform a full tag attack on KO auto-switch.
- Incoming character gets brief invulnerability.
- If no active character survives, trigger death/respawn.

## Tag Attack Cooldowns

First-pass policy:

- Cooldown is per character, not global.
- Cooldown starts when the tag attack begins.
- Swapping can still happen if tag attack is on cooldown, but the entry attack becomes a simple entry movement or quick strike.

## Difficulty Intent

Story:

- Lets players swap often.
- Keeps combo timer generous.
- Perfect-swap mastery is optional.

Normal:

- Default intended feel.
- Swapping is available often if the player keeps pressure.

Technical:

- Shorter combo windows.
- Larger perfect-swap reward.
- Better for players who want mastery.

Expert:

- Strict timing.
- Highest reward for perfect play.
- Should not unlock unique story content.

## Locked Decisions

- Momentum max starts at 100.
- Momentum is individual per character.
- Swap costs Momentum except KO auto-switch.
- Combo timing presets live in settings.

## Open Questions

- Whether Momentum carries between rooms.
- Whether Momentum resets on checkpoint respawn.
- Whether bosses have separate refund rules.
- Whether defensive actions can generate Momentum.
- Whether perfect dodge/parry exists and feeds Momentum.

## Implementation Notes

- Expose all values as data, not hardcoded constants.
- Tests should verify swap cost, refunds, cooldowns, KO auto-switch, and preset values.
- UI needs a readable ring state for full, partial, insufficient, and perfect-swap states.

