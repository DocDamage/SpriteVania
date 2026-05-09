# SpriteVania Vertical-Slice Design

## Goal

Build the first playable SpriteVania slice in Godot: title screen, working save/continue, character and sprite selection, three distinct class foundations, XP leveling, checkpoint respawn, room re-entry enemy respawns, and the first Swamp Outskirts metroidvania loop.

## Scope

The vertical slice is the first build target. It should prove the game structure without trying to implement the full 15+ hour vision.

Included:
- Title screen with New Game, Continue, and Settings
- Character selection for Warden, Gunslinger, and Hexbinder
- Sprite selection after class choice
- Game start into Swamp Outskirts
- Working save/load through checkpoint shrines and Continue
- XP gain and level-up behavior
- At least one learned or unlockable attack skill path per class
- One class-relevant traversal or tool upgrade
- Classic checkpoint death/respawn
- Normal enemy respawn on room re-entry
- One return shortcut
- One mini-boss beatable by all classes

Excluded from the first slice:
- Full upgrade trees
- Multiple save slots unless trivial after one-slot saving works
- Full settings menu beyond audio and display/window basics
- All later biomes
- Full class story arcs
- Full boss roster

## Menu Flow

The game opens at `TitleScreen`.

New Game:
1. Opens class selection.
2. Player chooses Warden, Gunslinger, or Hexbinder.
3. Player chooses a sprite/visual variant for that class.
4. Game creates a new save state.
5. Game loads the first Swamp Outskirts room.

Continue:
1. Checks for a valid save.
2. Loads the most recent save if present.
3. If no save exists, shows an empty-state message or disabled button state.

Settings:
1. Allows audio volume changes.
2. Allows display/window mode changes if practical in the first implementation.
3. Settings persist in save/config data.

## First Area

The first area is Swamp Outskirts. It is shared by all classes and should teach the game without feeling like a narrow tutorial.

Target room flow:
1. Safe start room for movement and atmosphere.
2. Movement room with basic jumps and class feel.
3. First enemy room.
4. Hazard room using swamp hazards, water, vines, or traps.
5. Locked route that foreshadows a traversal/tool requirement.
6. Checkpoint shrine room.
7. Upgrade room with the first class-relevant traversal or tool unlock.
8. Return loop that uses the new upgrade.
9. Shortcut back toward the checkpoint or start path.
10. Mini-boss room.

The mini-boss must be fair for all three classes:
- Warden can block or parry clear openings.
- Gunslinger can control spacing and exploit weak points.
- Hexbinder can evade and apply control effects.

## Class Foundations

### Warden

The first slice should make Warden feel durable and committed.

Baseline:
- Melee regular attack
- Block or guard state
- Higher health or armor
- Slower recovery than the other classes

First traversal/tool direction:
- Armored dash, shield-bash break, or wall-brace/climb

First attack skill direction:
- Guard counter, ground slam, shield throw, or charged cleave

### Gunslinger

The first slice should make Gunslinger feel fast, ranged, and technical.

Baseline:
- Ranged regular attack
- Reload, ammo, heat, or cooldown pressure
- Slide or evasive movement
- Weak close-range fallback

First traversal/tool direction:
- Hookshot/grapple, combat slide, recoil jump, or trick-shot switch

First attack skill direction:
- Piercing shot, ricochet shot, fan fire, explosive round, or trap shot

### Hexbinder

The first slice should make Hexbinder feel fragile, evasive, and controlling.

Baseline:
- Spell projectile regular attack
- Mana, charge, or cooldown resource
- Low health
- Evasive movement

First traversal/tool direction:
- Blink, float/fall control, or phase-through cursed barrier

First attack skill direction:
- Curse bolt, binding sigil, soul flare, hex mine, chain curse, or void lance

## XP And Leveling

Players earn XP from:
- Normal enemies
- Mini-bosses
- Bosses
- Discoveries
- Major progression events

Leveling should be present in the first slice. Level-up rewards can be simple at first:
- Increased max health, resource pool, attack power, or defense
- Skill point awards
- Eligibility for attack-skill upgrades

XP and levels must be saved. Death does not remove earned levels. Traversal unlocks still control major map progression.

## Save And Checkpoint Rules

Checkpoint shrines have two jobs:
- Set the respawn point.
- Write save data.

Save data for the first slice should include:
- Selected class
- Selected sprite
- Current level and XP
- Skill points
- Learned attack skills
- Current area and room
- Checkpoint position
- Health and class resources
- Acquired traversal/tool upgrades
- Defeated mini-boss state
- Opened shortcut state
- Collected one-time pickup state
- Settings

Death behavior:
- Respawn at the last checkpoint shrine.
- Keep XP, levels, learned skills, traversal unlocks, shortcuts, and major progress.
- Reset temporary room state.

Room re-entry behavior:
- Normal enemies respawn when the player leaves and re-enters a room.
- Bosses and mini-bosses stay defeated.
- One-time pickups stay collected.
- Shortcuts stay open.
- Checkpoints stay active.

## Technical Direction

This is a Godot 4.6 project, so the implementation should use Godot scenes and resources.

Recommended structure:
- `Main.tscn`: boot/root scene and screen transitions
- `TitleScreen.tscn`: New Game, Continue, Settings
- `CharacterSelect.tscn`: class and sprite selection
- `GameWorld.tscn`: loads current area/room and player
- `Player.tscn`: shared player shell
- `ClassData` resources: stats, abilities, XP curves, skill lists, sprite options
- `SaveManager`: save/load current slot, checkpoint state, settings
- `CheckpointShrine.tscn`: save and respawn interaction
- `SwampOutskirts` scenes: first rooms, hazards, enemies, shortcut, mini-boss

Class behavior should be data-driven where practical. Avoid hardcoding every class choice into one large player script.

## Verification Targets

The first slice is successful when:
- New Game reaches class selection.
- Each class can select at least one sprite variant and enter gameplay.
- Continue loads a saved run.
- Settings persist.
- Each class can move, attack, use its first class identity, gain XP, and level up.
- Checkpoint shrines save and set respawn.
- Death respawns at the active checkpoint.
- Normal enemies respawn after leaving and re-entering a room.
- Boss, shortcut, and one-time pickup state persist.
- Each class can unlock the first traversal/tool upgrade.
- Each class can complete the return loop and beat the mini-boss.
