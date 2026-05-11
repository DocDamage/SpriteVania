# The Black Keep Master Plan

## Document Status

This is the clean master overview for The Black Keep.

- Repo: DocDamage/SpriteVania.
- Branch target: temporary-full-assets.
- Current foundation: the SpriteVania Godot vertical slice.
- Target direction: The Black Keep, a real-time action RPG and Metroidvania.
- Scope: creative direction, production priorities, and links to focused specs.
- Code impact: this document does not define a code change by itself.

The detailed production specs live in the focused documents under
`docs/black_keep/`.

## Focused Documents

- [Black Keep docs index](black_keep/README.md)
- [First milestone overview](black_keep/first_milestone.md)
- [First milestone production spec](black_keep/first_milestone_production_spec.md)
- [First milestone build tasks](black_keep/first_milestone_build_tasks.md)
- [Milestone room graph](black_keep/milestone_room_graph.md)
- [First milestone room layouts](black_keep/first_milestone_room_layouts.md)
- [Asset integration tasks](black_keep/asset_integration_tasks.md)
- [Milestone verification plan](black_keep/milestone_verification_plan.md)
- [UI wireframes](black_keep/ui_wireframes.md)
- [Balance tuning plan](black_keep/balance_tuning_plan.md)
- [Audio plan](black_keep/audio_plan.md)
- [Credits and license audit](black_keep/credits_license_audit.md)
- [Implementation ticket slices](black_keep/implementation_ticket_slices.md)
- [First implementation sprint](black_keep/first_implementation_sprint.md)
- [Enemy roster plan](black_keep/enemy_roster_plan.md)
- [Dialogue and tutorial prompt spec](black_keep/dialogue_and_tutorial_prompt_spec.md)
- [Quest and progression spec](black_keep/quest_and_progression_spec.md)
- [Character creation spec](black_keep/character_creation_spec.md)
- [CharacterCreator2D port](character_creator_2d_port.md)
- [Godot CharacterCreator2D tool roadmap](character_creator_2d_godot_tool_roadmap.md)
- [Party and combat overview](black_keep/party_and_combat.md)
- [Party system technical spec](black_keep/party_system_technical_spec.md)
- [Momentum tuning](black_keep/momentum_tuning.md)
- [Combat and movement spec](black_keep/combat_movement_spec.md)
- [Enemy AI spec](black_keep/enemy_ai_spec.md)
- [Save and load UX spec](black_keep/save_load_ux_spec.md)
- [Menu and settings plan](black_keep/menu_settings_plan.md)
- [Art pipeline](black_keep/art_pipeline.md)
- [Asset classification](black_keep/asset_classification.md)
- [Asset audit results](black_keep/asset_audit_results.md)
- [Asset decision log](black_keep/asset_decision_log.md)
- [Playable import test plan](black_keep/playable_import_test_plan.md)
- [Playable import test results](black_keep/playable_import_test_results.md)
- [Story outline](black_keep/story_outline.md)
- [Sakuramori Court spec](black_keep/sakuramori_court_spec.md)
- [Samurai Castle Wing spec](black_keep/samurai_castle_wing_spec.md)
- [World Break state plan](black_keep/world_break_state_plan.md)
- [Traversal seals](black_keep/traversal_seals.md)
- [Zone manifest](black_keep/zone_manifest.md)
- [Final dungeon spec](black_keep/final_dungeon_spec.md)
- [Planning backlog](black_keep/planning_backlog.md)
- [Implementation epics](black_keep/implementation_epics.md)
- [Technical architecture plan](black_keep/technical_architecture_plan.md)
- [Milestone task board](black_keep/milestone_task_board.md)
- [Test strategy](black_keep/test_strategy.md)
- [Risk register](black_keep/risk_register.md)
- [Production readiness checklist](black_keep/production_readiness_checklist.md)

## Current Creative Direction

The project started as a SpriteVania vertical slice. That foundation remains
valuable because it already proves movement, combat, saves, room transitions,
menus, progression, enemies, checkpoints, and tests.

The target game direction is now The Black Keep. The game is a real-time
castle-and-portal action RPG with Metroidvania progression. The central location
is a demonic castle rooted near modern city outskirts and a rural swamp road.
Its portals open into pocket dimensions from different times and places.

The Feudal Japan-inspired fragments are the main story identity, but they are
not one continuous zone. They appear as separate wings, hubs, shrines, roads,
battlefields, and late-game spaces inside the Keep's portal network.

## Canon Rules

Older Chroma's Edge and Orion planning material may be used as inspiration only.

Keep these ideas as inspiration:

- World Break structure.
- False relic and true relic misdirection.
- Act 1 catastrophe and Act 2 restoration.
- Affinity and duo attack concepts.
- Large-system planning for accessibility, saves, endgame, and optional bosses.
- Major powers that stabilize or destabilize reality.

Replace these ideas completely:

- Orion as the setting.
- The Lattice and Progenitor Engine names.
- Nix as the only interface character.
- Dominion as the named faction.
- The fixed 13-character Chroma's Edge party.
- ATB combat.
- Summon-owner canon.

All playable heroes in The Black Keep are seal-bearers. Every playable character
can activate portals and traversal seals, but each character expresses those
abilities through their own animation style and lore.

## Current Repo Foundation

The current implementation foundation includes:

- Title, continue, settings, load-game, and character-selection flow.
- Three starter classes with movement and combat abilities.
- Save and continue state.
- XP, leveling, HUD updates, and progression state.
- Room transitions, traversal gates, shortcuts, hazards, enemies, checkpoints,
  pause saving, and boss-gated exits.
- Swamp Outskirts route and Castle Gate groundwork.
- Player damage, enemy contact damage, crawler attacks, and knockback.
- Familiar progression with leveling, evolution, upgrades, and enemy attacks.
- Controller support groundwork and input-map tests.
- Title-screen art, parallax, weather, polish layers, and expanded settings.
- CharacterCreator2D Base Fantasy source import, complete animation inventory profiling, and Godot-native creator/tool roadmap.

This foundation should be refined into the first Black Keep milestone rather
than discarded.

## First Milestone Target

The first complete Black Keep milestone should prove the following route:

1. Title screen.
2. New Game.
3. Starter character selection.
4. Player naming.
5. Modern City Outskirts.
6. Rural Swamp Road transition.
7. Swamp Outskirts.
8. Castle Gate.
9. Damaged Shrine.
10. Black Witch recruitment.
11. Tag-swap tutorial fight.
12. Samurai Castle Wing.
13. Shadow rescue.
14. Lord Masakiro boss.
15. Rising Torii Seal pickup.
16. Sakuramori Court hub.

By the end of the milestone, the player should have three active party members:

- The selected starter.
- The Black Witch of Ash.
- The Shadow.

The milestone should prove active party swapping, individual resources,
Momentum, tag-entry attacks, KO auto-switch behavior, reserve progression, and
hub party management.

## Playable Roster

The base game target is eight playable characters plus one New Game Plus secret
character.

- Slot 1: The Ronin. Samurai and sword fighter. Starter option or later recruit.
- Slot 2: The Arc-Gunner. Modern soldier and magical gunner. Starter option or
  later recruit.
- Slot 3: The Iron Knight. Tank, knight, and Black Keep survivor. Starter option
  or later recruit.
- Slot 4: The Black Witch of Ash. Mage and ash-seal ritualist. Required first
  recruit, not starter-selectable.
- Slot 5: The Shadow. Ranger, scout, and infiltrator. Required early recruit.
- Slot 6: The Gadgeteer. Scientist and tool user. Recruitable.
- Slot 7: The Blood-Marked. Demon-touched berserker. Secret before the final
  dungeon.
- Slot 8: The Yokai-Bound. Monster or yokai hero. Secret before the final
  dungeon.
- New Game Plus: The Fallen Shogun. Samurai lord and possible ally.

All base-game playable characters receive player-given names. Their titles stay
fixed in UI, dialogue, saves, and menus.

Only these starters are selectable during character creation:

- The Ronin.
- The Arc-Gunner.
- The Iron Knight.

The Witch is not selectable at character creation.

## Combat Model

The Black Keep uses real-time action combat, not ATB.

Core combat rules:

- The active party contains three characters.
- One character is visible and controlled at a time.
- The player can swap among the active three during combat.
- Swapping costs Momentum.
- Each character has individual HP, resources, and Momentum.
- Combo hits refund Momentum.
- Perfect swaps refund more Momentum.
- Incoming characters perform tag-entry attacks.
- KO behavior auto-switches to another living active character.
- Benched active characters recover slowly.
- Reserve characters gain partial XP.
- Full roster management happens at Cherry Blossom Court hubs.

Combat settings should support different combo timing presets:

- Story.
- Normal.
- Technical.
- Expert.

## Movement And Traversal

The game should support modern Metroidvania movement, including:

- Run.
- Jump.
- Double jump.
- Ground dash.
- Air dash.
- Wall jump.
- Wall hang.
- Controlled wall fall.
- Dash strike.
- Dive-bomb attack.
- Character-specific traversal identities.

Traversal seals unlock global movement categories, while each character expresses
the same category differently. No required puzzle should demand one specific
character if the player has the relevant seal.

The first locked traversal reward is the Rising Torii Seal, earned from Samurai
Castle Wing. It unlocks vertical ascent.

## Title Screen And Menus

The title screen direction is:

- Full-screen pixel-art title background.
- Title text: THE BLACK KEEP.
- Main menu buttons: Continue, New Game, Load Game, Settings, Accessibility,
  Extras, Credits, Quit.
- Parallax motion, Moon Sky layer, weather, petals, fog, rain, stars, vignette,
  and build label.
- Reduced-motion setting should reduce or disable animated title effects.

Current placeholder menu work should eventually become:

- Load Game opens a save-slot screen.
- Accessibility opens the Accessibility tab inside Settings.
- Extras opens unlockable content.
- Credits opens a real credits screen.
- Settings are split between global settings and save-specific settings.

## Hubs

Cherry Blossom Courts are the major safe hubs. The first hub is Sakuramori
Court.

Major hubs should support:

- Party switching.
- Renaming.
- Save shrine.
- Inn or healing service.
- Shop.
- Blacksmith.
- Quest board.
- Dialogue archive.
- Crafting.
- Training room.
- Bestiary.
- Palette or costume variants.
- Day and night NPC schedules.

After the World Break, hubs remain safe but change visually and mechanically.
NPC schedules, shops, quests, routes, and atmosphere should update.

## Early Zones

The first milestone uses these early spaces:

- Modern City Outskirts.
- Rural Swamp Road.
- Swamp Outskirts.
- Castle Gate.
- Damaged Shrine.
- Samurai Castle Wing.
- Sakuramori Court.

Samurai Castle Wing is the first major identity dungeon. It introduces Feudal
Japan fragments, stealth and rescue play, the Shadow recruit, Lord Masakiro, and
the Rising Torii Seal.

## World Break

The World Break is the midgame state change. It should:

- Physically alter The Black Keep.
- Change portal worlds.
- Damage hub visuals without making hubs unsafe.
- Change NPC schedules.
- Change shop inventory.
- Change available quests.
- Replace or upgrade enemy routes.
- Alter parallax, weather, lighting, and title-screen state.
- Bring back earlier villains and zones in corrupted forms.

Lord Masakiro should return after the World Break as Masakiro, the Oni-Worn
Lord.

## Final Dungeon

The final dungeon order is:

1. Final Tower.
2. Inside the Monster's Belly.
3. The Core.

The Final Tower is a long vertical climb with checkpoints, traversal challenges,
and a boss gauntlet. Inside the Monster's Belly is a horror-focused living-body
area. The Core is the final boss space, where the demon, tower, monster, and
living castle heart are fused.

Ending options may include:

- Destroy the Core.
- Seal the Core.
- Cleanse the Core.
- Take control.
- Bargain with it.
- Hidden true option, if later supported.

## Art And Asset Pipeline

The project should use the SpriteVania asset folders as the main asset source.
The asset pipeline should prioritize animation completeness before visual role.

Playable candidates need these animation targets:

- Idle.
- Run.
- Jump.
- Fall.
- Attack.
- Hurt.
- Death.
- Special.
- Dash.
- Dash strike.

Asset review categories:

- Playable.
- NPC.
- Enemy.
- Boss.
- Shopkeeper.
- Hub-only.
- Background and parallax.
- UI.
- VFX.
- Tile and terrain.
- Trap and hazard.

Art normalization should account for palette, outlines, scale, brightness,
contrast, animation timing, collision readability, and UI readability.

## Production Priorities

The next production priorities are:

1. Finish the asset audit and playable character selection.
2. Convert the first milestone production spec into build tasks.
3. Implement the final character creation flow.
4. Implement the party roster and active party state.
5. Implement Momentum, tag attacks, KO auto-switch, and reserve XP.
6. Build Samurai Castle Wing room flow.
7. Build Sakuramori Court hub services.
8. Finalize traversal seal categories and character-specific expressions.
9. Expand the zone manifest based on usable assets.
10. Plan and implement World Break state variants.
11. Plan the Final Tower, Monster Belly, and Core in detail.

## Open Questions

Open planning questions:

- Which audited sprites become the final playable characters?
- Which tile sets best support the first milestone rooms?
- How many major zones can be supported by the current asset library?
- Which enemies belong in the first Samurai Castle Wing pass?
- Which boss sprites support Lord Masakiro and his World Break form?
- How deep should stealth be in the first milestone?
- Which systems must be implemented before party combat can feel reliable?
- Which features are milestone blockers and which are later polish?

## Short Version

The Black Keep is now the main game identity for the repo. The SpriteVania
vertical slice remains the implementation foundation. The target game is a
real-time tag-combo action RPG and Metroidvania with player-named heroes, active
party swapping, traversal seals, Cherry Blossom Court hubs, a World Break
midgame shift, and a final dungeon sequence of Final Tower, Monster's Belly, and
the Core.
