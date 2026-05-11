# Planning Backlog

This backlog orders the Black Keep planning work needed before large production implementation. The master plan remains the overview; these items turn it into buildable specs.

## Recommended Order

1. Asset audit.
2. Playable character selection.
3. First milestone production spec.
4. Party/Momentum technical spec.
5. Samurai Castle Wing room plan.
6. Sakuramori Court hub plan.
7. Traversal seals.
8. Zone manifest.
9. World Break state plan.
10. Final dungeon spec.

## Planning Documents

| Priority | Document | Purpose | Status |
|---|---|---|---|
| 1 | [Asset Audit Results](asset_audit_results.md) | Classify real assets and choose playable candidates. | Contact-sheet review complete; import-test shortlist chosen |
| 2 | [Playable Import Test Plan](playable_import_test_plan.md) | Define import-test order, slicing assumptions, acceptance criteria, and candidate-specific risks. | Draft |
| 3 | [First Milestone Production Spec](first_milestone_production_spec.md) | Convert the milestone route into room-by-room build scope. | Outline |
| 4 | [Character Creation Spec](character_creation_spec.md) | Define starter select, naming, confirmation, save data, and opening variants. | Outline |
| 5 | [Party System Technical Spec](party_system_technical_spec.md) | Define roster, party state, names, HP/resources, Momentum, tag attacks, and hub management. | Outline |
| 6 | [Momentum Tuning](momentum_tuning.md) | Set first-pass numbers for swapping, combo refunds, cooldowns, and difficulty presets. | Outline |
| 7 | [Samurai Castle Wing Spec](samurai_castle_wing_spec.md) | Define first identity dungeon, stealth/rescue, Masakiro, and Rising Torii Seal. | Outline |
| 8 | [Sakuramori Court Spec](sakuramori_court_spec.md) | Define first hub layout, services, NPC schedules, and World Break variant. | Outline |
| 9 | [Traversal Seals](traversal_seals.md) | Plan major traversal categories and character-specific expressions. | Outline |
| 10 | [Zone Manifest](zone_manifest.md) | List candidate zones and tie them to asset support. | Outline |
| 11 | [World Break State Plan](world_break_state_plan.md) | Define pre-break, break event, and post-break content state model. | Outline |
| 12 | [Final Dungeon Spec](final_dungeon_spec.md) | Define Final Tower, Monster Belly, Core, bosses, and endings. | Outline |

## Locked Decisions

- The project direction is The Black Keep.
- The SpriteVania vertical slice remains the implementation foundation.
- The first starter choices are The Ronin, The Arc-Gunner, and The Iron Knight.
- The Black Witch of Ash is not starter-selectable.
- The first required party is starter, Witch, Shadow.
- The first seal is Rising Torii Seal, which unlocks vertical ascent.
- Do not write final dialogue during planning specs.

## Open Questions

- Which actual sprites become the 8 playable characters after contact-sheet and motion review.
- Which audited zone assets pass in-engine style and scale checks.
- Which asset folders have enough tile, parallax, enemy, boss, and UI coverage for production.
- Whether the first milestone should ship all three starter variants or one starter-first implementation pass.
- How much of the global settings split should happen before party-system implementation.
- Whether to choose `player_generic` for final Iron Knight despite its generic visual identity, or reserve it as a technical fallback.
- Whether The Shadow needs new/custom art because `magic_cliffs_player` does not visually read as a stealth/scout recruit.

## Implementation Notes

- Each planning doc should become a task source for implementation tickets.
- Asset audit results should be treated as a dependency for playable roster, zone manifest, and production art scope.
- Specs should use stable IDs for rooms, characters, abilities, seals, zones, and state flags before code work begins.
- The next audit task should create import-test plans for `SWAT_1`, `player/samurai`, `Witch_3`, and `player_generic`.
