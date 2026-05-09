# SpriteVania Full-Game Vision

## Purpose

SpriteVania is a large-scope 2D Godot metroidvania built around one shared gothic world and three fully distinct playable classes. The game should feel responsive moment to moment, but still punish careless play through meaningful enemy patterns, damage, checkpoint placement, and resource pressure.

The full-game target is ambitious: 8 or more major biomes, 10 or more bosses, and a 15+ hour campaign vision. This document is the north star; implementation should start with the separate vertical-slice spec.

## Core Structure

The game starts at a title screen with New Game, Continue, and Settings. New Game leads into character selection, where the player chooses both a class and a sprite/visual variant. Continue loads the most recent valid save. Settings include at least audio volume and display/window options.

All classes can complete the same major areas and main critical path. The map should not lock entire required regions behind one class. Instead, each class solves traversal, combat, and secrets differently.

## Playable Classes

### Warden

The Warden is durable, deliberate, and shield-forward. The class should reward timing, positioning, and commitment.

Traversal identity:
- Armored dash
- Shield-bash breaks
- Wall-brace or wall-climb

Combat identity:
- Melee attacks with commitment
- Blocking and parrying
- High survivability
- Slower recovery than the other classes

Attack skills:
- Guard counter
- Ground slam
- Shield throw
- Charged cleave
- Holy or warding burst

### Gunslinger

The Gunslinger is fast, ranged, technical, and spacing-focused. The class should reward mobility, aim, and resource control.

Traversal identity:
- Hookshot or grapple
- Combat slide
- Recoil jump
- Trick-shot switches

Combat identity:
- Pistols or firearm variants
- Ammo or cooldown pressure
- Strong ranged damage
- Weak melee fallback

Attack skills:
- Piercing shot
- Ricochet shot
- Fan fire
- Explosive round
- Charged rail shot
- Trap shot

### Hexbinder

The Hexbinder is fragile, evasive, and control-heavy. The class should feel strange, risky, and clever.

Traversal identity:
- Short blink
- Float or fall control
- Phase-through cursed barriers

Combat identity:
- Spell projectiles
- Bind, slow, or curse effects
- Resource-based casting
- Low durability

Attack skills:
- Curse bolt
- Binding sigil
- Soul flare
- Hex mine
- Chain curse
- Void lance

## Progression

Progression is hybrid. Each class has a mostly fixed sequence of required traversal unlocks so level design remains predictable. Optional side upgrades add class build variety.

The major progression layers are:
- Required traversal unlocks for map gates
- Learned attack skills beyond regular attacks
- Optional combat and utility upgrades
- XP-based leveling
- Class stat growth
- Skill points or upgrade currency from level-ups and discoveries

XP should come from enemies, mini-bosses, bosses, discoveries, and major progression events. XP and levels improve combat power, survivability, resource pools, and optional skill paths. XP should not replace metroidvania gating; traversal upgrades remain the primary map progression tools.

## World And Story

The tone is character-driven plus lore-heavy. Each class needs a personal motive for entering the world, while the larger mystery is told through environments, relics, item descriptions, hidden rooms, NPC hints, and optional discoveries.

The world should be large, interconnected, and readable as one place. Biomes can have distinct mechanics and enemy rosters, but they should connect through shortcuts, return loops, and ability gates.

The first confirmed biome is Swamp Outskirts. Later biomes can draw from the existing asset pack, including castle, cemetery, church, cold corridor, town, horror, wasteland, and sci-fi platforming sets.

## Death, Saves, And Room State

Death uses classic checkpoints. The player respawns at the last activated shrine or save room, keeping permanent progress.

Persistent state includes:
- Selected class and sprite
- XP, level, and skill points
- Learned attack skills
- Required traversal unlocks
- Optional upgrades
- Defeated bosses
- Opened shortcuts
- Collected one-time pickups
- Active checkpoint
- Current area or room
- Settings

Temporary room state resets when appropriate. Normal enemies respawn when the player leaves and re-enters a room. Bosses, shortcuts, one-time pickups, checkpoint activation, and major progression changes persist through save/load.

## Design Pillars

- Three real classes, not cosmetic variants.
- One shared main world that every class can complete.
- Different class solutions instead of class-exclusive required areas.
- Responsive controls with meaningful punishment.
- XP leveling supports combat growth but does not replace traversal gating.
- Normal enemies respawn on room re-entry for replayability, XP, and practice.
- Save/continue is a first-class feature, not a later placeholder.
