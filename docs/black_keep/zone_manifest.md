# Zone Manifest

The final zone list should be driven by asset support. This manifest lists candidate zones and what each needs before becoming production scope.

## Candidate Zones

| Zone | Role | Asset needs | Status |
|---|---|---|---|
| Swamp Outskirts | Opening tutorial foundation | Swamp tiles, hazards, enemies, parallax | Existing vertical slice foundation |
| Modern City Outskirts | Real-world opening | Streets, buildings, road props, modern parallax | Needs audit |
| Rural Swamp Road | Transition route | Road/swamp blend, signs, distant Keep | Needs audit |
| Castle Gate | First Keep arrival | Castle tiles, gate props, shrine approach | Partial groundwork |
| Samurai Castle Wing | First identity dungeon | Japan castle tiles, soldiers, samurai, oni, prison | Needs audit |
| Sakuramori Court | First hub | Cherry blossoms, shrine, shops, NPCs, hub props | Needs audit |
| Bamboo Road | Movement/exploration route | Bamboo, slopes, light enemies, parallax | Needs audit |
| Abandoned Shrine District | Relic/seal dungeon | Shrine ruins, yokai, ritual props | Needs audit |
| Oni Cave | Secret/monster route | Cave tiles, oni, hazards, boss | Needs audit |
| Moonlit Village | Hub/refuge | Village tiles, NPCs, night parallax | Needs audit |
| Red Gate Battlefield | Act 2 combat zone | Battlefield, fire, soldiers, oni, war props | Needs audit |
| Graveyard | Gothic route | Grave tiles, undead enemies, fog | Needs audit |
| Church | Gothic interior route | Church tiles, stained glass, cult enemies | Needs audit |
| Cave | Utility route | Cave tiles, hazards, monsters | Needs audit |
| Dungeon/Prison | Interior route | Cells, chains, jail props, guards | Needs audit |
| Forest | Exploration route | Trees, canopy, wildlife, parallax | Needs audit |
| Town | NPC/commercial route | Buildings, civilians, shops | Needs audit |
| Metroidvania Forge | Upgrade route | Machinery, lava/heat, forge NPCs | Needs audit |
| Final Tower | Final dungeon part 1 | Tower tiles, storm parallax, boss rooms | Needs audit |
| Monster Belly | Final dungeon part 2 | Organic horror tiles, acid, veins, ribs | Needs audit |
| Core | Final dungeon part 3 | Abstract/demonic core, final boss VFX | Needs audit |

## Zone Acceptance Criteria

A zone becomes production scope when it has:

- Terrain/tile coverage.
- Background/parallax support.
- At least one enemy family.
- At least one route mechanic.
- Save/checkpoint plan.
- Room transition plan.
- Audio/ambience direction.
- World Break variant decision.

## First Milestone Zones

Required first milestone zones:

- Modern City Outskirts.
- Rural Swamp Road.
- Swamp Outskirts.
- Castle Gate.
- Samurai Castle Wing.
- Sakuramori Court.

## Locked Decisions

- Swamp Outskirts remains the current implementation foundation.
- Samurai Castle Wing is the first major Feudal Japan combat dungeon.
- Sakuramori Court is the first hub.
- Final dungeon order is Final Tower -> Monster Belly -> Core.

## Open Questions

- Which candidate zones have enough asset coverage.
- Whether Graveyard/Church/Cave/Dungeon/Town are separate zones or subroutes.
- Whether Metroidvania Forge is a major zone, optional route, or hub service.
- How many major traversal seals the final zone list supports.

## Implementation Notes

- Asset audit should update this document with evidence.
- Do not build zone-specific systems until the zone passes acceptance criteria.
- Keep zone IDs stable once implementation starts.

