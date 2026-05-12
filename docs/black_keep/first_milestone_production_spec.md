# First Milestone Production Spec

This spec turns the first Black Keep milestone into buildable room and scene scope. It should be refined after the asset audit and before implementation begins.

## Goal

Ship a playable milestone that proves The Black Keep identity:

- Modern opening.
- Swamp transition using the current vertical slice foundation.
- First arrival at Castle Gate.
- Black Witch recruitment.
- Tag-swap tutorial.
- Samurai Castle Wing stealth/rescue.
- Shadow recruitment.
- Masakiro boss.
- Rising Torii Seal.
- Sakuramori Court hub.

## Room and Screen Flow

```text
Title Screen
-> Character Creation
-> Modern City Outskirts
-> Rural Swamp Road
-> Swamp Tutorial
-> Castle Gate
-> Damaged Shrine
-> Black Witch Recruitment
-> Tag-Swap Tutorial Fight
-> Samurai Castle Wing
-> Shadow Prison Room
-> Masakiro Boss Arena
-> Rising Torii Seal Pickup
-> Sakuramori Court
```

## Modern City Outskirts

Purpose: establish the real-world baseline before the Keep intrudes.

Candidate rooms:

- `ModernOutskirts_Start`: first controllable screen after character creation.
- `ModernOutskirts_StreetBreak`: first supernatural intrusion.
- `ModernOutskirts_ExitRoad`: transition toward rural swamp road.

Implementation notes:

- Keep combat minimal or optional.
- Use starter-specific opening lines later; do not write final dialogue in this spec.
- Teach basic movement before combat pressure.

## Rural Swamp Road

Purpose: bridge modern world into the existing swamp vertical slice.

Candidate rooms:

- `RuralRoad_Approach`: road, broken signs, distant Keep silhouette.
- `RuralRoad_Sink`: ground collapse or portal distortion.
- `RuralRoad_SwampEntry`: handoff into Swamp Tutorial.

Implementation notes:

- This can reuse swamp tiles with modern-road dressing once assets exist.
- The road should visually justify why the existing Swamp Outskirts route now belongs to The Black Keep opening.

## Swamp Tutorial Changes

Use the current Swamp Outskirts as foundation, but retheme it as the liminal first tutorial route.

Needed changes:

- Add Black Keep intrusion visuals.
- Clarify room exits and boundaries.
- Place combat tutorial enemies where attack is obvious.
- Place dash/double-jump/wall-jump tutorial affordances only if those skills are available at this point.
- Preserve save/checkpoint/death loop coverage.

## Castle Gate Expansion

Purpose: first true arrival at The Black Keep.

Candidate rooms:

- `CastleGate_Causeway`
- `CastleGate_BrokenPortcullis`
- `CastleGate_DamagedShrineApproach`

Implementation notes:

- Castle Gate should feel like a major identity shift from swamp to Keep.
- It should support the damaged shrine scene and Witch recruitment.

## Damaged Shrine Scene

Purpose: introduce The Black Witch of Ash and seal logic.

Build needs:

- Shrine interaction area.
- Witch entrance/reveal staging.
- Naming prompt for the Witch.
- Party roster update.
- First tag attack preview.
- Save-state update after recruitment.

No final dialogue should be written here yet.

## Tag-Swap Tutorial Fight

Purpose: first controlled test of two-character active party.

Build needs:

- Low-risk enemy group.
- Forced or strongly prompted swap.
- Witch tag-entry attack: Ashen Hexburst.
- Momentum UI introduction.
- Fail-safe if player refuses to swap.

## Samurai Castle Wing

Purpose: first major Feudal Japan identity dungeon.

High-level room list:

- `SamuraiCastle_OuterWall`
- `SamuraiCastle_PatrolHall`
- `SamuraiCastle_Watchpost`
- `SamuraiCastle_PrisonApproach`
- `SamuraiCastle_ShadowPrison`
- `SamuraiCastle_AlarmEscape`
- `SamuraiCastle_BossAntechamber`
- `SamuraiCastle_MasakiroArena`

## Stealth/Rescue Layout

Required beats:

- Patrol tutorial.
- Optional perfect-stealth treasure path.
- Watchpost with cursed samurai.
- Overheard oni/Masakiro clue.
- Prison wing.
- Shadow rescue.
- Alarm escape.

## Shadow Prison Room

Build needs:

- Captive Shadow staging.
- Rescue interaction.
- Naming prompt for The Shadow.
- Party state update to three active members.
- Shadow tag attack intro.

## Masakiro Boss Arena

Build needs:

- Arena sized for three-character swapping.
- Soldier/samurai add support.
- Oni escalation phase.
- Defeat scene where oni consume Masakiro.
- Post-boss safe pickup state.

## Rising Torii Seal Pickup

Build needs:

- Seal pickup interaction.
- Unlock vertical ascent globally.
- Character-specific expression hooks.
- Short traversal test after pickup.

## Sakuramori Court Hub Layout

First hub must include placeholder locations for:

- Harune's shrine.
- Save shrine.
- Inn/healing.
- Shop.
- Blacksmith.
- Quest board.
- Training room.
- Party management.
- Moonpetal Passage shrine.

## Locked Decisions

- First milestone ends at Sakuramori Court.
- Witch and Shadow are recruited before the milestone boss is complete.
- Masakiro is consumed by oni after defeat.
- Rising Torii Seal unlocks vertical ascent.

## Open Questions

- Exact room count for each route.
- Which existing swamp rooms survive unchanged.
- Which assets support modern road and castle gate dressing.
- Whether the tag-swap tutorial is mandatory or optional.
- Whether the first milestone includes full hub services or placeholders.

## Implementation Notes

- Use stable room IDs before scene work starts.
- Keep room transitions testable.
- Add save checkpoints after recruitment, after boss defeat, and after seal pickup.
- Avoid final dialogue until character voice and quest docs are ready.

