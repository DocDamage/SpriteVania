# Zone Manifest

The final zone list should be driven by asset support. This manifest lists candidate zones and what each needs before becoming production scope.

## Candidate Zones

| Zone | Role | Asset needs | Status |
|---|---|---|---|
| Swamp Outskirts | Opening tutorial foundation | Swamp tiles, hazards, enemies, parallax | Strong: existing vertical slice plus Gothicvania Swamp and SciGo SwampTiles |
| Modern City Outskirts | Real-world opening | Streets, buildings, road props, modern parallax | Medium: CraftPix modern characters exist; environment support still needs road/city review |
| Rural Swamp Road | Transition route | Road/swamp blend, signs, distant Keep | Medium: can combine swamp assets with town/exterior props, but road identity needs inspection |
| Castle Gate | First Keep arrival | Castle tiles, gate props, shrine approach | Medium-high: Castle Gate groundwork plus castle/dark castle tile sources |
| Samurai Castle Wing | First identity dungeon | Japan castle tiles, soldiers, samurai, oni, prison | High: Feudal Japan Stages and enemy Samurai/DarkKnight support |
| Sakuramori Court | First hub | Cherry blossoms, shrine, shops, NPCs, hub props | High: Mystic Sakura Forest, Sakura Temple, Priests/Traders |
| Bamboo Road | Movement/exploration route | Bamboo, slopes, light enemies, parallax | High: Mystic Bamboo Forest pack exists |
| Abandoned Shrine District | Relic/seal dungeon | Shrine ruins, yokai, ritual props | High: Feudal Japan Temple and Sakura Temple packs exist |
| Oni Cave | Secret/monster route | Cave tiles, oni, hazards, boss | Medium: cave tiles and demon/minotaur/dragon pools exist; oni-specific art needs selection |
| Moonlit Village | Hub/refuge | Village tiles, NPCs, night parallax | High: Feudal Japan Village plus Feudal Japan background support |
| Red Gate Battlefield | Act 2 combat zone | Battlefield, fire, soldiers, oni, war props | Medium-high: Burning Village Japan supports fire/war atmosphere |
| Graveyard | Gothic route | Grave tiles, undead enemies, fog | High: Gothicvania Cemetery, Haunted Graveyard, Skeleton/Zombie enemies |
| Church | Gothic interior route | Church tiles, stained glass, cult enemies | High: Gothicvania Church has strong PNG coverage |
| Cave | Utility route | Cave tiles, hazards, monsters | Medium-high: Fantasy Caves and trap/hazard assets exist |
| Dungeon/Prison | Interior route | Cells, chains, jail props, guards | Medium: Dark Dungeon/Cold Corridors support; prison-specific review needed |
| Forest | Exploration route | Trees, canopy, wildlife, parallax | Medium-high: Dark Forest, Mystic Sakura Forest, Bamboo Forest |
| Town | NPC/commercial route | Buildings, civilians, shops | High: GothicVania town files plus Traders and NPCs |
| Metroidvania Forge | Upgrade route | Machinery, lava/heat, forge NPCs | Medium: Metroidvania Forge folder exists but small; needs visual review |
| Final Tower | Final dungeon part 1 | Tower tiles, storm parallax, boss rooms | Medium: final tower assets exist, but platformer slicing/parallax needs review |
| Monster Belly | Final dungeon part 2 | Organic horror tiles, acid, veins, ribs | Medium: inside-belly tiles exist but small; likely needs added VFX/parallax |
| Core | Final dungeon part 3 | Abstract/demonic core, final boss VFX | Low-medium: can draw from Pixel Effects/Horror Textures but needs custom direction |

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
