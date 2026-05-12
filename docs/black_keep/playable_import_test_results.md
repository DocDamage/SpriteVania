# Playable Import Test Results

Status: ready-to-run prototype import-test package prepared. In-repo/in-engine execution is still required before marking any candidate as production-passed.

This document records the current prototype decision for milestone one. The user has approved prototype-quality playable sprites for milestone one, provided each candidate has a documented final-art risk.

## Test Scene Added

Temporary scene:

```text
scenes/dev/PlayableImportTestScene.tscn
scripts/dev/playable_import_test_scene.gd
```

The scene creates:

- Flat ground.
- Jump gap.
- Step-up ledge.
- Wall / vertical-ascent test.
- Dash-strike target-lane test.
- Dummy target.
- Moving-target path marker.
- Camera reference.
- Four candidate preview slots.
- Runtime candidate source/coverage scan.

This scene must remain dev-only and must not replace existing playable classes.

## Candidate Order Tested / Prepared

1. `SWAT_1` as The Arc-Gunner.
2. `player/samurai` as The Ronin.
3. `Witch_3` as The Black Witch of Ash.
4. `player_generic` as Iron Knight technical prototype.

## Prototype Decision Summary

| Candidate | Intended role | Current decision | Final-art risk |
|---|---|---|---|
| `SpriteVania Assets/craft pix characters/SWAT_1` | The Arc-Gunner | Prototype-approved | Needs arc-magic VFX, palette pass, projectile-origin tuning |
| `SpriteVania Assets/player/samurai` | The Ronin | Prototype-approved | Needs frame-range mapping, scale check, palette check |
| `SpriteVania Assets/craft pix characters/Witch_3` | The Black Witch of Ash | Prototype-approved | Needs ash VFX overlay; `Charge.png` likely needs custom 64px slicing |
| `SpriteVania Assets/player/player_generic` | The Iron Knight | Technical prototype only | Strong animation coverage but may not read as heavy Iron Knight without retheme |

## Animation Coverage Table

| Required animation | SWAT_1 / Arc-Gunner | player/samurai / Ronin | Witch_3 / Black Witch | player_generic / Iron Knight prototype |
|---|---|---|---|---|
| idle | Present via `Idle.png` | Needs frame mapping | Present via `Idle.png`, `Idle_2.png` | Present via `Idle/` |
| run | Present via `Run.png` | Needs frame mapping | Present via `Run.png` | Present via `Run/` |
| jump | Present via `Jump.png` | Needs frame mapping | Present via `Jump.png` | Present via `Jump/` |
| fall | Needs jump/fall fallback | Needs frame mapping | Needs jump/fall fallback | Likely covered by `Jump/` frames |
| attack | Present via `Shot_1.png`, `Shot_2.png` | Needs frame mapping | Present via `Attack_1.png`, `Attack_2.png` | Present via `Attacks/` |
| hurt | Present via `Hurt.png` | Needs frame mapping | Present via `Hurt.png` | Present via `Hit/` |
| death | Present via `Dead.png` | Needs frame mapping | Present via `Dead.png` | Present via `Dead/` |
| special | Present via `Special.png` / `Recharge.png` | Needs frame mapping or VFX fallback | Present via `Special.png` / `Charge.png` | Can prototype with `Shield Block/`, `Climb/`, or `Attacks/` |
| dash | Fake with run/shot + VFX | Fake with movement/slash frames | Fake with run/special + ash VFX | Prototype via `Roll/` |
| dash_strike | Needs generated/faked frame | Needs generated/faked frame | Needs generated/faked frame | Prototype via `Roll/` or attack fallback |

## Candidate Notes

### SWAT_1 — The Arc-Gunner

Decision: `prototype_approved`.

Reasons:

- Strongest modern gunner read from the audit.
- Has idle, run, walk, jump, shot, recharge, special, hurt, and death sheets.
- Best first target for CraftPix 128x128 slicing pipeline.

Risks:

- Military/SWAT look may be too literal without magical infusion.
- Needs arc-magic muzzle flash, projectile VFX, and possibly palette normalization.
- Dash and dash-strike need faked/generated actions.

Acceptance for milestone one:

- Accept as Arc-Gunner prototype if the shooting pose, run, jump, hurt, and death read cleanly at gameplay scale.

### player/samurai — The Ronin

Decision: `prototype_approved`.

Reasons:

- Strongest Ronin identity match.
- Feudal Japan role alignment is high.
- 120x120 frame sequences and sheet provide enough material to test movement/combat.

Risks:

- Animation names are not folder-separated.
- Requires manual frame-range mapping.
- Smaller/simpler silhouette may require scale adjustment.

Acceptance for milestone one:

- Accept as Ronin prototype if frame mapping can support idle, run, jump/fall, attack, hurt, and KO/death with readable sword motion.

### Witch_3 — The Black Witch of Ash

Decision: `prototype_approved`.

Reasons:

- Strong Witch candidate with attack, charge, hurt, idle, jump, run, special, walk, and death coverage.
- Can support Ashen Hexburst with VFX.
- Good first caster import test.

Risks:

- Reads as a staff/spear witch unless ash VFX and palette push the identity.
- `Charge.png` likely needs special slicing because it differs from the 128x128 convention.
- Dash/dash-strike need faked/generated actions.

Acceptance for milestone one:

- Accept as Witch prototype if the caster silhouette, run/jump, special, hurt, and death read cleanly and Ashen Hexburst can be mocked with VFX.

### player_generic — Iron Knight technical prototype

Decision: `technical_prototype_only`.

Reasons:

- Best broad animation coverage in the current audit.
- Has Attacks, Climb, Dead, Hit, Idle, Jump, Roll, Run, and Shield Block.
- Strong test source for melee, guard, roll/dash, and vertical-ascent animation handling.

Risks:

- May read as agile sword/shield rather than heavy Iron Knight.
- Palette and silhouette may need retheme.
- Frame sizes differ from CraftPix candidates.

Acceptance for milestone one:

- Accept as Iron Knight technical prototype if it validates the melee/guard/roll/climb pipeline. Do not treat it as final Iron Knight art until visual identity is approved.

## Pass / Prototype / Defer / Reject Results

| Candidate | Result |
|---|---|
| SWAT_1 | Prototype-approved for milestone one |
| player/samurai | Prototype-approved for milestone one |
| Witch_3 | Prototype-approved for milestone one |
| player_generic | Technical prototype only |
| magic_cliffs_player | Deferred for The Shadow; does not currently read as scout/ranger |
| Scientists_1 | Deferred for The Gadgeteer until attack/jump coverage is solved |

## Follow-Up Required

- Run `PlayableImportTestScene.tscn` inside Godot.
- Verify source paths exist on the actual checkout.
- Confirm slicing assumptions for CraftPix 128x128 sheets.
- Manually map `player/samurai` frame ranges.
- Produce screenshots or video clips from the import-test scene.
- Update this document with true in-engine results after the scene is executed.

## Do Not Do Yet

- Do not replace current playable classes.
- Do not implement party system.
- Do not lock final character art.
- Do not remove placeholder Warden/Gunslinger/Hexbinder systems until party-system migration is planned.
