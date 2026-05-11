# Traversal Seals

Traversal seals replace the older relic/foundation idea. Each major battle zone should grant a global traversal category. Every playable character can use each traversal category, but each expresses it through their own animation/lore style.

## Rules

- One thematic seal per major battle zone.
- Safe hubs do not count as seal zones.
- Optional major zones can have optional seals.
- Optional seals unlock special areas, legendary gear, secret bosses, and secret characters.
- No puzzle should require one specific character.

## Seal Categories

| Category | Example seal | Function |
|---|---|---|
| Vertical ascent | Rising Torii Seal | Climb/reach high ledges. |
| Gap crossing | TBD | Cross wide gaps. |
| Narrow passage | TBD | Pass through vents, cracks, roots, or spirit gaps. |
| Barrier bypass | TBD | Open magical, demonic, or faction barriers. |
| Hazard crossing | TBD | Cross fire, poison, spikes, corruption, or cursed ground. |
| Water/depth movement | TBD | Swim, dive, sink, or move through flooded routes. |
| Shadow/phase passage | TBD | Pass through shadow gates or phase walls. |
| Heavy break / force movement | TBD | Break heavy blocks, doors, armor, or machinery. |
| Time hub travel | Moonpetal Seal of Time | Shift hub states and enable Moonpetal Passage. |

## Rising Torii Seal

- First seal.
- Obtained from Samurai Castle Wing.
- Unlocks vertical ascent.
- Visual: floating moon-petal crest.

Character expressions:

| Character | Expression |
|---|---|
| Ronin | Blade-step wall ascent. |
| Arc-Gunner | Recoil/arc booster launch. |
| Iron Knight | Shield brace climb. |
| Black Witch of Ash | Ash-lift levitation burst. |
| Shadow | Rope arrow / shadow perch vault. |
| Gadgeteer | Compact climbing rig. |
| Blood-Marked | Claw vault / blood leap. |
| Yokai-Bound | Spirit pounce / yokai float. |

## Character Expression Matrix

| Category | Ronin | Arc-Gunner | Iron Knight | Witch | Shadow | Gadgeteer | Blood-Marked | Yokai-Bound |
|---|---|---|---|---|---|---|---|---|
| Vertical ascent | Blade-step | Recoil boost | Shield brace | Ash lift | Rope arrow | Climbing rig | Blood leap | Spirit pounce |
| Gap crossing | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Narrow passage | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Barrier bypass | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Hazard crossing | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Water/depth | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Shadow/phase | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Heavy break | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |
| Time hub travel | TBD | TBD | TBD | TBD | TBD | TBD | TBD | TBD |

## Locked Decisions

- Rising Torii Seal is first.
- Rising Torii Seal equals vertical ascent.
- Every playable character can use every required traversal category.
- Character-specific expression is visual/mechanical flavor, not hard character gating.

## Open Questions

- Exact seal names for remaining categories.
- Which zones award each seal.
- Which optional seals unlock secret characters.
- Whether some seals have combat uses.
- Whether time hub travel is late-game only or starts as limited fast travel.

## Implementation Notes

- Store traversal unlocks globally.
- Store character expression data separately from traversal access.
- Tests should verify route access by unlock category, not by character ID.
- Animation fallback is acceptable if exact frames are missing.

