# Asset Classification

Once all asset folders are visible, classify every sprite and asset by gameplay
use, visual compatibility, cleanup cost, and fallback value.

## Goals

- Turn raw asset folders into production decisions.
- Select playable, enemy, boss, NPC, hub, UI, VFX, tile, and hazard assets.
- Identify prototype assets separately from final-art candidates.
- Keep source paths traceable.
- Avoid losing useful fallback assets.

## Primary Categories

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
- Audio.
- Font.
- Prototype only.
- Reject.

## Classification Fields

Each classified asset should record:

- Asset path.
- Source pack or folder.
- Category.
- Candidate role.
- Zone or system fit.
- Animation coverage.
- Frame size or sheet size.
- Scale notes.
- Palette and style notes.
- Collision readability.
- Required cleanup.
- Derived asset target.
- Fallback use.
- License or credit note, if known.
- Decision status.

Decision statuses:

- `final_candidate`
- `prototype_candidate`
- `defer`
- `fallback`
- `reject`
- `needs_review`

## Character Sorting Criteria

Character assets should be sorted by:

1. Animation completeness.
2. Scale compatibility.
3. Readable silhouette.
4. Combat usability.
5. Traversal usability.
6. Palette and style match.
7. Role fit.
8. Cleanup cost.
9. NPC, enemy, or boss fallback value.

## Playable Candidate Requirements

Playable characters need enough animation support to sell:

- Movement.
- Combat.
- Traversal.
- Hit reactions.
- Death or KO.
- Upgrades.
- Tag entry.

Required animation target:

- Idle.
- Run.
- Jump.
- Fall.
- Attack.
- Hurt.
- Death.
- Special.
- Dash.
- Slide.

Missing special-case animations can be filled later if:

- Base silhouette is strong.
- Movement reads well.
- Combat reads well.
- Missing frames can be convincingly faked or generated.
- Cleanup cost is acceptable.

## Playable Role Targets

The Ronin:

- Needs sword readability.
- Needs fast melee animations.
- Strong candidates: samurai or ninja-like sprites.

The Arc-Gunner:

- Needs ranged attack readability.
- Needs projectile or muzzle marker.
- Strong candidates: SWAT, police, gunner, or tech soldier sprites.

The Iron Knight:

- Needs heavy silhouette.
- Needs guard, shield, or heavy melee support.
- `player_generic` is a technical prototype unless rethemed.

The Black Witch of Ash:

- Needs spell, staff, or ritual readability.
- Needs special or charge animation.
- Witch candidates are strong.

The Shadow:

- Needs stealth, scout, archer, rogue, or ranger readability.
- Current bright agile candidates need palette or silhouette work.

The Gadgeteer:

- Needs scientist, engineer, or device readability.
- Scientist candidates need attack and jump solutions.

The Blood-Marked:

- Needs demon-touched or berserker readability.
- Monstrous sprites may qualify.

The Yokai-Bound:

- Needs monster, spirit, or yokai readability.
- Monstrous sprites may qualify.

## Area Asset Grouping

Group assets by likely zone:

- Modern City Outskirts.
- Rural Swamp Road.
- Swamp Outskirts.
- Castle Gate.
- Samurai Castle Wing.
- Sakuramori Court.
- Bamboo Road.
- Abandoned Shrine District.
- Oni Cave.
- Moonlit Village.
- Red Gate Battlefield.
- Graveyard.
- Church.
- Cave.
- Dungeon or Prison.
- Forest.
- Town.
- Metroidvania Forge.
- Final Tower.
- Monster Belly.
- Core.

## Enemy And Boss Classification

Enemy candidates should be tagged with:

- Patrol enemy.
- Small enemy.
- Flying enemy.
- Ranged enemy.
- Guard.
- Brute.
- Caster.
- Undead.
- Demon or oni.
- Wildlife.
- Hazard creature.

Boss candidates should be tagged with:

- Humanoid boss.
- Monster boss.
- Giant boss.
- Phase overlay candidate.
- Final boss component.
- Secret boss.
- Rematch form.

Required enemy coverage:

- Idle or patrol.
- Move.
- Attack.
- Hurt.
- Death.

Required boss coverage:

- Idle or stance.
- At least two attacks.
- Hurt or stagger.
- Defeat or death.
- Phase-change support through animation or VFX.

## Terrain Classification

Tile and terrain assets should be tagged with:

- Ground.
- Wall.
- Platform.
- Slope.
- One-way platform.
- Hazard.
- Door.
- Gate.
- Background.
- Foreground.
- Decoration.
- Breakable.
- Traversal gate.

Terrain review should answer:

- Is collision readable?
- Does it support player scale?
- Does it support dash and wall movement?
- Does it tile cleanly?
- Does it need parallax separation?
- Does it need World Break variants?

## UI, VFX, Fonts, And Audio

UI assets should be tagged with:

- Button.
- Panel.
- Icon.
- Controller glyph.
- HUD frame.
- Save-slot card.
- Settings tab.
- Map marker.
- Portrait frame.

VFX assets should be tagged with:

- Hit.
- Slash.
- Projectile.
- Explosion.
- Magic.
- Dash.
- Jump.
- Seal.
- Save.
- Weather.
- Portal.

Fonts should be tagged with:

- Title.
- Heading.
- Body.
- Pixel body.
- Accessibility candidate.
- Unusable.

Audio should be tagged with:

- Music.
- Ambience.
- UI.
- Attack.
- Hit.
- Enemy.
- Boss.
- Movement.
- Weather.

## Classification Output

Preferred output files:

- `docs/black_keep/asset_audit_results.md`
- `docs/black_keep/asset_integration_tasks.md`
- Contact sheets under `docs/black_keep/contact_sheets/`

Each major audit pass should update:

- Candidate decisions.
- Missing art.
- Prototype approvals.
- Rejections.
- Next import tests.

## Acceptance Criteria

A playable candidate is accepted for prototype when:

- It has enough motion coverage for a controlled test.
- Scale can be made compatible.
- The role reads well enough for playtesting.
- Missing animations have a documented workaround.

An enemy candidate is accepted for prototype when:

- It can patrol or idle.
- It can attack.
- It can be hurt.
- It can die or despawn.
- It reads clearly at gameplay scale.

A tileset is accepted for prototype when:

- It can build one representative room.
- Solid surfaces are readable.
- Collision can be assigned cleanly.
- It supports the intended zone mood.

## Open Questions

- Which asset source has the best Shadow candidate?
- Which final tower assets support platforming versus map-only presentation?
- Which Monster Belly assets need custom VFX support?
- Which fonts are legally and visually appropriate for final UI?
- Which source packs require explicit credits in the Credits screen?
