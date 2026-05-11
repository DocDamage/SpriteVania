# Asset Audit Results

This document records the first repository asset audit for The Black Keep. It is based on the actual `SpriteVania Assets/` folder scan and should be refined with image review, scale checks, and in-engine motion tests before final playable selection.

## Audit Status

Status: first-pass folder, filename, and ImageMagick dimension audit complete.

Not complete yet:

- Final visual inspection decisions from contact sheets.
- Sprite sheet slicing checks.
- In-engine animation tests.
- Final playable character decisions.

## Contact Sheets

ImageMagick contact sheets were generated for the current top candidates:

- [player_generic_frames.png](contact_sheets/player_generic_frames.png)
- [samurai_frames.png](contact_sheets/samurai_frames.png)
- [magic_cliffs_frames.png](contact_sheets/magic_cliffs_frames.png)
- [witch_3_sheets.png](contact_sheets/witch_3_sheets.png)
- [witch_3_sliced_frames.png](contact_sheets/witch_3_sliced_frames.png)
- [swat_1_sheets.png](contact_sheets/swat_1_sheets.png)
- [swat_1_sliced_frames.png](contact_sheets/swat_1_sliced_frames.png)
- [scientists_1_sheets.png](contact_sheets/scientists_1_sheets.png)
- [scientists_1_sliced_frames.png](contact_sheets/scientists_1_sliced_frames.png)

These sheets are for planning review only. Final selection still requires in-engine import, animation timing, collision scale, and style checks.

## Contact Sheet Visual Review

Second-pass visual review from the generated contact sheets:

| Candidate | Visual read | Strengths | Concerns | Recommendation |
|---|---|---|---|---|
| `player_generic` | Dark armored sword fighter with large readable weapon arcs | Strong attack readability, many combat poses, shield block, climb, roll, death, hit, run | More agile swordsman than heavy Iron Knight; red/blue palette may need retint | Import-test as Iron Knight technical prototype; consider final retheme |
| `player/samurai` | Small, fast ninja/samurai silhouette with bright cyan slash effects | Strong Ronin identity, readable sword VFX, good action poses | Smaller/simple silhouette than `player_generic`; animation names are not folder-separated | Import-test as Ronin; requires frame mapping |
| `magic_cliffs_player` | Bright blond agile sword character | Clear agile motion, readable attacks, good jump/fall/death silhouettes | Does not visually read as The Shadow; too bright for stealth/scout role without palette work | Defer for Shadow; keep as agile fallback or NPC/enemy candidate |
| `Witch_3` | Staff/spear-bearing caster with dark clothing and many spell/combat frames | Strong Witch silhouette, run/jump/special/attack coverage, good staff read | Reads more staff/spear witch than ash ritualist; 64px charge sheet is an exception | Import-test as Black Witch of Ash; plan ash VFX overlay |
| `SWAT_1` | Modern rifle-bearing tactical character | Best Arc-Gunner read, strong shot/recharge/run/walk coverage, readable muzzle flashes | Military SWAT identity may need magical/arc VFX and palette pass | Import-test as Arc-Gunner first |
| `Scientists_1` | Yellow hazmat/scientist silhouette | Strong Gadgeteer/science identity, special frames, readable run/walk | No obvious attack/jump sheet; bulky suit may feel slow | Use as Gadgeteer/NPC candidate; defer as playable until combat frames are solved |

## Import-Test Shortlist

See [Playable Import Test Plan](playable_import_test_plan.md) for the detailed test plan.

Recommended first import-test order:

1. `SWAT_1` as The Arc-Gunner.
2. `player/samurai` as The Ronin.
3. `Witch_3` as The Black Witch of Ash.
4. `player_generic` as Iron Knight technical prototype.

Deferred:

- `magic_cliffs_player` for The Shadow unless palette/silhouette edits make it read stealthier.
- `Scientists_1` for The Gadgeteer until attack/jump coverage is solved.

Rejected for immediate playable use:

- `Adventure Character`, due to smaller and inconsistent scale compared with stronger candidates.

## Import-Test Conclusions - Prototype Milestone

The user approved prototype-quality playable sprites for milestone one, as long as final-art risks are documented.

A temporary import-test arena package has been prepared:

```text
scenes/dev/PlayableImportTestScene.tscn
scripts/dev/playable_import_test_scene.gd
docs/black_keep/playable_import_test_results.md
```

The scene creates a flat ground, jump gap, ledge, wall/vertical-ascent test, low-ceiling/slide test, dummy target, moving-target path marker, camera reference, candidate preview slots, and a runtime asset-coverage scan.

### Current Candidate Results

| Candidate | Intended role | Result | Conclusion |
|---|---|---|---|
| `SpriteVania Assets/craft pix characters/SWAT_1` | The Arc-Gunner | Prototype-approved | Use for first Arc-Gunner import test; needs magical gun/VFX and palette pass before final art. |
| `SpriteVania Assets/player/samurai` | The Ronin | Prototype-approved | Use for first Ronin import test; needs manual frame-range mapping and scale check. |
| `SpriteVania Assets/craft pix characters/Witch_3` | The Black Witch of Ash | Prototype-approved | Use for first Witch import test; needs ash VFX overlay and custom handling for 64px charge sheet. |
| `SpriteVania Assets/player/player_generic` | The Iron Knight | Technical prototype only | Use to prove melee/guard/roll/climb pipeline; do not lock as final Iron Knight art without retheme. |

### Deferred Candidates

| Candidate | Reason |
|---|---|
| `SpriteVania Assets/player/magic_cliffs_player` | Motion coverage is useful, but visual identity does not currently read as The Shadow. |
| `SpriteVania Assets/craft pix characters/Scientists_1` | Strong Gadgeteer/scientist identity, but attack/jump coverage needs a custom solution. |

### Next Required Step

Run the import-test scene inside Godot and update `docs/black_keep/playable_import_test_results.md` with true in-engine findings, screenshots, animation coverage, and final pass/prototype/defer/reject decisions.

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
| `SpriteVania Assets/player/player_generic` | Iron Knight / fallback full playable template | 145 PNGs; folders include Attacks, Climb, Dead, Hit, Idle, Jump, Roll, Run, Shield Block; mostly `128x96` frames with Dead at `128x128` | Needs visual role check; may be more generic than final identity | Strongest animation-completeness candidate |
| `SpriteVania Assets/player/samurai` | The Ronin | 152 PNGs; two `120x120` frame folders plus a `720x1560` sheet; Feudal Japan role fit | Filenames are frame-number based; animation labels need mapping before import | Strongest Ronin candidate |
| `SpriteVania Assets/player/magic_cliffs_player` | Shadow movement reference / agile fallback | 54 PNGs plus spritesheets; individual frames are mostly `128x96`; attack, crouch-attack, death, fall, hurt, idle, jump, jump-attack, run | No obvious dash/slide/special; visual role may not fit Shadow exactly | Good animation reference or fallback playable |
| `SpriteVania Assets/player/Adventure Character` | Explorer / generic fallback | 68 PNGs; mixed small individual frames and sheets: `32x32`, `62x41`, `65x58`, `1116x41`, etc. | Scale is much smaller and inconsistent versus main candidates | Lower priority unless style proves useful |

## ImageMagick Dimension and Coverage Pass

Top `player` folder candidates:

| Candidate | Frame/sheet sizes found | Coverage notes | Integration risk |
|---|---|---|---|
| `player_generic` | 128x96 for most folders; 128x128 for death | Attacks 38, Climb 16, Dead 6, Hit 16, Idle 12, Jump 14, Roll 14, Run 12, Shield Block 6 | Best immediate technical fit; needs identity art decision |
| `samurai` | 120x120 individual frames; 720x1560 sheet | 78 color-2 frames, 72 base frames | Strong Ronin fit; needs animation-name mapping |
| `magic_cliffs_player` | 128x96 individual frames; sheets from 256x96 to 1024x96 | Attack 8, crouch-attack 5, death 8, fall 2, hurt 1, idle 4, jump 3, jump-attack 5, run 8 | Useful agile reference; limited hurt/fall and no clear dash/slide |
| `Adventure Character` | Mixed small frames/sheets from 26x30 through 1116x41 | Good basic platformer set but small scale | Lower priority; likely needs scaling/cleanup |

Top CraftPix-style candidates are generally 128px-tall horizontal sheets. Estimated frame counts are width divided by 128 unless noted.

| Candidate | Strong sheets | Coverage notes | Integration risk |
|---|---|---|---|
| `Witch_1` | Attack, Dead, Hurt, Idle, Jump, Run, Special, Walk | Strong complete Witch set; Special has 13 frames | Needs slicing into 128x128 frames |
| `Witch_2` | Attack, Dead, Hurt, Idle, Jump, Run, Spear, Special, Walk | Best if spear identity is desired | Needs slicing; compare silhouette to Witch_3 |
| `Witch_3` | Attack, Charge, Dead, Hurt, Idle, Jump, Run, Special, Walk | Best ash-mage candidate on coverage; Special has 14 frames; Charge is 576x64 | Charge sheet uses 64px height, requiring special handling |
| `SWAT_1` | Dead, Hurt, Idle, Jump, Recharge, Run, Shot, Special, Walk | Strong Arc-Gunner candidate; Run/Walk have 12 frames | Needs slicing and gun/projectile hookup |
| `SWAT_2` | Dead, Hurt, Idle, Jump, Recharge, Run, Shot, Walk | Similar Arc-Gunner variant; lacks Special sheet in scan | Needs slicing; weaker than SWAT_1 for special attacks |
| `SWAT_3` | Dead, Hurt, Idle, Jump, Recharge, Run, Shot, Walk | Strong Shot variants; no Special sheet in scan | Needs slicing; good backup/variant |
| `Scientists_1` | Dead, Hurt, Idle, Run, Special, Walk | Strong Gadgeteer/NPC base; Special has 14 frames | No jump/attack sheet in scan; needs custom combat solution |
| `Policewoman` | Attack, Dead, Hurt, Idle, Jump, Recharge, Run, Shot, Walk | Strong modern ranged character or NPC | Needs slicing; could compete with SWAT for Arc-Gunner |
| `Lightning Mage` | Attack, Charge, Dead, Hurt, Idle, Jump, Light_ball, Light_charge, Run, Walk | Strong mage/boss candidate | Needs role decision; may overlap Witch |
| `Wanderer Magican` | Attack, Charge, Dead, Hurt, Idle, Jump, Magic_arrow, Magic_sphere, Run, Walk | Strong mage/boss/NPC candidate | One charge sheet has non-integer 128px frame estimate; needs slice review |

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
| The Ronin | `player/samurai`; Feudal Japan stage characters as backup | High; import-test after frame mapping |
| The Arc-Gunner | `craft pix characters/SWAT_1` first, SWAT_3/Policewoman backup | High; first import-test target |
| The Iron Knight | `player/player_generic`; `player/Knight`; `player/Special Knight` backup | Medium-high technically; visual identity needs retheme or confirmation |
| The Black Witch of Ash | `craft pix characters/Witch_3`, Witch_1/2 backup | High; add ash VFX to push identity |
| The Shadow | Defer `magic_cliffs_player`; seek darker scout/ranger candidate or custom edit | Low-medium |
| The Gadgeteer | `craft pix characters/Scientists_1`; Scientists_2/3 backup | Medium; lacks obvious attack/jump coverage |
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
- How `player/samurai` frame numbers map to idle/run/jump/fall/attack/hurt/death/special/dash/slide.
- Whether Arc-Gunner should use SWAT sheets directly or a cleaned/customized derivative.
- Whether The Shadow needs new art instead of reusing available movement-rich sprites.
- Whether Final Tower and Monster Belly packs need additional parallax and enemy art.
- Whether `player_generic` should become the final Iron Knight or remain a temporary technical prototype.
- Whether Witch_3's staff/spear read is acceptable for The Black Witch of Ash.

## Implementation Notes

- Next pass should create import-test plans for `SWAT_1`, `player/samurai`, `Witch_3`, and `player_generic`.
- Test the top 4 playable candidates in Godot before locking the roster.
- Prefer direct import tests for `player_generic`, `player/samurai`, `Witch_3`, and `SWAT_1`.
- CraftPix-style sheets need a slicing convention, likely 128x128, with explicit exceptions for 64px-high charge/projectile sheets.
- Use fallback categories aggressively; a failed playable candidate can still become an NPC, enemy, boss, shopkeeper, or hub character.
- Any generated/painted edits should be cleaned and normalized before becoming production sprites.
- Avoid changing game code until playable selections are made and documented.
