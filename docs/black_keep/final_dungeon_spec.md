# Final Dungeon Spec

The final dungeon order is locked:

1. The Final Tower.
2. Inside the Monster's Belly.
3. The Core.

This spec remains planning-level until asset support for tower, organic horror,
and core visuals is confirmed in-engine.

## Goals

- Deliver a final traversal exam.
- Pay off restored traversal seals.
- Test full party swapping without requiring one specific character.
- Resolve World Break consequences.
- Support multiple ending choices.
- Use checkpoint floors to prevent frustration during the long climb.

## Stable IDs

Zones:

- `final_tower`
- `monster_belly`
- `core`

Major flags:

- `final_tower_unlocked`
- `final_tower_entered`
- `final_tower_checkpoint_floor`
- `monster_belly_entered`
- `core_entered`
- `final_boss_defeated`
- `ending_choice_destroy`
- `ending_choice_seal`
- `ending_choice_cleanse`
- `ending_choice_control`
- `ending_choice_bargain`
- `ending_choice_true`

## Unlock Requirements

Final Tower should open when:

- Required main seals are restored or stabilized.
- Required story bosses are defeated.
- World Break state is post-break or restoration.
- Sakuramori Court or equivalent hub has a final approach route.

Optional requirements can affect:

- Extra checkpoint floors.
- Boss gauntlet variants.
- Final dialogue.
- Ending choices.
- True ending availability.

## Final Tower

Role:

- Long vertical climb.
- Boss gauntlet.
- Full traversal exam.
- Restored-seal checkpoint structure.

Planning targets:

- Eight to twelve major floors.
- One checkpoint floor for each restored major seal cluster.
- Optional side rooms for final gear.
- Storm, debris, distant tower, and vertical parallax.
- Route shortcuts opened from inside the tower.

## Final Tower Floor Plan

Floor 1: Entry Breach.

- Required traversal: basic movement.
- Encounter: enemy gauntlet.
- Checkpoint: yes.
- Purpose: prove final-tower baseline pressure.

Floor 2: Broken Ascent.

- Required traversal: vertical ascent.
- Encounter: platforming plus enemies.
- Checkpoint: optional.
- Purpose: pay off Rising Torii Seal.

Floor 3: Wide Void.

- Required traversal: gap crossing.
- Encounter: long-air traversal challenge.
- Checkpoint: optional.
- Purpose: test Wind Bridge Seal.

Floor 4: Cracked Machinery.

- Required traversal: heavy break.
- Encounter: puzzle combat.
- Checkpoint: optional.
- Purpose: test Giant Breaker or forge-style seal.

Floor 5: Cursed Flood.

- Required traversal: water/depth or hazard crossing.
- Encounter: hazard route.
- Checkpoint: optional.
- Purpose: combine Deep Moon or Ember Path checks.

Floor 6: Shadow Galleries.

- Required traversal: shadow/phase.
- Encounter: ambush route.
- Checkpoint: optional.
- Purpose: test Shadow Gate Seal.

Floor 7: Seal Convergence.

- Required traversal: multiple categories.
- Encounter: miniboss.
- Checkpoint: yes.
- Purpose: test mixed traversal under pressure.

Floor 8: Crown Approach.

- Required traversal: all major seals.
- Encounter: boss gauntlet start.
- Checkpoint: yes.
- Purpose: transition into final gauntlet.

Optional upper floors:

- Character quest echo floor.
- Secret character route.
- True ending route.
- Final shop or shrine.

## Boss Gauntlet

Possible gauntlet roles:

- Rematched major bosses.
- Oni-Worn Lord rematch if not already resolved.
- Secret-boss echo if optional requirements are met.
- Character quest boss echoes for completed quests.
- Seal guardian echoes.

Rules:

- Do not lock the exact boss list until boss roster is planned.
- Every gauntlet boss needs a checkpoint or retry structure.
- Optional bosses should not block base ending.
- Completed character quests can alter or weaken specific echoes.

## Monster Belly

Role:

- Horror-heavy second final section.
- Party is swallowed or pulled into the living body of the demon or Keep-heart.
- Visual contrast after the stone and storm of Final Tower.

Room sequence:

- `MonsterBelly_MouthEntry`
- `MonsterBelly_ThroatDrop`
- `MonsterBelly_RibCorridor`
- `MonsterBelly_AcidBasin`
- `MonsterBelly_VeinPump`
- `MonsterBelly_ParasiteNest`
- `MonsterBelly_BreathingMaze`
- `MonsterBelly_HeartGate`

Hazards:

- Acid pools.
- Pulsing walls.
- Crushing ribs.
- Parasite swarms.
- Corruption clouds.
- Living-floor movement.

Traversal:

- Hazard crossing.
- Narrow passage.
- Water/depth movement.
- Shadow/phase if the route uses living darkness.

Rules:

- Organic motion must respect reduced-motion settings.
- Body horror should be readable and not obscure collision.
- Save points should be rare but fair.

## The Core

Role:

- Final boss space.
- Fusion of demon, tower, monster, and living castle heart.
- Ending choice location.

Arena needs:

- Multi-phase boss room.
- Clear safe zones.
- Seal-response mechanics.
- Party-swap pressure.
- Familiar participation, if familiar remains active in final boss.
- Reduced-motion-compatible VFX.

Boss phase outline:

1. Core shell and hazard arena.
2. Party/tag-swap pressure phase.
3. Seal-response phase requiring traversal categories.
4. Character memory or quest-response phase, if supported.
5. Final choice phase.

## Ending Choices

Destroy the Core:

- Direct ending.
- Requires defeating final boss.
- May leave some portal consequences unresolved.

Seal the Core:

- Containment ending.
- Requires key seals restored.
- Safer but possibly temporary.

Cleanse the Core:

- Restoration ending.
- Requires hub restoration and major character quests.

Take Control:

- Dark or ambiguous ending.
- Requires specific late-game choice or corruption threshold.

Bargain With It:

- Compromise ending.
- Requires specific NPC, faction, or secret knowledge flags.

Hidden True Option:

- Optional.
- Requires secret characters, optional seals, and major hub restoration.

## Ending Requirement Data

Requirement types:

- Character quests completed.
- Secret characters recruited.
- Optional seals restored.
- Hub restoration quests completed.
- Pair affinity milestones.
- Final Tower optional rooms cleared.
- World Break restoration state.
- Familiar evolution or final ability state.

Save rules:

- Save ending choice flags separately from autosave state.
- Do not overwrite pre-ending save unless player confirms.
- Allow post-ending or clear-save state later if desired.

## Checkpoints

Checkpoint rules:

- Final Tower uses checkpoint floors.
- Monster Belly uses fewer but safe checkpoints.
- Core has immediate pre-boss checkpoint.
- Ending choice should not autosave over the only pre-choice save.

Potential checkpoint IDs:

- `checkpoint_final_tower_entry`
- `checkpoint_final_tower_convergence`
- `checkpoint_final_tower_crown`
- `checkpoint_monster_belly_entry`
- `checkpoint_monster_belly_heart_gate`
- `checkpoint_core_antechamber`

## Tests

Automated tests:

- Final Tower unlock flag opens route.
- Final Tower room graph has no missing floor transitions.
- Checkpoint floors save and load.
- Required traversal gates check seal categories.
- Monster Belly hazards damage player but do not softlock.
- Core pre-boss checkpoint loads safely.
- Ending choice flags save separately.

Manual tests:

- Climb tower with full party.
- Retry from each checkpoint.
- Run Monster Belly with reduced motion enabled.
- Fight final boss with controller.
- Select each available ending choice in test saves.

## Locked Decisions

- Final dungeon order is Final Tower to Monster Belly to Core.
- Final Tower is vertical and traversal-heavy.
- Monster Belly is organic horror.
- Core is final boss and ending choice space.
- Final boss should test party swapping without requiring one specific
  character.

## Open Questions

- Exact floor count.
- Exact boss gauntlet list.
- Whether every major seal creates a checkpoint floor.
- Whether ending choice is explicit UI, final interaction, or dialogue-driven.
- Whether hidden or true ending exists in base game or later expansion.
- Whether familiar evolution affects final boss or ending requirements.

## Implementation Notes

- Keep final dungeon data-driven so restored seals can affect checkpoints.
- Use checkpoint floors to reduce frustration during long climb.
- Save ending choice flags separately from autosave state.
- Do not implement final dungeon rooms until zone asset review is complete.
