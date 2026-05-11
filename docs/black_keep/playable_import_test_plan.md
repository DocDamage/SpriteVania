# Playable Import Test Plan

This plan converts the asset audit shortlist into concrete Godot import tests. It is a planning document only; do not modify game code from this spec until the import-test branch/task begins.

## Purpose

The import tests should prove whether the current asset candidates can support production playable characters before the party-system rewrite begins.

The tests must answer:

- Can the sprite be sliced/imported cleanly?
- Can it match the current player scale and collision footprint?
- Does it have enough animation coverage for movement and combat?
- Does the silhouette read correctly during play?
- Does it need palette, VFX, or frame cleanup before becoming production?

## Import-Test Order

1. `SWAT_1` as The Arc-Gunner.
2. `player/samurai` as The Ronin.
3. `Witch_3` as The Black Witch of Ash.
4. `player_generic` as Iron Knight technical prototype.

Deferred:

- `magic_cliffs_player` for The Shadow.
- `Scientists_1` for The Gadgeteer.

## Shared Acceptance Criteria

A candidate passes import testing when it supports:

- Idle.
- Run.
- Jump.
- Fall or usable fall hold.
- Ground attack.
- Air attack or acceptable air-attack fallback.
- Hurt.
- Death/KO.
- Special or tag-entry placeholder.
- Dash placeholder.
- Slide placeholder.
- Collision shape alignment.
- Camera framing.
- Current room traversal without visual scale mismatch.

## Candidate 1: SWAT_1 as The Arc-Gunner

Source:

```text
SpriteVania Assets/craft pix characters/SWAT_1
```

Known sheets:

- `Idle.png`
- `Run.png`
- `Walk.png`
- `Jump.png`
- `Shot_1.png`
- `Shot_2.png`
- `Recharge.png`
- `Special.png`
- `Hurt.png`
- `Dead.png`

Slicing assumption:

- Most sheets are 128px high.
- Slice as 128x128 frames.

Proof goals:

- Rifle shot reads at gameplay scale.
- Muzzle flash/projectile direction is clear.
- Jump and run match current movement speeds.
- Recharge or Special can stand in for Arc-Gunner skill.
- Dash can be faked with run/shot frame plus VFX.

Risks:

- Military SWAT identity may need arc-magic VFX or palette changes.
- Horizontal rifle poses may need wider attack hitbox/projectile origin tuning.

Decision after test:

- Pass as production Arc-Gunner.
- Pass as prototype only with VFX/palette requirements.
- Defer to Policewoman/SWAT_3.

## Candidate 2: player/samurai as The Ronin

Source:

```text
SpriteVania Assets/player/samurai
```

Known files:

- `PNG/` frame sequence.
- `Character color 2/PNG/` frame sequence.
- `Character color 2/Character 120x120.png` sheet.

Slicing/mapping assumption:

- Individual frames are 120x120.
- Animation names are not obvious from folders.
- Import test must first map frame ranges to idle/run/jump/fall/attack/hurt/death/special.

Proof goals:

- Cyan slash effects read well but do not clash with Black Keep palette.
- Character scale is not too small compared with the current player.
- Frame ranges can be mapped without heavy manual cleanup.
- Basic sword combo feels readable.
- Dash/slide can be faked from existing movement frames if missing.

Risks:

- Smaller silhouette than other candidates.
- Requires manual frame mapping.
- May need scale-up or camera/HUD adjustment.

Decision after test:

- Pass as production Ronin.
- Pass as prototype with scale/palette changes.
- Defer to another Feudal Japan character source.

## Candidate 3: Witch_3 as The Black Witch of Ash

Source:

```text
SpriteVania Assets/craft pix characters/Witch_3
```

Known sheets:

- `Attack_1.png`
- `Attack_2.png`
- `Charge.png`
- `Dead.png`
- `Hurt.png`
- `Idle.png`
- `Idle_2.png`
- `Jump.png`
- `Run.png`
- `Special.png`
- `Walk.png`

Slicing assumption:

- Most sheets slice as 128x128.
- `Charge.png` is 576x64 and needs special handling.

Proof goals:

- Staff/spear silhouette can support the Black Witch of Ash role.
- Special can become Ashen Hexburst or a placeholder for it.
- Charge can support ash-seal ritual effects.
- Run/jump are readable enough for platforming.
- Ash VFX can push identity away from generic staff fighter.

Risks:

- Visual read is more staff/spear than ash ritualist.
- Needs VFX overlay to sell the ash identity.
- Charge sheet height differs from the main slicing convention.

Decision after test:

- Pass as production Witch with VFX requirements.
- Pass as prototype only.
- Compare Witch_1/Witch_2 before final lock.

## Candidate 4: player_generic as Iron Knight Prototype

Source:

```text
SpriteVania Assets/player/player_generic
```

Known folders:

- `Attacks`
- `Climb`
- `Dead`
- `Hit`
- `Idle`
- `Jump`
- `Roll`
- `Run`
- `Shield Block`

Frame assumptions:

- Most frames are 128x96.
- Death frames are 128x128.

Proof goals:

- Validate a full-featured melee character pipeline quickly.
- Shield Block can become Iron Knight guard.
- Climb can support Rising Torii/vertical ascent tests.
- Roll can become dash placeholder.
- Attack arcs are readable.

Risks:

- Reads like agile swordsman, not heavy Iron Knight.
- Palette and silhouette may need retheme.
- Height mismatch with 128x128 CraftPix sheets needs scale policy.

Decision after test:

- Use as Iron Knight production base with retheme.
- Use as melee technical prototype only.
- Replace with stronger knight asset later.

## Deferred Candidate: magic_cliffs_player

Reason deferred:

- Good motion coverage, but visual read is too bright and heroic for The Shadow.
- No clear dash/slide/special.

Potential future use:

- Agile NPC.
- Enemy lieutenant.
- Temporary Shadow motion prototype.
- Source for animation timing reference.

## Deferred Candidate: Scientists_1

Reason deferred:

- Strong Gadgeteer/science identity.
- Lacks obvious attack and jump coverage.

Potential future use:

- Gadgeteer NPC prototype.
- Hub scientist.
- Shop/upgrade NPC.
- Playable Gadgeteer only after combat/jump solution is defined.

## Test Scene Requirements

Create a temporary import-test scene later with:

- Flat ground.
- One step-up ledge.
- One jump gap.
- One wall or vertical ascent test.
- One dummy enemy target.
- One moving enemy target.
- One low ceiling/slide test.
- One dash distance marker.
- Camera framing reference.

## Test Output

Each candidate should produce:

- Imported SpriteFrames or equivalent animation resource.
- Screenshot/contact proof from Godot.
- Animation coverage table.
- Scale/collision notes.
- Decision: production, prototype, deferred, or rejected.

## Open Questions

- Whether CraftPix 128x128 sheets should be scaled down or current player frames scaled up.
- Whether all first milestone playable characters must share the same frame box.
- Whether Iron Knight should prioritize shield/tank silhouette over animation completeness.
- Whether The Shadow should get custom/generated art instead of using existing assets.

