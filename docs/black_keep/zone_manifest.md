# Zone Manifest

The final zone list should be driven by asset support. This manifest lists
candidate zones, stable IDs, production roles, asset confidence, and the gates
each zone must pass before it becomes implementation scope.

## Goals

- Keep the world plan tied to real asset coverage.
- Identify first-milestone zones separately from later zones.
- Preserve stable zone IDs before room implementation starts.
- Avoid building large zone-specific systems before the art path is credible.
- Keep World Break variants visible in planning from the start.

## Zone Status Terms

Strong:

- Terrain, parallax, enemies, and props appear likely from current assets.

Medium:

- Some asset support exists, but production use needs review or combination.

Low:

- Needs custom art, heavy editing, or a fallback plan.

Prototype:

- Use temporary art to prove gameplay before final art is ready.

## First Milestone Zones

Modern City Outskirts:

- Zone ID: `modern_outskirts`.
- Role: real-world opening.
- Asset confidence: medium.
- Asset needs: streets, buildings, road props, modern parallax.
- Current evidence: CraftPix modern characters exist; environment support still
  needs road and city review.
- Production gate: enough street and barrier art for three small rooms.

Rural Swamp Road:

- Zone ID: `rural_swamp_road`.
- Role: transition route from modern world to swamp.
- Asset confidence: medium.
- Asset needs: road/swamp blend, broken signs, grass, mud, distant Keep.
- Current evidence: can combine swamp assets with exterior props.
- Production gate: transition art must explain why the swamp route belongs to
  The Black Keep opening.

Swamp Outskirts:

- Zone ID: `swamp_outskirts`.
- Role: opening tutorial foundation.
- Asset confidence: strong.
- Asset needs: finished trees, hazards, enemies, parallax.
- Current evidence: existing vertical slice plus Gothicvania Swamp and SciGo
  SwampTiles.
- Production gate: trees and boundaries must pass visual review.

Castle Gate:

- Zone ID: `castle_gate`.
- Role: first Keep arrival.
- Asset confidence: medium-high.
- Asset needs: castle tiles, gate props, shrine approach, dark atmosphere.
- Current evidence: Castle Gate groundwork plus castle and dark castle sources.
- Production gate: causeway, broken portcullis, and shrine approach must be
  buildable.

Samurai Castle Wing:

- Zone ID: `samurai_castle_wing`.
- Role: first identity dungeon.
- Asset confidence: high.
- Asset needs: Japan castle tiles, soldiers, samurai, oni, prison.
- Current evidence: Feudal Japan stages and Samurai/DarkKnight support.
- Production gate: patrol hall, prison, boss arena, and seal room must be
  buildable.

Sakuramori Court:

- Zone ID: `sakuramori_court`.
- Role: first hub.
- Asset confidence: high.
- Asset needs: cherry blossoms, shrine, shops, NPCs, hub props.
- Current evidence: Mystic Sakura Forest, Sakura Temple, Priests, and Traders.
- Production gate: save shrine, party shrine, and training yard must be
  buildable.

## Candidate Main Zones

Bamboo Road:

- Zone ID: `bamboo_road`.
- Role: movement and exploration route.
- Asset confidence: high.
- Candidate seal: Wind Bridge Seal.
- Asset needs: bamboo, slopes, light enemies, parallax.
- Current evidence: Mystic Bamboo Forest pack exists.

Abandoned Shrine District:

- Zone ID: `abandoned_shrine_district`.
- Role: relic and seal dungeon.
- Asset confidence: high.
- Candidate seal: Root Whisper Seal or Iron Ward Seal.
- Asset needs: shrine ruins, yokai, ritual props.
- Current evidence: Feudal Japan Temple and Sakura Temple packs.

Oni Cave:

- Zone ID: `oni_cave`.
- Role: monster route and secret pressure zone.
- Asset confidence: medium.
- Candidate seal: Giant Breaker Seal.
- Asset needs: cave tiles, oni, hazards, boss.
- Current evidence: cave tiles and demon/minotaur/dragon pools exist.
- Risk: oni-specific art still needs selection.

Moonlit Village:

- Zone ID: `moonlit_village`.
- Role: hub or refuge.
- Asset confidence: high.
- Candidate system: Moonpetal Passage support.
- Asset needs: village tiles, NPCs, night parallax.
- Current evidence: Feudal Japan Village and Feudal Japan background support.

Red Gate Battlefield:

- Zone ID: `red_gate_battlefield`.
- Role: Act 2 combat zone.
- Asset confidence: medium-high.
- Candidate seal: Ember Path Seal.
- Asset needs: battlefield, fire, soldiers, oni, war props.
- Current evidence: Burning Village Japan supports fire and war atmosphere.

Graveyard:

- Zone ID: `graveyard`.
- Role: Gothic route.
- Asset confidence: high.
- Candidate seal: Shadow Gate Seal.
- Asset needs: grave tiles, undead enemies, fog.
- Current evidence: Gothicvania Cemetery, Haunted Graveyard, skeleton and zombie
  enemies.

Church:

- Zone ID: `church`.
- Role: Gothic interior route.
- Asset confidence: high.
- Candidate seal: Iron Ward Seal.
- Asset needs: church tiles, stained glass, cult enemies.
- Current evidence: Gothicvania Church has strong PNG coverage.

Cave:

- Zone ID: `cave`.
- Role: utility route.
- Asset confidence: medium-high.
- Candidate seal: Deep Moon Seal if flooded route is viable.
- Asset needs: cave tiles, hazards, monsters.
- Current evidence: Fantasy Caves and trap/hazard assets exist.

Dungeon Or Prison:

- Zone ID: `dungeon_prison`.
- Role: interior route.
- Asset confidence: medium.
- Candidate seal: Iron Ward Seal or Shadow Gate Seal.
- Asset needs: cells, chains, jail props, guards.
- Current evidence: Dark Dungeon and Cold Corridors support.
- Risk: prison-specific review needed.

Forest:

- Zone ID: `forest`.
- Role: exploration route.
- Asset confidence: medium-high.
- Candidate seal: Root Whisper Seal.
- Asset needs: trees, canopy, wildlife, parallax.
- Current evidence: Dark Forest, Mystic Sakura Forest, and Bamboo Forest.

Town:

- Zone ID: `town`.
- Role: NPC and commercial route.
- Asset confidence: high.
- Candidate system: hub services, shops, side quests.
- Asset needs: buildings, civilians, shops.
- Current evidence: GothicVania town files plus Traders and NPCs.

Metroidvania Forge:

- Zone ID: `metroidvania_forge`.
- Role: upgrade route.
- Asset confidence: medium.
- Candidate seal: Giant Breaker Seal or Ember Path Seal.
- Asset needs: machinery, lava or heat, forge NPCs.
- Current evidence: Metroidvania Forge folder exists but needs review.

## Final Dungeon Zones

Final Tower:

- Zone ID: `final_tower`.
- Role: final dungeon part one.
- Asset confidence: medium.
- Asset needs: tower tiles, storm parallax, boss rooms.
- Current evidence: final tower assets exist.
- Risk: platformer slicing and parallax need review.

Monster Belly:

- Zone ID: `monster_belly`.
- Role: final dungeon part two.
- Asset confidence: medium.
- Asset needs: organic horror tiles, acid, veins, ribs.
- Current evidence: inside-belly tiles exist but likely need added VFX.
- Risk: may need custom parallax.

Core:

- Zone ID: `core`.
- Role: final dungeon part three.
- Asset confidence: low-medium.
- Asset needs: abstract demonic core, final boss VFX.
- Current evidence: Pixel Effects and Horror Textures can help.
- Risk: needs custom direction.

## Zone Acceptance Criteria

A zone becomes production scope when it has:

- Terrain and tile coverage.
- Background or parallax support.
- At least one enemy family.
- At least one route mechanic.
- Save and checkpoint plan.
- Room transition plan.
- Audio or ambience direction.
- World Break variant decision.
- Asset source list.
- Known placeholder list.
- First room graph sketch.

## Production Gate Checklist

Before implementation:

- Zone ID is stable.
- Required traversal seal is known or explicitly none.
- Asset source folders are listed.
- Tile collision strategy is known.
- Enemy families are selected.
- Boss or miniboss need is defined.
- Save/checkpoint location is defined.
- World Break behavior is decided.

Before content lock:

- At least one room has passed visual review.
- At least one enemy encounter has passed playtest.
- Room transitions pass both directions.
- Parallax fills target viewports.
- Audio direction is assigned.
- Required traversal check is testable.

## Locked Decisions

- Swamp Outskirts remains the current implementation foundation.
- Samurai Castle Wing is the first major Feudal Japan combat dungeon.
- Sakuramori Court is the first hub.
- Final dungeon order is Final Tower to Monster Belly to Core.
- Zone build order should follow asset confidence and milestone needs.

## Open Questions

- Which candidate zones have enough asset coverage after in-engine review?
- Are Graveyard, Church, Cave, Dungeon, and Town separate zones or subroutes?
- Is Metroidvania Forge a major zone, optional route, or hub service?
- How many major traversal seals should be required before Final Tower?
- Which zone should award each non-locked seal?

## Implementation Notes

- Asset audit should update this document with evidence.
- Do not build zone-specific systems until the zone passes acceptance criteria.
- Keep zone IDs stable once implementation starts.
- Use prototype art where systems need proof before final asset selection.
