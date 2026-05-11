# The Black Keep — Master Plan

**Working title:** The Black Keep  
**Repo:** DocDamage/SpriteVania  
**Branch target:** `temporary-full-assets`  
**Document purpose:** GitHub-ready master design plan for the reimagined castle/portal game.  
**Status:** Planning document. Not final implementation code.

---

## 1. Project Identity

The Black Keep is a real-time hybrid action RPG / Metroidvania built from the current SpriteVania Godot project.

The game is inspired by the older Chroma’s Edge / Orion documents, but it is not Chroma’s Edge canon. The older documents remain useful for structure: a World Break, relic/pedestal misdirection, a large recruitable cast, affinity-style pair content, accessibility goals, endgame structure, and long-form RPG systems. The new game replaces Orion, the Lattice, Nix, Dominion, ATB, and the 13 fixed party members with a new world, new cast, real-time tag combat, The Black Keep, and player-named heroes.

### Core premise

The Black Keep is a demonic castle rooted in the real world near modern city outskirts and a rural swamp road. Its portals open into pocket dimensions from different points in time and space. The Keep is ruled by layered forces: a cursed royal line, a cult, a magical military order, a living demonic Core, and a deeper ancient evil older than the Keep itself.

The Feudal Japan-inspired time fragments are the main story identity, but they are scattered through the Keep instead of existing as one continuous zone.

---

## 2. Current Repo Progress Snapshot

The project already has a working Godot vertical slice foundation:

- Title, continue, settings, and character selection flow.
- Placeholder playable classes with movement/combat abilities.
- Save/continue state.
- Room transitions, traversal gates, shortcuts, hazards, enemy contact damage, checkpoint respawn, pause saving, and boss-gated exits.
- Swamp Outskirts route.
- HUD feedback for health, resource, XP, level, upgrades, current room, and map discovery.
- Familiar progression.
- Castle Gate groundwork.

The current Black Keep title screen work has advanced beyond the older placeholder title screen:

- `TitleScreen.tscn` uses `res://SpriteVania Assets/title_screen_black_keep.png`.
- The title reads `THE BLACK KEEP`.
- Menu buttons now include Continue, New Game, Load Game, Settings, Accessibility, Extras, Credits, and Quit.
- The title screen has parallax-style background motion, a Moon Sky layer, weather/polish layers, petals/fog/rain/star effects, a vignette, and a version label.
- `title_screen.gd` exposes signals for all expanded menu buttons.
- `Main.gd` routes Load Game, Accessibility, Extras, Credits, Settings, Continue, and Quit.
- Settings has grown into a tabbed menu with General, Audio, Video, Gameplay, Controls, and Accessibility.
- Tests now cover title-screen art/import safety, parallax, weather/polish layers, menu order, title signals, settings tabs, expanded settings persistence, clamping, reset defaults, and bindings.

---

## 3. Chroma’s Edge / Orion Usage Rule

Use the old documents as inspiration only.

### Keep as inspiration

- World Break structure.
- False relic / true relic style misdirection.
- Act 1 catastrophe and Act 2 restoration.
- Affinity/pair-combo idea.
- Large systems thinking: equipment tiers, accessibility, settings, save data, endgame, optional bosses.
- The idea that major powers stabilize or destabilize reality.

### Replace completely

- Orion as setting.
- The Lattice and Progenitor Engine names.
- Nix as the only activation/interface character.
- Dominion as named faction.
- The fixed 13 Chroma’s Edge party members.
- ATB combat.
- Summon-owner canon.

The Black Keep should treat all playable heroes as seal-bearers. Every playable character can activate portals and seals, but each does it through their own animation/lore style.

---

## 4. First Milestone Target

The first milestone should prove the final game identity while remaining buildable:

```text
Title Screen
→ Character Creation: choose Ronin / Arc-Gunner / Iron Knight
→ Modern City Outskirts
→ Rural Swamp Road
→ Swamp Tutorial
→ Castle Gate
→ Damaged Shrine
→ Recruit The Black Witch of Ash
→ Full active-party UI unlocks
→ Momentum / tag-swap tutorial
→ Samurai Castle Wing
→ Stealth/rescue section
→ Rescue The Shadow
→ Player names The Shadow
→ Three-character active party online
→ Boss: Lord Masakiro, Warlord of the Black Keep
→ Masakiro is consumed by the oni after defeat
→ Unlock Rising Torii Seal
→ Enter Sakuramori Court
→ Meet High Priestess Harune
→ Moonpetal Passage hinted, not fully unlocked
```

### First milestone active party

By the end of the Samurai Castle Wing:

1. Player-chosen starter.
2. The Black Witch of Ash.
3. The Shadow.

This supports the first complete test of:

- Three-character active party.
- One visible character at a time.
- Mid-fight swapping.
- Individual HP/resource bars.
- Individual Momentum rings.
- Tag-entry attacks.
- KO auto-switching.
- Benched active-character recovery.
- Hub party management.

---

## 5. Main Menu and Settings Plan

### Title screen

Use the uploaded castle/cherry-blossom pixel-art image as the production title-screen identity.

Title-screen state:

- Game title: `THE BLACK KEEP`.
- Menu stack: Continue, New Game, Load Game, Settings, Accessibility, Extras, Credits, Quit.
- Visual layers: background image, Moon Sky overlay, weather layer, polish layer, vignette, dark left gradient, build/version label.
- Motion options: title parallax, stars, rain, fog, petals; all disabled/reduced when reduced motion is enabled.

### Settings menu

Current tab set:

- General
- Audio
- Video
- Gameplay
- Controls
- Accessibility

Future expanded tab set:

- Gameplay
- Combat
- Controls
- Display
- Audio
- Interface
- Accessibility
- Language/Text
- Save & Data

### Settings persistence direction

The current settings are saved into existing save data and must not create a blank save. Future work should split settings into:

- Global settings file: `user://black_keep_settings.json`
- Save-specific settings inside save files.

This allows settings to persist even before a save exists.

### Combat-specific settings to add

- Combo Timing: Story, Normal, Technical, Expert.
- Momentum refill feedback.
- Tag attack camera intensity.
- Auto-swap on KO.
- Damage numbers.
- Enemy HP bars.
- Hit pause slider.
- Aim assist.
- Swap input style.

---

## 6. Playable Roster

The base game has 8 playable characters: 6 main characters and 2 secret characters. There is also a New Game+ secret character.

| Slot | Title | Role | Status |
|---|---|---|---|
| 1 | The Ronin | Samurai / sword fighter | Starter option or later recruit |
| 2 | The Arc-Gunner | Modern soldier / magically infused gunner | Starter option or later recruit |
| 3 | The Iron Knight | Tank / knight / Black Keep survivor | Starter option or later recruit |
| 4 | The Black Witch of Ash | Mage / witch / ash-seal ritualist | Required first recruit, not starter-selectable |
| 5 | The Shadow | Ranger / scout / infiltrator | Required early recruit |
| 6 | The Gadgeteer | Scientist / gadget user | Recruitable |
| 7 | The Blood-Marked | Demon-touched berserker | Secret, before final dungeon |
| 8 | The Yokai-Bound | Monster / yokai hero | Secret, before final dungeon |
| NG+ | The Fallen Shogun | Samurai lord / possible ally | New Game+ only |

### Naming rule

The player names each playable character immediately during recruitment. Titles remain fixed.

Example:

```text
Name: [Player chosen]
Title: The Black Witch of Ash
```

### Starter choices

Only these 3 are selectable at character creation:

- The Ronin.
- The Arc-Gunner.
- The Iron Knight.

The Witch and Witch-associated titles are not selectable at character creation.

All 3 starters begin in the same modern city outskirts / rural swamp road sequence, but each has different dialogue and motivation.

---

## 7. Party and Combat Model

The Black Keep is real-time, not ATB.

| System | Rule |
|---|---|
| Active party | 3 characters |
| Visible character | 1 on screen |
| Mid-fight swap | Unlimited among active 3 |
| Swap cost | Small Momentum cost |
| Momentum meter | Individual per character |
| Combo reward | Maintaining combo replenishes Momentum |
| Tag attack | Incoming character performs unique entry attack |
| Combo difficulty | Changeable in options |
| KO behavior | Auto-switch to another living active character |
| Benched active party | Slowly recovers |
| Reserve roster | Gains partial XP |
| Full roster changes | Only at Cherry Blossom Court hubs |

### Momentum

Momentum is the swap meter. It appears as a circular icon around each swap button.

Visual states:

- Full ring: swap ready.
- Partial ring: partially charged.
- Dim/cracked ring: insufficient Momentum.
- Flash ring: perfect swap.
- Flowing streak/petal effect: combo maintained and Momentum refunded.

### Combo timing options

- Story: generous combo window, easy Momentum refund.
- Normal: default.
- Technical: shorter window, larger reward.
- Expert: strict timing, highest reward.

---

## 8. Character Quest Structure

Every base-game playable character has 3 personal quests.

| Quest | Purpose | Reward |
|---|---|---|
| Quest 1 | Recruitment / naming / personal motivation | Character joins |
| Quest 2 | Mastery quest | Ultimate weapon |
| Quest 3 | Identity quest | Final costume + upgraded tag attack |

These quests are mandatory for main story 100% completion, but they do not block beating the game.

Base game target:

```text
8 characters × 3 quests = 24 character quests
```

New Game+ target:

```text
Fallen Shogun altered Samurai Castle Wing route
+ optional mastery quest
+ optional identity quest
= up to 3 NG+ character quests
```

Full character-content target:

```text
24 base quests + 3 NG+ quests = 27 total character quests
```

---

## 9. First Three Recruits

### The Black Witch of Ash

- First required recruit.
- Found at a damaged shrine near Castle Gate.
- Not available at character creation.
- Player names her during recruitment.
- Introduces seal logic, demonic rules, and tag-swap combat.

#### First tag attack: Ashen Hexburst

The Witch enters in a burst of black ash, pulls nearby enemies inward, staggers them, and marks them with Ashbrand. Ashbranded enemies take bonus damage from the next active character attack.

Role: offensive crowd control.

### The Shadow

- Third recruit.
- Found in Samurai Castle Wing as a captured prisoner/scout.
- Origin: another portal world, not modern and not Japan.
- Origin realm: The Umbral Marches.
- Weapon: Riftbow Carbine, a rifle-bow hybrid.
- Backup weapon: dagger / short sword.
- Player names them during rescue.

#### First tag attack: Silent Arrowfall

The Shadow enters from a blind angle, fires a spread from the Riftbow Carbine, pins/slows grouped enemies, and marks the strongest target. If close, a dagger follow-up becomes available.

---

## 10. Early Story Zones

### Modern City Outskirts

Opening real-world setting. The player sees modern civilization before the Keep fully intrudes.

### Rural Swamp Road

Transition from modern world into liminal danger. The current Swamp Outskirts vertical slice should remain and be adapted to this opening.

### Castle Gate

The first true arrival at The Black Keep. The damaged shrine and Witch recruitment occur here.

### Samurai Castle Wing

First major Feudal Japan combat dungeon. Contains:

- Human soldiers.
- Cursed samurai.
- Oni.
- Stealth/rescue section.
- The Shadow as prisoner/scout.
- Lord Masakiro boss.
- Rising Torii Seal reward.

### Sakuramori Court

First Cherry Blossom Court hub. Peaceful when first found. Safe but visibly damaged after the World Break.

Leader: High Priestess Harune.

---

## 11. Hubs

All hubs are Cherry Blossom Courts, but each is a different time-fragment version of the idea.

### First hub: Sakuramori Court

A protected cherry-blossom refuge hidden inside The Black Keep’s portal network.

Main NPC:

- High Priestess Harune.
- Public role: shrine priestess, healer, ritual guide, hub leader.
- Secret role: hereditary vessel/guardian of the Moonpetal Seal of Time.

### Hub systems

Every major hub should support:

- Character switching.
- Renaming.
- Save shrine.
- Inn/healing.
- Shop.
- Blacksmith.
- Quest board.
- Dialogue archive.
- Crafting.
- Training room.
- Bestiary.
- Palette/costume variants.
- Day/night NPC schedules.

After the World Break, hubs remain safe but NPCs, shops, quests, routes, and visuals change.

---

## 12. Time and Fast Travel

### Moonpetal Seal of Time

High Priestess Harune is secretly connected to the late-game Time seal.

### Moonpetal Passage

The hub/time-travel/fast-travel system.

Functions:

- Fast travel between discovered Cherry Blossom Courts.
- Shift hubs between day/night states.
- Later: access special pre-World Break / post-World Break hub quest states.
- Stabilize a final tower checkpoint/floor.

Limits:

- It should not freely rewrite the entire world.
- It should not skip locked story dungeons.
- It should only affect hubs and special quest instances.

---

## 13. Relics and Traversal Seals

The old relic/foundation idea becomes Black Keep traversal seals.

Rules:

- One thematic seal per major battle zone.
- Safe hubs do not count as seal zones.
- Optional major zones can have optional seals.
- Optional seals unlock special areas, legendary weapons, armor, accessories, secret bosses, and secret characters.
- Seal rewards primarily unlock global traversal categories.

### First seal: Rising Torii Seal

- Obtained from Samurai Castle Wing.
- Visual: floating moon-petal crest.
- Unlock: vertical ascent.

Every character can use vertical ascent, but each expresses it differently.

Examples:

| Character | Vertical ascent expression |
|---|---|
| Ronin | blade-step wall ascent |
| Arc-Gunner | recoil/arc booster launch |
| Iron Knight | shield brace climb |
| Black Witch of Ash | ash-lift levitation burst |
| Shadow | rope arrow / shadow perch vault |
| Gadgeteer | compact climbing rig |
| Blood-Marked | claw vault / blood leap |
| Yokai-Bound | spirit pounce / yokai float |

No puzzle should require one specific character.

---

## 14. Feudal Japan Structure

Feudal Japan is not one zone. It appears as scattered time fragments throughout The Black Keep.

Story layers:

- Fallen shogun.
- Oni invasion.
- Shrine curse.
- Civil war.
- Different Japan-inspired time fragments.
- Something older than The Black Keep.

Recommended fragments:

| Fragment | Type | Combat? | Purpose |
|---|---|---|---|
| Samurai Castle Wing | Major dungeon | Yes | First Japan combat dungeon |
| Sakuramori Court | Hub | No | First Cherry Blossom Court hub |
| Bamboo Road | Exploration route | Light | Movement/puzzle route |
| Abandoned Shrine District | Relic dungeon | Yes | Seal ritual and priest/yokai lore |
| Oni Cave | Monster dungeon | Yes | Secret boss / secret route |
| Moonlit Village | Hub | Mostly no | Refugees and late quests |
| Red Gate Battlefield | Act 2 combat zone | Yes | Civil war / oni invasion |
| Burning Pagoda or Storm Temple | Late-game dungeon | Yes | Major story climax |

---

## 15. Lord Masakiro Arc

### First boss

Name: Lord Masakiro, Warlord of the Black Keep.

Role:

- Human warlord serving The Black Keep.
- Commands human soldiers, cursed samurai, and oni forces.
- Believes he controls the oni.
- The oni are manipulating him.

Boss phases:

1. Disciplined human warlord combat.
2. Calls soldiers and cursed samurai.
3. Oni “blessing” empowers him, but his control slips.
4. Defeat: oni consume him.

### Later mandatory rematch

Name: Masakiro, the Oni-Worn Lord.

Placement:

- Mandatory Act 2 / post-World Break boss.
- Recommended location: Revisited Samurai Castle Wing or Red Gate Battlefield.

Purpose:

- Shows the consequences of oni manipulation.
- Reuses early villain as a corrupted rematch.
- Confirms the oni are older and deeper than The Black Keep.

---

## 16. Stealth/Rescue Section

The Samurai Castle Wing should include meaningful stealth before rescuing The Shadow.

Structure:

```text
Enter Samurai Castle Wing
→ Patrol tutorial
→ Cursed samurai watchpost
→ Optional perfect-stealth treasure route
→ Overhear oni manipulating Lord Masakiro
→ Prison wing
→ Rescue The Shadow
→ Player names The Shadow
→ Alarm escape sequence
→ Three-character party combat begins
→ Lord Masakiro boss fight
```

Stealth should have fail states:

| Result | Condition | Outcome |
|---|---|---|
| Perfect | no alarms | best optional reward + unique Shadow dialogue |
| Clean | one alarm | normal reward |
| Rough | multiple alarms | harder fights, less treasure |
| Forced combat | repeated detection | miniboss guard appears |
| Story minimum | rescue still succeeds | no softlock |

Perfect stealth rewards:

- Rare crafting material.
- Riftbow Carbine mod.
- Stealth charm accessory.
- Shadow affinity bonus.
- Oni lore note.
- Alternate Shadow dialogue.

---

## 17. World Break Structure

The villain tricks or forces the heroes into causing the World Break.

Effects:

- The Black Keep physically changes.
- Portal worlds change.
- Safe hubs remain safe but visibly damaged.
- NPCs, shops, quests, and routes change.
- Earlier villains and zones return in corrupted forms.
- Masakiro returns as the Oni-Worn Lord.

World Break variants should include both visual and gameplay changes: cracked walls, red sky overlays, corrupted portals, damaged hub parallax, altered shop inventory, changed NPC schedules, and new enemy routes.

---

## 18. Final Dungeon

Final dungeon order:

```text
The Final Tower
→ Inside the Monster’s Belly
→ The Core
```

### The Final Tower

- Long vertical climb.
- Boss gauntlet.
- Requires every major traversal category.
- Each restored seal creates one checkpoint/floor.
- Heavy parallax: storm, falling debris, deep verticality, distant tower layers.

### Inside the Monster’s Belly

- Horror-heavy.
- Literal: the party is swallowed or pulled into the living body of the demon/Keep-heart.
- Animated parallax: pulsing tissue, veins, acid bubbles, rib shadows, breathing walls.

### The Core

Final boss: fusion of demon, tower, monster, and living castle heart.

Multiple endings:

- Destroy the Core.
- Seal the Core.
- Cleanse the Core.
- Take control.
- Bargain with it.
- Hidden/true option, if later desired.

---

## 19. Art Direction and Asset Pipeline

### Palette/style rule

Allow each realm to keep a strong color identity, but all assets must feel like the same game.

Normalize:

- Palette.
- Outlines.
- Scale.
- Brightness.
- Contrast.
- Animation timing.
- UI readability.

### Sprite selection priority

Playable candidates are chosen by animation completeness first.

Required playable target animations:

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

Sprites missing dash/slide/special can still qualify if the missing animations can be faked with VFX/existing frames or generated with Codex image generation and cleaned in Aseprite.

Pipeline:

```text
Candidate sprite selected
→ Check animation completeness
→ Use Codex image generation for missing dash/slide/special/costume frames if needed
→ Clean frame shapes in Aseprite
→ Normalize palette, outline, scale, brightness, contrast
→ Export sprite sheet
→ Import into Godot SpriteFrames
→ Test in motion
```

Higher-resolution painted sprites are acceptable as source material only if later pixel-cleaned in Aseprite.

---

## 20. Parallax Direction

Parallax should be used in every major area.

Minimum layers:

- Far sky/horizon.
- Distant silhouettes.
- Midground architecture/trees/ruins.
- Gameplay layer.
- Foreground atmosphere.
- Weather/particles.
- World Break overlay variant.

Priority parallax zones:

- Title screen.
- Swamp.
- Castle Gate.
- Samurai Castle Wing.
- Cherry Blossom Courts.
- Graveyard.
- Church.
- Final Tower.
- Monster Belly.
- Core.

All hubs should support day/night and weather variants.

---

## 21. Asset Classification Plan

Once all folders are visible, classify every sprite/asset as:

- Playable.
- NPC.
- Enemy.
- Boss.
- Shopkeeper.
- Hub-only.
- Background/parallax.
- UI.
- VFX.
- Tile/terrain.
- Trap/hazard.

Character assets should be sorted by:

1. Animation completeness.
2. Scale compatibility.
3. Readable silhouette.
4. Combat usability.
5. Palette/style match.
6. Role fit.
7. NPC/enemy/boss fallback value.

Monstrous sprites may be considered for both The Blood-Marked and The Yokai-Bound.

---

## 22. GitHub Documentation Plan

Add these files to the repo:

```text
docs/BLACK_KEEP_MASTER_PLAN.md
docs/black_keep/README.md
docs/black_keep/first_milestone.md
docs/black_keep/party_and_combat.md
docs/black_keep/menu_settings_plan.md
docs/black_keep/art_pipeline.md
docs/black_keep/asset_classification.md
docs/black_keep/story_outline.md
```

### Immediate doc update

At minimum, add:

```text
docs/BLACK_KEEP_MASTER_PLAN.md
```

Then update:

```text
docs/implementation_roadmap.md
```

so it no longer only describes the older SpriteVania vertical slice; it should explicitly mention The Black Keep direction.

---

## 23. Codex Tasks

### Task 1 — Add master plan to GitHub

```text
Create docs/BLACK_KEEP_MASTER_PLAN.md using the provided master plan. Add a short link to it at the top of docs/implementation_roadmap.md under a new section called “Current Creative Direction.” Do not remove the existing vertical slice notes; mark them as current implementation foundation. Do not change game code.
```

### Task 2 — Split docs into subdocuments

```text
Create docs/black_keep/ and split the master plan into focused documents: README.md, first_milestone.md, party_and_combat.md, menu_settings_plan.md, art_pipeline.md, asset_classification.md, and story_outline.md. Keep docs/BLACK_KEEP_MASTER_PLAN.md as the single-source overview and link to the subdocuments.
```

### Task 3 — Update roadmap

```text
Update docs/implementation_roadmap.md to include The Black Keep milestone: Title Screen, Character Creation, Modern City Outskirts, Rural Swamp Road, Swamp Tutorial, Castle Gate, Damaged Shrine, The Black Witch of Ash recruitment, Momentum/tag-swap tutorial, Samurai Castle Wing stealth/rescue, The Shadow recruitment, Lord Masakiro boss, Rising Torii Seal, and Sakuramori Court hub.
```

### Task 4 — Add menu/settings roadmap

```text
Add docs/black_keep/menu_settings_plan.md documenting the title screen, main menu buttons, load game screen, settings tabs, settings persistence, global settings file plan, accessibility routing, and remaining work.
```

---

## 24. Open Questions

The following still need decisions or asset review:

1. Which actual sprites become the 8 playable characters.
2. Which assets support Inside the Monster’s Belly and The Final Tower once those folders are visible.
3. Which portal zones exist based on asset coverage.
4. How many traversal seals the final zone list supports.
5. The exact first hub layout for Sakuramori Court.
6. The exact world-break overlay art direction.
7. The Load Game screen final design.
8. Global settings storage implementation.
9. Full party roster data model.
10. Character quest details for all 8 characters.

---

## 25. Short Version

The Black Keep should become the repo’s main game identity:

- Real-time tag-combo action RPG / Metroidvania.
- 8 player-named recruitable characters.
- Active party of 3, one visible at a time.
- Momentum-based mid-fight swapping.
- The Black Keep as central castle/portal structure.
- Feudal Japan time fragments as the main story identity.
- Cherry Blossom Courts as hubs.
- World Break midgame structure.
- Final Tower → Monster Belly → Core as final dungeon.
- Old Chroma’s Edge docs are inspiration, not canon.
- Current repo systems are the implementation foundation.

