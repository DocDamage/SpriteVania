# Asset Audit Results

This document records the first repository asset audit for The Black Keep. It is based on the actual `SpriteVania Assets/` folder scan and should be refined with image review, scale checks, and in-engine motion tests before final playable selection.

## Audit Status

Status: first-pass folder and filename audit complete.

Not complete yet:

- Visual inspection for every candidate.
- Sprite sheet slicing checks.
- Frame-size normalization checks.
- In-engine animation tests.
- Final playable character decisions.

## Repository Asset Summary

Approximate file counts from `SpriteVania Assets/`:

| Type | Count |
|---|---:|
| `.png` | 4,960 |
| `.gif` | 160 |
| `.psd` | 112 |
| `.ttf` | 76 |
| `.otf` | 68 |
| `.woff2` | 66 |
| `.woff` | 63 |
| `.ase` | 48 |
| `.wav` | 32 |
| `.aseprite` | 26 |
| `.json` | 22 |
| `.svg` | 22 |
| `.ogg` | 13 |

Largest PNG buckets:

| Folder | PNG count | Primary use |
|---|---:|---|
| `SpriteVania Assets/tile sets` | 1,547 | Zone tiles, props, backgrounds, parallax, final dungeon support |
| `SpriteVania Assets/Transitions` | 1,214 | Scene/menu/portal transition masks |
| `SpriteVania Assets/craft pix characters` | 498 | NPCs, recruit candidates, enemies, shopkeepers |
| `SpriteVania Assets/player` | 488 | Highest-priority playable candidate pool |
| `SpriteVania Assets/Hardcore Gandalf` | 426 | Modular character parts, NPCs, companions, UI/HUD pieces |
| `SpriteVania Assets/Pixel Effects` | 351 | Combat/VFX |
| `SpriteVania Assets/Fonts` | 162 | UI typography |
| `SpriteVania Assets/traps and weapons` | 91 | Hazards, traps, weapons, pickups |
| `SpriteVania Assets/Explosions and Power ups` | 48 | Pickups, combat feedback, VFX |
| `SpriteVania Assets/GUI` | 43 | HUD, icons, map icons, buttons, portrait frames |
| `SpriteVania Assets/Bullets` | 30 | Projectiles |
| `SpriteVania Assets/Feudal Japan Background` | 21 | Waterfall/background support |
| `SpriteVania Assets/enemies` | 18 | Current enemy sprite sheets |

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

## Highest-Priority Playable Candidate Pool

These candidates have the strongest animation-folder evidence from the scan. They still need visual inspection and motion tests.

| Candidate path | Possible Black Keep role | Evidence | Missing/risk notes | First-pass decision |
|---|---|---|---|---|
| `SpriteVania Assets/player/player_generic` | Iron Knight / fallback full playable template | 145 PNGs; folders include Attacks, Climb, Dead, Hit, Idle, Jump, Roll, Run, Shield Block | Needs visual role check; may be more generic than final identity | Strongest animation-completeness candidate |
| `SpriteVania Assets/player/samurai` | The Ronin | 152 PNGs; frame sequence folders and Feudal Japan role fit | Filenames are frame-number based; needs sheet/slice mapping and missing animation check | Strongest Ronin candidate |
| `SpriteVania Assets/player/magic_cliffs_player` | Agile starter fallback / Shadow movement reference | 54 PNGs plus spritesheets; attack, crouch-attack, death, fall, hurt, idle, jump, jump-attack, run | No obvious dash/slide/special; visual role may not fit Shadow exactly | Good animation reference or fallback playable |
| `SpriteVania Assets/player/Adventure Character` | Explorer / Ronin fallback / generic hero | 68 PNGs; Air Damage, Falling, Idle, Jumping, Main Attack, Main Attack Air, Walking | Needs run/dash/slide check; style compatibility unknown | Secondary candidate |

## CraftPix Character Candidate Pool

These have enough named action sheets to consider for player, recruit, NPC, enemy, or boss roles.

| Candidate path | Possible role | Evidence | First-pass decision |
|---|---|---|---|
| `SpriteVania Assets/craft pix characters/Witch_1` | The Black Witch of Ash | Attack, Dead, Hurt, Idle, Walk | Candidate Witch; needs scale/style check |
| `SpriteVania Assets/craft pix characters/Witch_2` | The Black Witch of Ash | Attack, Dead, Hurt, Idle, Walk | Candidate Witch; compare against Witch_1 and Witch_3 |
| `SpriteVania Assets/craft pix characters/Witch_3` | The Black Witch of Ash | Attack, Charge, Dead, Hurt, Idle | Strong Witch candidate due to Charge |
| `SpriteVania Assets/craft pix characters/SWAT_1` | Arc-Gunner / modern soldier | Dead, Hurt, Idle, Jump, Recharge, Run | Strong Arc-Gunner candidate; needs attack/projectile mapping |
| `SpriteVania Assets/craft pix characters/SWAT_2` | Arc-Gunner variant | Dead, Hurt, Idle, Jump, Recharge, Run | Variant candidate |
| `SpriteVania Assets/craft pix characters/SWAT_3` | Arc-Gunner variant | Dead, Hurt, Idle, Jump, Recharge, Run | Variant candidate |
| `SpriteVania Assets/craft pix characters/Policewoman` | Arc-Gunner / NPC ally | Attack, Dead, Hurt, Idle, Jump | Possible modern ranged recruit or NPC |
| `SpriteVania Assets/craft pix characters/Policeman_Patrolman` | Modern NPC / enemy / Arc-Gunner fallback | Dead, Hurt, Idle, Jump, Recharge | Useful modern faction asset |
| `SpriteVania Assets/craft pix characters/Scientists_1` | The Gadgeteer / NPC | Dead, Hurt, Idle, Run, Special, Walk | Strong Gadgeteer/NPC candidate |
| `SpriteVania Assets/craft pix characters/Scientists_2` | The Gadgeteer variant | Dead, Hurt, Idle, Run, Special, Walk | Variant candidate |
| `SpriteVania Assets/craft pix characters/Scientists_3` | The Gadgeteer variant | Dead, Hurt, Idle, Run, Special, Walk | Variant candidate |
| `SpriteVania Assets/craft pix characters/Wanderer Magican` | Mage recruit / NPC / boss | Attack, Charge, Dead, Hurt | Possible Witch-adjacent NPC or boss |
| `SpriteVania Assets/craft pix characters/Lightning Mage` | Mage recruit / boss | Attack, Charge, Dead, Hurt, Idle | Good spellcaster candidate |
| `SpriteVania Assets/craft pix characters/Pyromancer_1` | Enemy caster / boss / secret recruit | Multiple attacks, Charge, Dead, Hurt | Strong enemy/boss candidate |
| `SpriteVania Assets/craft pix characters/Demon_1` | Enemy / Blood-Marked fallback | Attack, Charge, Dead, Hurt, Idle, Walk | Enemy first; possible monstrous recruit inspiration |
| `SpriteVania Assets/craft pix characters/Zombie_1-4` | Enemy | Attack, Dead, Hurt, Idle, Walk | Good undead enemy family |
| `SpriteVania Assets/craft pix characters/Trader_1-3` | Shopkeepers | Approval, Dialogue, Idle | Strong shopkeeper pool |
| `SpriteVania Assets/craft pix characters/Priests_1-3` | Shrine NPCs / Harune candidates | Attack, Dialogue, Idle, Special, Walk | Strong hub/shrine NPC pool |

## Current Enemy Pool

`SpriteVania Assets/enemies/` contains compact enemy sheets:

- `DarkKnight.png`
- `Orc_Big.png`
- `Orc_Small.png`
- `Pig_Big.png`
- `Pig_Small.png`
- `Samurai.png`
- `Skeleton_Big.png`
- `Skeleton_Small.png`
- `Wizzart_A.png`
- `Wizzart_B.png`
- `Wizzart_C.png`
- `Zombie_Big.png`
- `Zombie_Small.png`
- Projectile sheets for Orc/Wizzart bullets.

First-pass use:

- Samurai Castle Wing: `Samurai.png`, `DarkKnight.png`, possibly Wizzart as cursed caster.
- Graveyard/Church: Skeleton/Zombie/Wizzart.
- Swamp/early route: Pig/Orc variants if style compatible.

## Zone and Tile Support

| Folder | PNG count | Candidate zones |
|---|---:|---|
| `tile sets/Feudal Japan Stages` | 358 | Samurai Castle Wing, Sakuramori Court, Bamboo Road, shrine districts, burning village, frozen mountain |
| `tile sets/Horror Textures` | 300 | Monster Belly/Core support after pixel-style review, horror interiors |
| `tile sets/Gothicvania Church` | 200 | Church zone |
| `tile sets/SciGo Tiles Platformer` | 179 | Swamp, dark castle, fire, ice, exterior house routes |
| `tile sets/Other Stages` | 136 | Castle, Dark Dungeon, Dark Forest, Fantasy Caves, Moon Graveyard |
| `tile sets/GothicVania-town-files` | 132 | Town/NPC route, title-screen alternates, props |
| `tile sets/Gothicvania Cemetery` | 112 | Graveyard |
| `tile sets/Gothicvania Swamp files` | 77 | Existing swamp route foundation |
| `tile sets/the final tower` | 16 | Final Tower tiles/characters/worldmap |
| `tile sets/Gothicvania Cold Corridors` | 15 | Cold corridor / dungeon route |
| `tile sets/inside the monsters belly` | 10 | Monster Belly final dungeon section |

Feudal Japan stage packs found:

- Burning Village Japan
- Feudal Japan Temple
- Feudal Japan Village
- Frozen Mountain
- Haunted Graveyard
- Mystic Bamboo Forest
- Mystic Sakura Forest
- Sakura Temple

These strongly support the planned Feudal Japan fragments and Sakuramori Court direction.

## Final Dungeon Support

Final Tower files exist under `tile sets/the final tower`, including full-color and TF-color tiles plus `finaltower_worldmap_*` and `finaltower_complete_*` images. This supports keeping Final Tower in the zone plan, but it still needs platformer slicing and parallax/floor planning.

Monster Belly files exist under `tile sets/inside the monsters belly`, including:

- Inside-belly doors.
- Tentacle.
- Cell monsters.
- Heartbeat.
- Giant worm.
- Giant worm terrain.
- Belly tile sheets.

This supports the Monster Belly concept, but the folder is small and likely needs additional VFX/parallax support.

## UI, VFX, Transitions, and Hazards

GUI includes menu buttons, portrait frames, party HUD, map icons, settings/info icons, skillbook/monsterbook/redbook icons, weapon/armor/crafting icons, and screenshots/previews.

VFX support:

- `Pixel Effects`: 351 PNGs.
- `Explosions and Power ups`: 48 PNGs.
- `Bullets`: 30 PNGs.

Hazard/trap support:

- Double-jump arrow.
- Spears.
- Bombs.
- Falling platforms.
- Falling rocks.
- Fans.
- Fire/fire boxes.
- Jumper.
- Moving platforms.
- Arrow shooter trap.
- Spikes.
- Spike ball.
- Shuriken.
- Trap spike run/static.

Transitions include 1,214 PNGs across many mask styles: iris, dissolve, slash, curtain, clock, mosaic, television, star, wipe, zoom, and others. These are strong candidates for portal transitions, menu transitions, and World Break effects.

## First-Pass Role Recommendations

| Black Keep role | Recommended candidate pool | Confidence |
|---|---|---|
| The Ronin | `player/samurai`; Feudal Japan stage characters as backup | High |
| The Arc-Gunner | `craft pix characters/SWAT_*`; Policewoman/Patrolman backup | Medium-high |
| The Iron Knight | `player/player_generic`; `player/Knight`; `player/Special Knight` backup | Medium |
| The Black Witch of Ash | `craft pix characters/Witch_3`, Witch_1/2 backup | Medium-high |
| The Shadow | `player/magic_cliffs_player` as movement base; needs visual role review | Medium-low |
| The Gadgeteer | `craft pix characters/Scientists_*` | Medium |
| The Blood-Marked | Demon/Gladiator/monstrous pool | Medium-low |
| The Yokai-Bound | Demon/Satyr/Dragon/Minotaur pool | Medium-low |
| Harune / shrine NPCs | `Priests_*`, Queen, Girl variants | Medium |
| Shopkeepers | `Trader_*`, Hardcore Gandalf NPC layers | High |
| Early undead enemies | Skeleton/Zombie/Wizzart sheets | High |
| Samurai Castle enemies | `enemies/Samurai.png`, DarkKnight, Feudal Japan pack characters | Medium |

## Locked Decisions

- Animation completeness comes before lore fit.
- Scale compatibility comes before visual role fit.
- The Witch is not starter-selectable.
- The first three starter roles are Ronin, Arc-Gunner, and Iron Knight.
- Monstrous sprites may be candidates for The Blood-Marked or The Yokai-Bound.

## Open Questions

- Which candidate sprites look best after visual inspection.
- Whether CraftPix character scale matches the current player scale.
- Whether `player/samurai` has cleanly identifiable idle/run/jump/fall/attack/hurt/death/special/dash/slide groups.
- Whether Arc-Gunner should use SWAT sheets directly or a cleaned/customized derivative.
- Whether The Shadow needs new art instead of reusing available movement-rich sprites.
- Whether Final Tower and Monster Belly packs need additional parallax and enemy art.

## Implementation Notes

- Next pass should generate contact sheets for candidate playable sprites.
- Test the top 4 playable candidates in Godot before locking the roster.
- Use fallback categories aggressively; a failed playable candidate can still become an NPC, enemy, boss, shopkeeper, or hub character.
- Any generated/painted edits should be cleaned and normalized before becoming production sprites.
- Avoid changing game code until playable selections are made and documented.

