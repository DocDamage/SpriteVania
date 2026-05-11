# Planning Backlog

This backlog orders the Black Keep planning work needed before large production
implementation. The master plan remains the overview. These items turn it into
buildable specs.

## Recommended Order

1. Asset audit.
2. Playable character selection.
3. First milestone production spec.
4. Milestone build tasks.
5. Milestone room graph.
6. Asset integration tasks.
7. Milestone verification plan.
8. Party and Momentum technical spec.
9. Combat and movement spec.
10. Enemy AI spec.
11. Samurai Castle Wing room plan.
12. Sakuramori Court hub plan.
13. Traversal seals.
14. Zone manifest.
15. World Break state plan.
16. Final dungeon spec.
17. Implementation epics.
18. Technical architecture plan.
19. Milestone task board.
20. Test strategy.
21. Risk register.
22. Production readiness checklist.
23. First milestone room layouts.
24. UI wireframes.
25. Balance tuning plan.
26. Audio plan.
27. Credits and license audit.
28. Implementation ticket slices.
29. Asset decision log.
30. Enemy roster plan.
31. Dialogue and tutorial prompt spec.
32. Quest and progression spec.
33. First implementation sprint.

## Planning Documents

Priority 0: [Implementation Epics](implementation_epics.md)

- Purpose: group development work into engineering epics with dependencies and
  acceptance criteria.
- Status: draft.

Priority 0: [Technical Architecture Plan](technical_architecture_plan.md)

- Purpose: propose resources, managers, save flow, room flow, combat flow, input
  flow, and testing architecture.
- Status: draft.

Priority 0: [Milestone Task Board](milestone_task_board.md)

- Purpose: turn the first milestone into ticket-shaped implementation tasks.
- Status: draft.

Priority 0: [Test Strategy](test_strategy.md)

- Purpose: define headless tests, dev scenes, manual playtests, warning policy,
  and release-candidate checks.
- Status: draft.

Priority 0: [Risk Register](risk_register.md)

- Purpose: track production risks, impact, mitigation, and review cadence.
- Status: draft.

Priority 0: [Production Readiness Checklist](production_readiness_checklist.md)

- Purpose: define go/no-go criteria for milestone review and merge readiness.
- Status: draft.

Priority 0: [Implementation Ticket Slices](implementation_ticket_slices.md)

- Purpose: break milestone work into file- and system-oriented implementation
  tickets.
- Status: draft.

Priority 0: [First Implementation Sprint](first_implementation_sprint.md)

- Purpose: define the first focused sprint that moves from docs into code.
- Status: draft.

Priority 1: [Asset Audit Results](asset_audit_results.md)

- Purpose: classify real assets and choose playable candidates.
- Status: contact-sheet review complete; import-test shortlist chosen.

Priority 1: [Asset Decision Log](asset_decision_log.md)

- Purpose: record prototype approvals, final-art risks, deferred assets, and
  next actions.
- Status: draft.

Priority 2: [Playable Import Test Plan](playable_import_test_plan.md)

- Purpose: define import-test order, slicing assumptions, acceptance criteria,
  and candidate-specific risks.
- Status: draft.

Priority 3: [First Milestone Production Spec](first_milestone_production_spec.md)

- Purpose: convert the milestone route into room-by-room build scope.
- Status: outline.

Priority 4: [First Milestone Build Tasks](first_milestone_build_tasks.md)

- Purpose: convert milestone scope into build tasks, acceptance criteria, and
  tests.
- Status: draft.

Priority 5: [Milestone Room Graph](milestone_room_graph.md)

- Purpose: define room IDs, exits, checkpoints, flags, and transition tests.
- Status: draft.

Priority 6: [First Milestone Room Layouts](first_milestone_room_layouts.md)

- Purpose: define room dimensions, markers, layout intent, and acceptance checks.
- Status: draft.

Priority 7: [Asset Integration Tasks](asset_integration_tasks.md)

- Purpose: convert asset audit findings into import, slicing, VFX, tile, and
  enemy tasks.
- Status: draft.

Priority 8: [Milestone Verification Plan](milestone_verification_plan.md)

- Purpose: define automated tests, manual playtests, controller checks, and
  visual review.
- Status: draft.

Priority 9: [UI Wireframes](ui_wireframes.md)

- Purpose: define functional layouts for required milestone UI screens.
- Status: draft.

Priority 10: [Balance Tuning Plan](balance_tuning_plan.md)

- Purpose: define first-pass movement, combat, XP, enemy, boss, familiar, and
  economy values.
- Status: draft.

Priority 11: [Audio Plan](audio_plan.md)

- Purpose: define required music, ambience, SFX, and zone audio direction.
- Status: draft.

Priority 12: [Credits and License Audit](credits_license_audit.md)

- Purpose: track asset sources, licenses, required credits, and release status.
- Status: draft.

Priority 13: [Character Creation Spec](character_creation_spec.md)

- Purpose: define starter select, naming, confirmation, save data, and opening
  variants.
- Status: outline.

Priority 14: [Party System Technical Spec](party_system_technical_spec.md)

- Purpose: define roster, party state, names, HP/resources, Momentum, tag
  attacks, and hub management.
- Status: outline.

Priority 15: [Momentum Tuning](momentum_tuning.md)

- Purpose: set first-pass numbers for swapping, combo refunds, cooldowns, and
  difficulty presets.
- Status: outline.

Priority 16: [Combat and Movement Spec](combat_movement_spec.md)

- Purpose: define attacks, combo basics, dash, double jump, wall actions, slide
  attack, dive bomb, and controller support.
- Status: draft.

Priority 17: [Enemy AI Spec](enemy_ai_spec.md)

- Purpose: define enemy states, patrols, attacks, respawn policies, archetypes,
  and Masakiro first pass.
- Status: draft.

Priority 17: [Enemy Roster Plan](enemy_roster_plan.md)

- Purpose: define milestone enemy roles, behavior purpose, placement, and tests.
- Status: draft.

Priority 18: [Save and Load UX Spec](save_load_ux_spec.md)

- Purpose: define Continue, Load Game, save slots, settings files, migration,
  and robustness.
- Status: draft.

Priority 19: [Samurai Castle Wing Spec](samurai_castle_wing_spec.md)

- Purpose: define first identity dungeon, stealth/rescue, Masakiro, and Rising
  Torii Seal.
- Status: outline.

Priority 19: [Dialogue and Tutorial Prompt Spec](dialogue_and_tutorial_prompt_spec.md)

- Purpose: define placeholder dialogue rules, tutorial prompt placement, flags,
  and accessibility requirements.
- Status: draft.

Priority 19: [Quest and Progression Spec](quest_and_progression_spec.md)

- Purpose: define milestone quest chain, progression flags, rewards, and World
  Break quest rules.
- Status: draft.

Priority 20: [Sakuramori Court Spec](sakuramori_court_spec.md)

- Purpose: define first hub layout, services, NPC schedules, and World Break
  variant.
- Status: outline.

Priority 21: [Traversal Seals](traversal_seals.md)

- Purpose: plan major traversal categories and character-specific expressions.
- Status: outline.

Priority 22: [Zone Manifest](zone_manifest.md)

- Purpose: list candidate zones and tie them to asset support.
- Status: outline.

Priority 23: [World Break State Plan](world_break_state_plan.md)

- Purpose: define pre-break, break event, and post-break content state model.
- Status: outline.

Priority 24: [Final Dungeon Spec](final_dungeon_spec.md)

- Purpose: define Final Tower, Monster Belly, Core, bosses, and endings.
- Status: outline.

## Locked Decisions

- The project direction is The Black Keep.
- The SpriteVania vertical slice remains the implementation foundation.
- The first starter choices are The Ronin, The Arc-Gunner, and The Iron Knight.
- The Black Witch of Ash is not starter-selectable.
- The first required party is starter, Witch, Shadow.
- The first seal is Rising Torii Seal, which unlocks vertical ascent.
- Do not write final dialogue during planning specs.

## Open Questions

- Which actual sprites become the eight playable characters after contact-sheet
  and motion review?
- Which audited zone assets pass in-engine style and scale checks?
- Which asset folders have enough tile, parallax, enemy, boss, and UI coverage?
- Should the first milestone ship all three starter variants or one
  starter-first implementation pass?
- How much of the global settings split should happen before party-system
  implementation?
- Should `player_generic` become final Iron Knight art, or stay a technical
  fallback?
- Does The Shadow need custom art because `magic_cliffs_player` does not read as
  a stealth/scout recruit?

## Implementation Notes

- Each planning doc should become a task source for implementation tickets.
- Asset audit results should be treated as a dependency for playable roster,
  zone manifest, and production art scope.
- Specs should use stable IDs for rooms, characters, abilities, seals, zones,
  and state flags before code work begins.
- The next audit task should create import-test plans for `SWAT_1`,
  `player/samurai`, `Witch_3`, and `player_generic`.
