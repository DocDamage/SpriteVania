# Asset Decision Log

This document records concrete asset decisions for The Black Keep. It separates
prototype-approved assets from final-art decisions so implementation can move
without pretending every asset is final.

## Decision Rules

- Prototype-approved means the asset can be used to build and test systems.
- Final-approved means the asset is intended to ship after license and style
  review.
- Deferred means the asset stays available but should not block implementation.
- Rejected means do not spend implementation time on it for the named role.
- Every decision should list source path, role, decision, risk, and next action.

## Playable Decisions

### The Ronin

Source path:

- `SpriteVania Assets/player/samurai`

Decision:

- Prototype-approved.

Use:

- First Ronin import test.
- Starter character implementation.
- Sword combo and traversal expression prototype.

Risks:

- Animation labels need manual frame mapping.
- Scale must be checked against current player collision.
- Final palette/style may need cleanup.

Next action:

- Build `ronin_prototype_frames`.
- Map idle, run, jump, fall, attack, hurt, death, dash, dash-strike, and special.

### The Arc-Gunner

Source path:

- `SpriteVania Assets/craft pix characters/SWAT_1`

Decision:

- Prototype-approved.

Use:

- First Arc-Gunner import test.
- Ranged starter implementation.
- Projectile and reload or heat-loop prototype.

Risks:

- Military SWAT read needs magical or arc VFX to fit the Black Keep direction.
- Requires 128-pixel horizontal sheet slicing.

Next action:

- Build `arc_gunner_prototype_frames`.
- Add projectile muzzle marker and arc projectile placeholder.

### The Iron Knight

Source path:

- `SpriteVania Assets/player/player_generic`

Decision:

- Technical prototype only.

Use:

- Heavy melee, guard, shield, roll, climb, and collision prototype.

Risks:

- Visual identity may not read as final Iron Knight.
- Palette and silhouette may need retheme.

Next action:

- Build `iron_knight_prototype_frames`.
- Use shield block as guard prototype.
- Keep final-art risk visible.

### The Black Witch Of Ash

Source path:

- `SpriteVania Assets/craft pix characters/Witch_3`

Decision:

- Prototype-approved.

Use:

- First required recruit.
- Ashen Hexburst tag attack prototype.
- Shrine recruitment scene.

Risks:

- Reads more staff or spear witch than ash ritualist without VFX.
- Charge sheet has different height and needs custom handling.

Next action:

- Build `witch_ash_prototype_frames`.
- Add ash VFX overlay.

### The Shadow

Source path:

- Not final.

Decision:

- Needs asset search before prototype lock.

Temporary fallback:

- `SpriteVania Assets/player/magic_cliffs_player`

Risks:

- Current fallback reads too bright and heroic for stealth/scout identity.
- May need dark palette pass or a different asset.

Next action:

- Search asset folders for rogue, archer, ranger, scout, ninja, thief, or dark
  agile candidates.
- If no stronger candidate exists, create `shadow_prototype_frames` from
  `magic_cliffs_player` with documented palette risk.

### The Gadgeteer

Source path:

- `SpriteVania Assets/craft pix characters/Scientists_1`

Decision:

- Deferred.

Use:

- Gadgeteer or scientist NPC candidate.

Risks:

- Strong identity but missing obvious attack and jump coverage.

Next action:

- Keep for later recruit/NPC review.

### The Blood-Marked

Source path:

- Not selected.

Decision:

- Deferred.

Use:

- Secret demon-touched berserker.

Next action:

- Review demon, brute, werewolf, vampire, or monstrous humanoid assets after
  milestone one.

### The Yokai-Bound

Source path:

- Not selected.

Decision:

- Deferred.

Use:

- Secret yokai or monster hero.

Next action:

- Review yokai, spirit, beast, and monster assets after milestone one.

## Enemy Decisions

### Standard Patrol Enemy

Decision:

- Needs final prototype selection.

Role:

- First enemy tutorial.
- Rural Road and Swamp standard enemy.

Requirements:

- Idle or patrol.
- Move.
- Attack.
- Hurt.
- Death.

Next action:

- Choose the clearest existing enemy or CraftPix character with attack frames.

### Small Crawler

Decision:

- Use existing crawler if current implementation already has one.

Role:

- Dash-strike tutorial target.

Risks:

- Must be low enough to justify dash strike.
- Contact damage must be readable.

Next action:

- Confirm current crawler art and animation coverage.

### Cursed Samurai

Decision:

- Prototype from Samurai or DarkKnight enemy support.

Role:

- Samurai Castle patrol and stronger guard.

Next action:

- Select source path during enemy asset pass.

### Oni Brute

Decision:

- Prototype from demon, minotaur, dragon, or oni-adjacent asset.

Role:

- Samurai Castle threat and Masakiro escalation.

Risks:

- Oni identity may require custom palette or VFX.

Next action:

- Select readable brute asset with heavy attack animation.

### Ranged Guard

Decision:

- Needs source selection.

Role:

- Samurai Castle watchpost.

Requirements:

- Aim or attack windup.
- Projectile or ranged effect.
- Hurt and death.

Next action:

- Review archer, rifle, mage, or guard assets.

## Boss Decisions

### Lord Masakiro

Decision:

- Needs prototype asset selection.

Role:

- First major boss.

Requirements:

- Humanoid sword or warlord silhouette.
- At least two attacks.
- Hurt or stagger.
- Defeat pose or death.
- Supports oni overlay or phase VFX.

Next action:

- Search Samurai, DarkKnight, warlord, knight, shogun, and demon-hybrid assets.

### Masakiro Oni Overlay

Decision:

- Prototype through VFX if no full alternate sprite exists.

Role:

- Phase 3 and later Oni-Worn foreshadowing.

Next action:

- Use red/black aura, oni mask overlay, or demon shadow VFX placeholder.

## Tile And Zone Decisions

Swamp Outskirts:

- Decision: production foundation.
- Need: finished tree composition and screen-fill pass.

Castle Gate:

- Decision: milestone-required.
- Need: causeway, broken portcullis, damaged shrine.

Samurai Castle Wing:

- Decision: milestone-required.
- Need: outer wall, patrol hall, watchpost, prison, boss arena, seal room.

Sakuramori Court:

- Decision: milestone-required.
- Need: entrance, save shrine, party shrine, training yard.

Final Tower:

- Decision: full-game planned, not milestone-required.
- Need: later platforming and parallax review.

## Immediate Asset Sprint

Priority order:

1. Ronin import.
2. Arc-Gunner import.
3. Witch import.
4. Iron Knight prototype import.
5. Shadow candidate search.
6. Standard enemy selection.
7. Crawler confirmation.
8. Cursed samurai selection.
9. Masakiro selection.
10. Swamp tree replacement tiles.
