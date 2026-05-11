# Final Dungeon Spec

The final dungeon order is locked:

```text
The Final Tower
-> Inside the Monster's Belly
-> The Core
```

This spec is an outline until the asset audit confirms support for tower, organic horror, and core visuals.

## Final Tower

Role:

- Long vertical climb.
- Boss gauntlet.
- Full traversal exam.
- Restored-seal checkpoint structure.

Planning targets:

- 8 to 12 major floors.
- One checkpoint floor per restored major seal.
- Optional side rooms for final gear.
- Storm, debris, distant tower, and vertical parallax.

Floor template:

| Floor | Theme | Required traversal | Encounter type | Checkpoint? |
|---|---|---|---|---|
| 1 | Entry breach | Basic movement | Enemy gauntlet | Yes |
| 2 | Broken ascent | Vertical ascent | Platforming + enemies | TBD |
| 3 | Wide void | Gap crossing | Traversal challenge | TBD |
| 4 | Cracked machinery | Heavy break | Puzzle/combat | TBD |
| 5 | Cursed flood | Water/depth or hazard crossing | Hazard route | TBD |
| 6 | Shadow galleries | Shadow/phase | Ambush route | TBD |
| 7 | Seal convergence | Multiple | Miniboss | Yes |
| 8 | Crown approach | All major seals | Boss gauntlet start | TBD |

## Boss Gauntlet

Possible gauntlet roles:

- Rematched major bosses.
- Oni-Worn Lord rematch if not already resolved.
- Secret-boss echo if optional requirements are met.
- Character quest boss echoes for completed quests.

Do not lock exact boss list until boss roster is planned.

## Inside the Monster's Belly

Role:

- Horror-heavy second final section.
- The party is swallowed or pulled into the living body of the demon/Keep-heart.

Room sequence targets:

- Mouth/throat entry.
- Rib corridor.
- Acid stomach basin.
- Vein pump chamber.
- Parasite nest.
- Breathing wall maze.
- Heart gate.

Hazards:

- Acid pools.
- Pulsing walls.
- Crushing ribs.
- Parasite swarms.
- Corruption clouds.
- Living-floor movement.

## The Core

Role:

- Final boss space.
- Fusion of demon, tower, monster, and living castle heart.

Boss phase outline:

1. Core shell and hazard arena.
2. Character/tag-swap pressure phase.
3. Seal-response phase requiring traversal categories.
4. Final choice phase.

## Ending Choice Structure

Possible endings:

- Destroy the Core.
- Seal the Core.
- Cleanse the Core.
- Take control.
- Bargain with it.
- Hidden/true option later.

## Ending Requirements

Potential requirement types:

- Character quests completed.
- Secret characters recruited.
- Optional seals restored.
- Hub restoration quests completed.
- Pair affinity milestones.
- Final Tower optional rooms cleared.

## Locked Decisions

- Final dungeon order is Final Tower -> Monster Belly -> Core.
- Final Tower is vertical and traversal-heavy.
- Monster Belly is organic horror.
- Core is final boss and ending choice space.

## Open Questions

- Exact floor count.
- Exact boss gauntlet list.
- Whether every major seal creates a checkpoint floor.
- Whether ending choice is explicit UI, final interaction, or dialogue-driven.
- Whether hidden/true ending exists in base game or later expansion.

## Implementation Notes

- Keep final dungeon data-driven so restored seals can affect checkpoints.
- Use checkpoint floors to reduce frustration during long climb.
- Save ending choice flags separately from autosave state.
- Final boss should test party swapping without requiring one specific character.

