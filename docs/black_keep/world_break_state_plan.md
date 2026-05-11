# World Break State Plan

The World Break is the major midgame state change. It alters The Black Keep, portal worlds, hubs, NPCs, shops, quests, enemy routes, parallax, weather, and possibly title-screen presentation.

## State Model

Suggested global state:

- `world_break_state = pre_break`
- `world_break_state = break_event`
- `world_break_state = post_break`

Suggested per-zone state:

- `normal`
- `damaged`
- `corrupted`
- `sealed`
- `restored`

## Pre-Break State

Characteristics:

- Hubs intact.
- Portal routes mostly stable.
- Early villains alive or active.
- Shops and NPCs follow normal schedules.
- Title screen uses standard Black Keep mood.

## Break Event Trigger

Trigger should occur after a major story mistake, forced ritual, or villain manipulation.

Implementation needs:

- One explicit story flag.
- Save-safe transition.
- Cutscene or gameplay event.
- Updated hub/zone state flags.
- Respawn/checkpoint handling after event.

## Post-Break State

Effects:

- The Black Keep physically changes.
- Portal worlds change.
- Safe hubs remain safe but visibly damaged.
- NPCs, shops, quests, and routes change.
- Earlier villains and zones return in corrupted forms.
- Masakiro returns as the Oni-Worn Lord.

## Hub Damage Variants

Hub changes:

- Damaged parallax.
- Altered lighting/weather.
- Displaced NPC positions.
- Changed shop stock.
- Rebuild/rescue quests.
- Moonpetal Passage increased importance.

## NPC Schedule Changes

NPC data should support:

- Pre-break schedule.
- Post-break schedule.
- Missing/displaced state.
- Quest-dependent override.
- Restored state after optional quests.

## Shop Inventory Changes

Shop inventory should support:

- Normal inventory.
- Scarcity/damaged inventory.
- Post-break emergency inventory.
- Restored inventory after hub quests.
- Secret inventory after optional seals.

## Quest Changes

Quest states should support:

- Available pre-break.
- Failed or transformed by break.
- New post-break quest.
- Restoration quest.
- Hidden alternate state.

## Enemy Replacements

Zones can replace:

- Soldiers with cursed variants.
- Wildlife with corrupted creatures.
- Boss arenas with rematch encounters.
- Patrols with oni routes.

## Portal Route Changes

Post-break portals can:

- Lock.
- Become unstable.
- Open alternate route.
- Connect to corrupted version.
- Require a traversal seal.

## Parallax and Weather Changes

World Break variants should include:

- Red sky overlays.
- Cracked distant geometry.
- Ash/fog/rain changes.
- Corrupted portal shimmer.
- Damaged hub foreground details.

## Title Screen State Changes

Possible title variants:

- Pre-break title: standard Black Keep.
- Post-break title: more red/ash, broken portal glows, damaged petals.
- True ending title: restored or cleansed variant.

## Locked Decisions

- World Break changes safe hubs but does not make them unsafe.
- World Break has visual and gameplay consequences.
- Masakiro returns as Oni-Worn Lord after World Break.

## Open Questions

- Exact story trigger.
- Whether title-screen state should depend on latest save.
- Whether missed pre-break quests become unavailable or transform.
- Whether every zone needs a post-break variant or only major zones.

## Implementation Notes

- Centralize world-state flags.
- Keep state transitions save-safe and testable.
- Avoid duplicating entire scenes where state-driven variants are enough.
- Use separate scenes only when layout changes are large.

