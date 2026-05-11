# World Break State Plan

The World Break is the major midgame state change. It alters The Black Keep,
portal worlds, hubs, NPCs, shops, quests, enemy routes, parallax, weather, and
possibly title-screen presentation.

## Goals

- Create a clear midgame shift with both story and gameplay consequences.
- Change the world without making safe hubs unsafe.
- Reuse early zones in altered forms.
- Make NPCs, shops, quests, enemies, and routes respond to global state.
- Keep the state transition save-safe and testable.

## Global State Model

World Break state:

- `pre_break`
- `break_event`
- `post_break`
- `restoration`
- `true_restored`

Meaning:

- `pre_break`: normal first-half game state.
- `break_event`: transition sequence only.
- `post_break`: damaged world state after the catastrophe.
- `restoration`: some hubs or zones have been partially restored.
- `true_restored`: ending or postgame state, if supported.

Save field:

- `world_break_state`

Required transition flag:

- `world_break_triggered`

## Per-Zone State Model

Zone state values:

- `normal`
- `damaged`
- `corrupted`
- `sealed`
- `unstable`
- `restored`

Examples:

- Sakuramori Court: `normal`, `damaged`, `restored`.
- Samurai Castle Wing: `normal`, `corrupted`, `restored`.
- Castle Gate: `normal`, `damaged`, `unstable`.
- Final Tower: `sealed`, `unstable`, `open`.

Save field:

- `zone_states`

Data shape:

- Key: zone ID.
- Value: zone state string.

## Trigger Requirements

The World Break should trigger after:

- The player has enough seals to understand their importance.
- The first major villain manipulation has been established.
- At least one hub has emotional value.
- The party has enough roster depth for the state change to matter.

Candidate trigger:

- A forced ritual or false victory causes the heroes to destabilize the Keep's
  portal network.

Implementation requirements:

- One explicit story flag.
- Save-safe transition.
- Temporary control lock or controlled sequence.
- Checkpoint before event.
- Checkpoint after event.
- Updated hub and zone state flags.
- Safe fallback if the transition is interrupted.

## Break Event Sequence

Sequence outline:

1. Player enters ritual or false-relic chamber.
2. Villain manipulation is revealed.
3. The party completes or disrupts the wrong seal.
4. Portal network tears open.
5. The Black Keep changes.
6. Active hub state updates to damaged.
7. Player respawns or wakes at a safe hub.
8. New post-break objective appears.

Save rules:

- Save before event starts.
- Do not autosave during unstable cutscene frames.
- Save after post-break safe room loads.
- If load detects `break_event`, recover to post-break safe room.

## Pre-Break State

Characteristics:

- Hubs intact.
- Portal routes mostly stable.
- Early villains alive or active.
- Shops and NPCs follow normal schedules.
- Title screen uses standard Black Keep mood.
- Optional quests are in normal state.

Systems:

- Normal enemy routes.
- Normal shop stock.
- Normal hub parallax.
- Normal NPC schedules.
- First-half traversal gates.

## Post-Break State

Effects:

- The Black Keep physically changes.
- Portal worlds change.
- Safe hubs remain safe but visibly damaged.
- NPCs, shops, quests, and routes change.
- Earlier villains and zones return in corrupted forms.
- Masakiro returns as the Oni-Worn Lord.
- Title screen can shift to damaged visual state.

Systems:

- Corrupted enemy replacements.
- Changed portal links.
- Damaged hub service states.
- Scarcity or emergency shop stock.
- New rescue and restoration quests.
- World Break weather and parallax overlays.

## Hub Damage Variants

Hub variant data:

- Normal parallax.
- Damaged parallax.
- Restored parallax.
- NPC position map.
- Service availability map.
- Shop inventory ID.
- Quest board ID.
- Weather profile ID.

Sakuramori Court damaged state:

- Cherry blossoms ash-coated.
- Shrine cracked but functional.
- Harune relocates between main shrine and Moonpetal Passage.
- Some NPCs displaced.
- Shop stock shifts to emergency items.
- Quest board adds rescue and rebuild tasks.

Safety rule:

- Hubs remain non-combat unless a clearly marked story instance overrides the
  hub scene.

## NPC Schedules

NPC data should support:

- Pre-break schedule.
- Post-break schedule.
- Missing or displaced state.
- Quest-dependent override.
- Restored state after optional quests.

Schedule resolution order:

1. Required story override.
2. Quest-specific override.
3. World Break state override.
4. Day/night schedule.
5. Default position.

## Shop Inventory

Inventory variants:

- `normal_inventory`
- `scarcity_inventory`
- `emergency_inventory`
- `restored_inventory`
- `secret_inventory`

Rules:

- Post-break inventory should not remove required progression items.
- Scarcity can affect consumables, prices, or quantities.
- Restoration quests can improve inventory.
- Optional seals can unlock secret stock.

## Quest Changes

Quest states should support:

- Available pre-break.
- Completed pre-break.
- Failed by break.
- Transformed by break.
- New post-break quest.
- Restoration quest.
- Hidden alternate state.

Rules:

- Main story must not be blocked by missed pre-break side quests.
- Missed optional rewards can transform into post-break alternatives.
- Quest log must clearly distinguish failed, transformed, and unavailable
  states.

## Enemy Replacements

Replacement examples:

- Soldiers become cursed variants.
- Wildlife becomes corrupted.
- Patrols become oni-led routes.
- Boss arenas become rematch arenas.
- Safe roads become unstable traversal routes.

Data fields:

- Pre-break enemy set ID.
- Post-break enemy set ID.
- Restoration enemy set ID.
- Spawn policy.
- Defeat flags.

## Portal Route Changes

Post-break portals can:

- Lock.
- Become unstable.
- Open alternate routes.
- Connect to corrupted versions.
- Require a traversal seal.
- Redirect to damaged hub variants.

Rules:

- Required route changes must have quest guidance.
- Old route IDs should not silently point to invalid rooms.
- Continue/load must resolve obsolete rooms to safe fallback markers.

## Parallax And Weather

World Break variants should include:

- Red sky overlays.
- Cracked distant geometry.
- Ash, fog, or rain changes.
- Corrupted portal shimmer.
- Damaged hub foreground details.
- Lower saturation or harsher contrast where appropriate.

Settings:

- Reduced motion should reduce portal shimmer and particle intensity.
- Flash intensity setting should affect break-event VFX.

## Title Screen State

Possible title variants:

- `title_pre_break`: standard Black Keep.
- `title_post_break`: red/ash, broken portal glow, damaged petals.
- `title_restored`: calmer restored state.

Selection rule:

- If no save exists, show pre-break.
- If latest valid save is post-break, show post-break.
- If latest valid save is true restored, show restored.
- If save scan fails, fall back to pre-break.

## Tests

Automated tests:

- World state saves and loads.
- Break event sets `world_break_triggered`.
- Loading during `break_event` recovers to safe post-break marker.
- Zone state map saves and loads.
- Hub variant resolves from world state.
- NPC schedule resolves in correct priority order.
- Shop inventory changes after world state update.
- Required route does not point to missing room after break.
- Title screen variant resolves from latest valid save.

Manual tests:

- Trigger break event from a clean save.
- Load before, during recovery, and after event.
- Visit Sakuramori Court before and after break.
- Check shop and NPC changes.
- Revisit an early zone after break.
- Confirm reduced-motion break visuals.

## Locked Decisions

- World Break changes safe hubs but does not make them unsafe.
- World Break has visual and gameplay consequences.
- Masakiro returns as Oni-Worn Lord after World Break.
- World Break state must be centralized and save-safe.

## Open Questions

- Exact story trigger.
- Whether missed pre-break quests become unavailable or transform.
- Whether every zone gets a post-break variant or only major zones.
- Which hub becomes the primary post-break recovery location?
- How much title-screen state should reflect latest save versus profile-wide
  progress?

## Implementation Notes

- Centralize world-state flags.
- Keep state transitions save-safe and testable.
- Avoid duplicating entire scenes where state-driven variants are enough.
- Use separate scenes only when layout changes are large.
- Add room-ID fallback rules before implementing World Break.
