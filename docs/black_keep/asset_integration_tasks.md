# Asset Integration Tasks

This document converts the asset audit into production tasks for the first
milestone. It does not replace the audit; it lists what must be integrated,
tested, or rejected before gameplay work can stabilize.

## Goals

- Pick prototype-ready assets for milestone implementation.
- Avoid blocking systems work on final art.
- Identify the exact sheets that need slicing.
- Keep placeholder use explicit.
- Make the first route look finished enough for meaningful playtests.
- Integrate the CharacterCreator2D source package through the Godot-native creator, recipe, morph, and sheet-baking pipeline.

## Import Settings

Pixel art import settings:

- Filter off.
- Mipmaps off.
- Lossless compression.
- Repeat disabled unless the tile or parallax use requires it.
- Use nearest-neighbor scaling.
- Keep source art unmodified.
- Store cleaned or sliced output in a clearly named derived asset folder.

Godot resource expectations:

- Character animations should become `SpriteFrames` resources or equivalent
  reusable animation resources.
- CharacterCreator2D output should become recipes plus generated `SpriteFrames`;
  Unity is not part of the production export path.
- Tile sets should become `TileSet` resources with collision assigned.
- Parallax layers should be separated by depth.
- VFX should be imported as reusable animation resources.

## Playable Prototype Assets

### The Ronin

Source candidate:

- `SpriteVania Assets/player/samurai`

Tasks:

- Map frame ranges to idle, walk, run, jump, fall, attack, hurt, death, dash,
  dash-strike, and special.
- Create first `SpriteFrames` resource.
- Scale test against current player collision.
- Create three-hit combo animation mapping.
- Create dash-strike animation mapping.
- Create dive-bomb animation mapping.
- Document missing or faked animations.

Acceptance:

- Ronin can run, jump, attack, dash, dash-strike, and take damage in the import-test
  scene.

### The Arc-Gunner

Source candidate:

- `SpriteVania Assets/craft pix characters/SWAT_1`

Tasks:

- Slice 128px-tall horizontal sheets.
- Map Shot, Recharge, Run, Walk, Idle, Jump, Hurt, Dead, and Special.
- Add projectile muzzle marker.
- Add magic or arc projectile VFX placeholder.
- Create reload or heat feedback placeholder.
- Test controller aim and attack readability.

Acceptance:

- Arc-Gunner can fire a visible projectile that damages a dummy target.

### The Iron Knight

Source candidate:

- `SpriteVania Assets/player/player_generic`

Tasks:

- Use as technical prototype only.
- Map attacks, shield block, climb, roll, jump, run, idle, hit, and death.
- Retheme palette only if quick and non-destructive.
- Use shield block as guard prototype.
- Use roll or shield movement as dash placeholder.
- Document final-art risk.

Acceptance:

- Iron Knight proves heavy melee and guard behavior, even if final art changes.

### The Black Witch Of Ash

Source candidate:

- `SpriteVania Assets/craft pix characters/Witch_3`

Tasks:

- Slice 128px-tall sheets.
- Handle Charge sheet exception separately.
- Map attack, charge, special, idle, run, jump, hurt, and death.
- Add ash VFX overlay.
- Create Ashen Hexburst tag attack placeholder.
- Test recruitment scene scale against starter characters.

Acceptance:

- Witch can tag in, perform Ashen Hexburst, and remain readable beside starter
  characters.

### The Shadow

Current status:

- Final sprite not locked.
- `magic_cliffs_player` is useful for movement but does not visually read as
  Shadow without palette or silhouette work.

Tasks:

- Search current asset folders for stronger stealth, ranger, scout, archer, or
  rogue candidates.
- If no stronger candidate exists, create a prototype Shadow from
  `magic_cliffs_player` with a dark palette pass.
- Define bow, dagger, or hybrid attack placeholder.
- Create Silent Arrowfall tag attack placeholder.
- Document final-art risk.

Acceptance:

- Shadow can be rescued, named, added to party, and used in three-character
  swap tests.

## Enemy Assets

First standard patrol enemy:

- Pick from current enemy sprite sheets or CraftPix character enemies.
- Must have idle or walk, attack, hurt, and death frames.

Small crawler:

- Use existing crawler if current implementation already has one.
- Add dash-strike vulnerability tag.

Cursed samurai:

- Use Samurai or DarkKnight support from audited folders.
- Needs patrol, attack, hurt, and death.

Oni brute:

- Use demon, minotaur, or oni-adjacent sprite until final oni art is selected.
- Needs readable heavy windup.

Ranged guard:

- Use archer, rifle, or magic projectile-capable sprite.
- Needs clear aim/windup.

Tasks:

- Create enemy animation resource per archetype.
- Assign collision and hurtboxes.
- Assign attack hitboxes.
- Assign patrol path test scene.
- Add source path notes to asset audit.

Acceptance:

- Each milestone enemy can patrol, attack, be hit, die, and respawn.

## Boss Assets

Masakiro phase 1:

- Needs samurai lord or armored sword fighter sprite.
- Must support sword attack, hurt, and death or defeated pose.

Masakiro phase 2:

- Can reuse phase 1 with commander VFX and adds.

Masakiro phase 3:

- Needs oni escalation overlay or alternate sprite.
- Can use VFX and palette shift for milestone prototype.

Tasks:

- Select phase 1 source asset.
- Select oni overlay or phase 3 source asset.
- Create arena-scale size test.
- Create attack readability test.
- Document any missing boss animation frames.

Acceptance:

- Boss can be fought in a prototype arena with readable attacks and defeat
  state.

## Tile And Terrain Assets

Modern City Outskirts:

- Needs street ground, background buildings, road props, and barriers.
- If full city tiles are weak, build a short staging route with modern props and
  strong parallax silhouette.

Rural Swamp Road:

- Needs road-to-swamp blend, broken signs, grass, mud, and Keep silhouette.

Swamp Outskirts:

- Needs finished tree compositions, readable terrain, hazards, and parallax.

Castle Gate:

- Needs causeway, broken portcullis, castle wall, shrine approach, and dark
  atmosphere.

Samurai Castle Wing:

- Needs outer wall, patrol hall, watchpost, prison, boss arena, and seal room.

Sakuramori Court:

- Needs cherry trees, shrine, save point, hub props, and NPC staging.

Tasks:

- Create one tile source list per milestone zone.
- Create Godot `TileSet` resources.
- Add collision to solid terrain.
- Add one debug test room per tile set.
- Record missing terrain needs.

Acceptance:

- Each milestone zone has enough tiles for one representative room before full
  route construction begins.

## VFX And UI Assets

Required VFX:

- Hit spark.
- Enemy hit flash.
- Dash trail.
- Double-jump burst.
- Wall contact dust.
- Dash-strike slash or impact.
- Dive-bomb impact.
- Ashen Hexburst.
- Silent Arrowfall.
- Projectile muzzle flash.
- Save shrine activation.
- Rising Torii Seal pickup.

Required UI:

- Controller glyphs or fallback text labels.
- Party HUD slots.
- HP/resource bars.
- Momentum rings.
- Familiar level indicator.
- Save-slot cards.
- Settings tab icons or labels.

Tasks:

- Select placeholder VFX from Pixel Effects first.
- Create missing VFX as simple generated or scripted effects only when needed.
- Keep UI placeholders clean and readable.
- Add reduced-motion fallback for each major effect.

Acceptance:

- Combat and traversal feedback is readable before final polish.

## Derived Asset Naming

Use stable derived asset names:

- `ronin_prototype_frames`
- `arc_gunner_prototype_frames`
- `iron_knight_prototype_frames`
- `witch_ash_prototype_frames`
- `shadow_prototype_frames`
- `enemy_patrol_basic_frames`
- `enemy_crawler_frames`
- `enemy_cursed_samurai_frames`
- `enemy_oni_brute_frames`
- `boss_masakiro_phase1_frames`
- `boss_masakiro_oni_overlay_frames`

Do not overwrite source asset files.

## CharacterCreator2D Integration Tasks

Source:

- `SpriteVania Assets/Base Fantasy v1.99.unitypackage`

Tasks:

- Preserve the full package payload in the generated manifest.
- Keep Godot-loadable runtime assets separate from ignored raw reference assets.
- Generate complete base and aim animation export inventory.
- Build Godot-native recipe resources for selected parts, palettes, morph values, content-pack IDs, and export profile IDs.
- Build layered rig preview scene for the in-game creator and separate Character Studio app.
- Add morph controls for safe transform-based changes first: height, width, head size, limb proportions, posture, weapon scale, and cape volume.
- Add per-part mesh/lattice morphing only after transform morphs validate.
- Add checklist-driven bulk export UI with first-slice, movement, combat, all-base, all-aim, and custom sets.
- Bake selected rig animations into transparent sheets.
- Generate Godot `SpriteFrames`, import manifest, contact sheet, and recipe provenance.
- Add validation for collision fit, frame bounds, missing animations, transparency, pivot stability, and small-scale readability.

Acceptance:

- No Unity editor or Unity runtime is needed to create, preview, morph, bulk-export, or import a character.
- A recipe can be saved, reloaded, validated, baked, and assigned to the player.
- `all_base` and `all_aim` checklists expose the complete imported CC2D animation inventory.
- Headless import and runtime assignment tests pass.

## Open Questions

- Which folders contain the best Shadow candidate?
- Which exact tree tiles should replace the unfinished first-stage trees?
- Which enemy asset has the clearest attack windup?
- Does Masakiro need custom art before the first prototype boss pass?
- Should the derived assets live under `assets/black_keep/` or a different
  project convention?
- Which CharacterCreator2D morph controls are safe enough for in-game use versus Character Studio only?
