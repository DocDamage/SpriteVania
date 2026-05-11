# Sakuramori Court Spec

Sakuramori Court is the first Cherry Blossom Court hub and the first safe space after the Samurai Castle Wing. It should feel protected, ancient, and fragile.

## Role

- First full hub.
- Party management unlock point.
- Harune introduction.
- Moonpetal Passage hint.
- Safe contrast to Samurai Castle Wing.
- Later World Break damaged-state example.

## Hub Map Zones

| Zone | Purpose |
|---|---|
| Arrival Gate | Player enters from Samurai Castle Wing exit. |
| Harune's Shrine | Main story shrine and Harune staging. |
| Save Shrine | Save/checkpoint location. |
| Inn Grove | Healing/rest. |
| Market Walk | Shop and consumables. |
| Blacksmith Pavilion | Weapons and upgrades. |
| Quest Board | Hub quest routing. |
| Training Yard | Combat, swap, and traversal practice. |
| Archive Nook | Bestiary, lore, dialogue archive. |
| Naming Shrine | Renaming NPC/system. |
| Dye Pavilion | Costume and palette NPC/system. |
| Moonpetal Passage Shrine | Future fast-travel/time-state system. |

## Harune's Shrine

High Priestess Harune:

- Public role: shrine priestess, healer, ritual guide, hub leader.
- Secret role: hereditary vessel/guardian of the Moonpetal Seal of Time.

No final dialogue should be written in this spec.

## Services

Minimum first pass:

- Save shrine.
- Healing/inn.
- Shop.
- Blacksmith.
- Party management.
- Training room.

Later pass:

- Bestiary.
- Quest board.
- Renaming.
- Costume/palette.
- Dialogue archive.
- Moonpetal Passage.

## Day/Night NPC Schedules

Needed schedule groups:

- Harune at shrine during day, Moonpetal shrine at night.
- Shopkeeper at Market Walk during day, Inn Grove at night.
- Blacksmith at pavilion during day, workshop interior at night.
- Training NPC in yard during day, archive at night.

## World Break Damaged State

After World Break:

- Cherry blossoms partially burned or ash-coated.
- Shrine cracked but still functional.
- Some NPCs displaced.
- Shop inventory changes.
- Quest board adds rescue/rebuild tasks.
- Moonpetal Passage becomes more important.
- Weather/parallax shifts toward red sky, ash, and broken portal effects.

## Locked Decisions

- Sakuramori Court is the first Cherry Blossom Court hub.
- Harune leads the hub.
- It remains safe after World Break but visibly damaged.
- Moonpetal Passage is hinted before full unlock.

## Open Questions

- Exact screen count.
- Whether the hub is one large map or several connected rooms.
- Which assets support cherry blossom court visuals.
- Which services must be present in the first playable milestone.
- Whether party management happens through Harune, a shrine, or menu UI.

## Implementation Notes

- Build the hub with stable service node IDs.
- Separate normal and World Break variants through state flags.
- Keep service interactions modular so incomplete services can show locked/placeholder states without breaking flow.

