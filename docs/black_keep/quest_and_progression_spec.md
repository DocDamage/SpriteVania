# Quest And Progression Spec

This document defines first-pass quest, progression, and unlock structure for
The Black Keep without writing final quest dialogue.

## Goals

- Keep main story progression clear.
- Track recruitment and traversal unlocks safely.
- Support character quests later.
- Prevent missed side quests from blocking main story.
- Make World Break quest changes explicit.

## Progression Types

Main story:

- Required route and boss progression.
- Unlocks zones, party members, and seals.

Character quest:

- Personal quest for a playable character.
- Unlocks ultimate weapon, costume, tag upgrade, or ending contribution.

Hub quest:

- Service, NPC, rebuild, or rescue quest.
- Can change hub state or inventory.

Seal quest:

- Unlocks or restores traversal seal.
- Can be mandatory or optional.

Secret quest:

- Unlocks secret characters, bosses, or endings.

## First Milestone Main Quest

Quest ID:

- `main_001_reach_black_keep`

Steps:

1. Start New Game.
2. Select starter.
3. Reach Modern City Outskirts.
4. Enter Rural Swamp Road.
5. Clear Swamp route.
6. Reach Castle Gate.

Completion:

- `castle_gate_reached`

Quest ID:

- `main_002_recruit_witch`

Steps:

1. Reach Damaged Shrine.
2. Interact with shrine.
3. Name The Black Witch of Ash.
4. Complete recruitment.

Completion:

- `witch_recruited`

Quest ID:

- `main_003_learn_tag_swap`

Steps:

1. Enter Tag Tutorial.
2. Swap to Witch.
3. Trigger or observe tag attack.
4. Defeat tutorial enemies.

Completion:

- `tag_tutorial_cleared`

Quest ID:

- `main_004_rescue_shadow`

Steps:

1. Enter Samurai Castle Wing.
2. Pass patrol hall.
3. Reach prison.
4. Rescue The Shadow.
5. Name The Shadow.
6. Escape alarm route.

Completion:

- `shadow_recruited`

Quest ID:

- `main_005_defeat_masakiro`

Steps:

1. Reach Boss Antechamber.
2. Enter Masakiro Arena.
3. Defeat Masakiro.
4. Witness oni-consumption scene.

Completion:

- `masakiro_defeated`

Quest ID:

- `main_006_unlock_rising_torii`

Steps:

1. Enter seal room.
2. Collect Rising Torii Seal.
3. Clear ascent test.
4. Reach Sakuramori Court.

Completion:

- `sakuramori_court_reached`

## Character Quest Structure

Every base-game playable character has three personal quests.

Quest 1:

- Recruitment, naming, or personal motivation.
- Reward: character joins.

Quest 2:

- Mastery quest.
- Reward: ultimate weapon or major skill.

Quest 3:

- Identity quest.
- Reward: final costume and upgraded tag attack.

Milestone character quests:

- Starter Quest 1 is completed through character creation.
- Witch Quest 1 is completed at damaged shrine.
- Shadow Quest 1 is completed at prison rescue.

## Progression Flags

Main flags:

- `starter_selected`
- `starter_named`
- `modern_outskirts_cleared`
- `rural_road_cleared`
- `swamp_route_cleared`
- `castle_gate_reached`
- `witch_recruited`
- `tag_tutorial_cleared`
- `samurai_castle_entered`
- `shadow_recruited`
- `samurai_alarm_escape_cleared`
- `masakiro_defeated`
- `rising_torii_seal_unlocked`
- `sakuramori_court_reached`

Side flags:

- `swamp_shortcut_opened`
- `samurai_perfect_stealth_failed`
- `moonpetal_passage_discovered`
- `party_shrine_unlocked`

## Rewards

Progression rewards:

- New party member.
- New traversal seal.
- New hub access.
- Shortcut open.
- Save checkpoint.

Character rewards:

- Skill.
- Tag attack.
- Weapon.
- Costume.
- Affinity.

Familiar rewards:

- XP.
- Ability upgrade.
- Evolution trigger.

## Quest Log Requirements

Quest log should show:

- Quest title.
- Current objective.
- Zone hint.
- Completion state.
- Optional reward state.

Quest log can be deferred for milestone one if prompts and route structure are
clear, but data should not prevent adding it later.

## World Break Quest Rules

Pre-break quests:

- Can complete normally.
- Some optional quests can transform if missed.

Post-break quests:

- Rescue.
- Rebuild.
- Restore.
- Rematch.
- Recover lost route.

Rules:

- Main story cannot be blocked by missed pre-break side quests.
- Transformed quests should preserve narrative consequence without punishing
  core progression.

## Tests

Automated tests:

- Main quest flags save and load.
- Witch recruitment completes correct quest.
- Shadow recruitment completes correct quest.
- Masakiro defeat completes correct quest.
- Rising Torii pickup completes correct quest.
- Shortcut flag saves and loads.
- Missing optional quest does not block main route.

Manual tests:

- Follow milestone main quest chain.
- Save and continue after each quest completion.
- Verify repeated recruitment does not duplicate quest reward.
- Verify quest state survives room transitions.
