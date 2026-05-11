# Asset Audit Results

This document will hold the production asset audit. It should be filled from real repository assets, not assumptions. The immediate goal is to identify usable playable characters, enemies, bosses, NPCs, tiles, VFX, UI assets, and parallax/background material for the first Black Keep milestone and the wider game.

## Audit Status

Status: outline only. Asset classification still needs to be performed against the actual asset folders.

## Classification Categories

- Playable
- NPC
- Enemy
- Boss
- Shopkeeper
- Hub-only
- Background/parallax
- UI
- VFX
- Tile/terrain
- Trap/hazard

## Playable Candidate Filter

Playable candidates are selected by:

1. Animation completeness.
2. Scale compatibility.
3. Visual role fit.

Required playable animation target:

```text
idle
run
jump
fall
attack
hurt
death
special
dash
slide
```

## Audit Table Template

| Asset path | Category | Candidate role | Animation coverage | Scale fit | Style fit | Cleanup needed | Fallback use |
|---|---|---|---|---|---|---|---|
| TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

## Playable Candidate Template

| Candidate | Source path | Possible title | Required animations present | Missing animations | Scale notes | Role notes | Decision |
|---|---|---|---|---|---|---|---|
| TBD | TBD | Ronin / Arc-Gunner / Iron Knight / Witch / Shadow / other | TBD | TBD | TBD | TBD | Pending |

## Locked Decisions

- Animation completeness comes before lore fit.
- Scale compatibility comes before visual role fit.
- The Witch is not starter-selectable.
- The first three starter roles are Ronin, Arc-Gunner, and Iron Knight.
- Monstrous sprites may be candidates for The Blood-Marked or The Yokai-Bound.

## Open Questions

- Which asset folders contain the strongest playable candidates.
- Which sprites already support dash and slide without new frame work.
- Which enemies can support the Samurai Castle Wing without style mismatch.
- Which assets support Final Tower, Monster Belly, and Core.
- Whether title, menu, and UI assets need a separate audit pass.

## Implementation Notes

- Use this audit before changing character scenes or data resources.
- Do not lock playable selections until sprite sheets are tested in motion.
- Use fallback categories aggressively; a failed playable candidate can still become an NPC, enemy, boss, shopkeeper, or hub character.
- Any generated/painted edits should be cleaned and normalized before becoming production sprites.

