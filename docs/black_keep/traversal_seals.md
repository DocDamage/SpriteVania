# Traversal Seals

Traversal seals replace the older relic/foundation idea. Each major battle zone
grants a global traversal category. Every playable character can use each
required traversal category, but each character expresses it through their own
animation, VFX, and lore style.

## Goals

- Give Metroidvania progression a clear Black Keep identity.
- Avoid hard character gates in required puzzles.
- Support character-specific traversal flavor.
- Let optional zones unlock optional rewards without blocking the main route.
- Keep traversal checks data-driven and testable.

## Rules

- One thematic seal per major battle zone.
- Safe hubs do not count as seal zones.
- Optional major zones can grant optional seals.
- Optional seals can unlock secret rooms, legendary gear, secret bosses, or
  secret characters.
- No required puzzle should demand one specific character.
- Required checks should test unlock category, not character ID.
- Character expressions may differ in animation and feel, but required route
  clearance must remain equivalent.

## Unlock Data

Global unlock fields:

- `seal_rising_torii`
- `seal_wind_bridge`
- `seal_root_whisper`
- `seal_iron_ward`
- `seal_ember_path`
- `seal_deep_moon`
- `seal_shadow_gate`
- `seal_giant_breaker`
- `seal_moonpetal_time`

Traversal categories:

- `vertical_ascent`
- `gap_crossing`
- `narrow_passage`
- `barrier_bypass`
- `hazard_crossing`
- `water_depth`
- `shadow_phase`
- `heavy_break`
- `time_hub_travel`

## Required Seal List

Rising Torii Seal:

- Category: vertical ascent.
- First source zone: Samurai Castle Wing.
- Function: climb or reach high ledges.
- Status: locked first seal.

Wind Bridge Seal:

- Category: gap crossing.
- Candidate source zone: Bamboo Road.
- Function: cross wide gaps, broken bridges, and long air routes.
- Status: planned.

Root Whisper Seal:

- Category: narrow passage.
- Candidate source zone: Abandoned Shrine District or Forest.
- Function: pass through vents, roots, crawl gaps, cracks, or spirit tunnels.
- Status: planned.

Iron Ward Seal:

- Category: barrier bypass.
- Candidate source zone: Church or Dungeon/Prison.
- Function: open magical, demonic, faction, or warded doors.
- Status: planned.

Ember Path Seal:

- Category: hazard crossing.
- Candidate source zone: Red Gate Battlefield or Metroidvania Forge.
- Function: cross fire, poison, spikes, corruption, cursed ground, or ash.
- Status: planned.

Deep Moon Seal:

- Category: water and depth movement.
- Candidate source zone: Cave, flooded shrine, or Moonlit Village route.
- Function: swim, dive, sink, resist currents, or move through flooded routes.
- Status: planned.

Shadow Gate Seal:

- Category: shadow and phase passage.
- Candidate source zone: Graveyard or Shadow-focused route.
- Function: pass through shadow gates, phase walls, mirror gaps, or dusk doors.
- Status: planned.

Giant Breaker Seal:

- Category: heavy break and force movement.
- Candidate source zone: Oni Cave or Metroidvania Forge.
- Function: break heavy blocks, armored doors, machinery, cracked floors, and
  reinforced barriers.
- Status: planned.

Moonpetal Seal of Time:

- Category: time hub travel.
- Candidate source zone: Sakuramori Court quest line and Moonpetal Passage.
- Function: shift hub states, unlock Cherry Blossom Court travel, and access
  special pre-break or post-break quest states.
- Status: planned limited hub system.

## Rising Torii Seal

Locked decisions:

- First seal.
- Obtained from Samurai Castle Wing.
- Unlocks vertical ascent.
- Visual: floating moon-petal crest.

Character expressions:

- Ronin: blade-step wall ascent.
- Arc-Gunner: recoil or arc booster launch.
- Iron Knight: shield brace climb.
- Black Witch of Ash: ash-lift levitation burst.
- Shadow: rope arrow or shadow perch vault.
- Gadgeteer: compact climbing rig.
- Blood-Marked: claw vault or blood leap.
- Yokai-Bound: spirit pounce or yokai float.

Implementation:

- Save unlock as `seal_rising_torii`.
- Route checks query `vertical_ascent`.
- Character animation lookup maps current character to expression.
- Fallback animation is allowed for prototype.

## Character Expression Matrix

Ronin:

- Vertical ascent: blade-step.
- Gap crossing: air-sheathe dash.
- Narrow passage: disciplined low stance.
- Barrier bypass: seal-cutting iaijutsu.
- Hazard crossing: focus guard step.
- Water/depth: breath-discipline glide.
- Shadow/phase: moonlit draw-step.
- Heavy break: charged cleaving cut.
- Time hub travel: ritual bow and blade offering.

Arc-Gunner:

- Vertical ascent: recoil boost.
- Gap crossing: arc booster dash.
- Dash strike: tactical burst through close ground threats.
- Barrier bypass: charged arc shot.
- Hazard crossing: insulated field.
- Water/depth: pressure-sealed kit.
- Shadow/phase: pulse scanner breach.
- Heavy break: explosive breach shot.
- Time hub travel: signal lock on Moonpetal anchor.

Iron Knight:

- Vertical ascent: shield brace.
- Gap crossing: armor burst leap.
- Narrow passage: armor compression crawl.
- Barrier bypass: warded shield push.
- Hazard crossing: shielded march.
- Water/depth: weighted anchor walk.
- Shadow/phase: oath-lit armor pass.
- Heavy break: shield ram.
- Time hub travel: kneeling oath at shrine anchor.

Black Witch of Ash:

- Vertical ascent: ash lift.
- Gap crossing: ash drift.
- Narrow passage: ash-body dissolve.
- Barrier bypass: hex unbinding.
- Hazard crossing: ash ward.
- Water/depth: smoke bubble.
- Shadow/phase: black flame flicker.
- Heavy break: ritual fracture.
- Time hub travel: moon-ash rite.

Shadow:

- Vertical ascent: rope arrow.
- Gap crossing: shadow perch vault.
- Narrow passage: slipstep.
- Barrier bypass: lockshade mark.
- Hazard crossing: cloak step.
- Water/depth: silent current step.
- Shadow/phase: full shadow pass.
- Heavy break: weak-point sabotage.
- Time hub travel: dusk marker.

Gadgeteer:

- Vertical ascent: climbing rig.
- Gap crossing: spring rig or glider.
- Narrow passage: collapsible crawler frame.
- Barrier bypass: lockbreaker tool.
- Hazard crossing: hazard suit mod.
- Water/depth: pressure device.
- Shadow/phase: phase calibrator.
- Heavy break: demolition charge.
- Time hub travel: temporal meter.

Blood-Marked:

- Vertical ascent: blood leap.
- Gap crossing: blood chain lunge.
- Narrow passage: bone-shift crouch.
- Barrier bypass: blood seal rupture.
- Hazard crossing: pain-fed resistance.
- Water/depth: blood-current pull.
- Shadow/phase: demon vein phase.
- Heavy break: berserker smash.
- Time hub travel: blood pact marker.

Yokai-Bound:

- Vertical ascent: spirit pounce.
- Gap crossing: yokai float.
- Narrow passage: spirit shrink.
- Barrier bypass: charm-eating bite.
- Hazard crossing: spirit veil.
- Water/depth: river spirit swim.
- Shadow/phase: yokai veil pass.
- Heavy break: beast slam.
- Time hub travel: shrine-spirit pact.

## Optional Seal Uses

Combat hooks:

- Rising Torii can unlock launcher follow-ups.
- Wind Bridge can unlock air combo extension.
- Root Whisper can unlock low-profile evasions.
- Iron Ward can unlock barrier parry.
- Ember Path can unlock hazard-resistant attacks.
- Deep Moon can unlock water combat.
- Shadow Gate can unlock phase dodge.
- Giant Breaker can unlock armor-break attacks.
- Moonpetal Time can unlock hub-state quests, not free combat rewinds.

Optional gates:

- Secret character route.
- Legendary weapon chambers.
- Boss rematch doors.
- Postgame route variants.
- Final Tower shortcut floors.

## Tests

Automated tests:

- Each seal unlock maps to one traversal category.
- Required gates check category unlock, not character ID.
- Rising Torii unlock enables vertical ascent checks.
- Character expression lookup returns fallback if custom animation is missing.
- Save/load preserves unlocked seals.
- Locked gates stay locked without required seal.
- Optional gates do not block main route.

Manual tests:

- Clear vertical ascent with each active milestone character.
- Confirm gate UI communicates required seal.
- Confirm character-specific expression changes without changing route access.
- Confirm seal pickup cannot be collected twice.

## Locked Decisions

- Rising Torii Seal is first.
- Rising Torii Seal equals vertical ascent.
- Every playable character can use every required traversal category.
- Character-specific expression is visual and mechanical flavor, not hard
  character gating.
- Moonpetal Seal of Time is hub and route state travel, not full free time
  rewinding.

## Open Questions

- Which exact zones award Wind Bridge, Root Whisper, and Iron Ward?
- Which optional seals unlock secret characters?
- How many seals should be required before Final Tower opens?
- Should some traversal seals have mandatory combat tutorials?
- Which seal effects need custom animation versus VFX fallback?

## Implementation Notes

- Store traversal unlocks globally.
- Store character expression data separately from traversal access.
- Keep seal checks in a shared route-gate helper.
- Animation fallback is acceptable if exact frames are missing.
