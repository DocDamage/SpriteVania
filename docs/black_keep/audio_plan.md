# Audio Plan

This document defines the first audio planning pass for The Black Keep. It does
not select final audio assets yet; it defines required music, ambience, and SFX
coverage.

## Goals

- Make every major action readable through sound.
- Give each major zone a distinct audio identity.
- Keep UI feedback consistent.
- Support accessibility and volume settings.
- Track missing audio before implementation reaches polish.

## Audio Categories

Music:

- Title theme.
- Modern outskirts tension.
- Swamp ambience music.
- Castle Gate theme.
- Samurai Castle Wing theme.
- Masakiro boss theme.
- Sakuramori Court hub theme.
- World Break variant theme.
- Final Tower theme.
- Monster Belly theme.
- Core theme.

Ambience:

- Rain.
- Wind.
- Swamp insects.
- Castle stone rumble.
- Shrine chimes.
- Bamboo forest movement.
- Graveyard fog.
- Church interior air.
- Tower storm.
- Organic pulse.
- Core hum.

UI SFX:

- Menu move.
- Menu confirm.
- Menu cancel.
- Disabled button.
- Save success.
- Save failure.
- Settings change.
- Slot select.
- Error modal.

Player SFX:

- Footstep.
- Jump.
- Double jump.
- Land.
- Dash.
- Controlled wall fall.
- Wall jump.
- Dash strike.
- Dash strike.
- Dive bomb start.
- Dive bomb impact.
- Hurt.
- KO.

Combat SFX:

- Light attack 1.
- Light attack 2.
- Light attack 3.
- Heavy attack.
- Hit spark.
- Enemy hurt.
- Enemy death.
- Projectile shot.
- Projectile impact.
- Tag swap.
- Tag attack.
- Momentum ready.
- Perfect swap.

Familiar SFX:

- Familiar summon or appear.
- Familiar attack.
- Familiar hit.
- Familiar level up.
- Familiar evolution.
- Familiar ability upgrade.

Enemy SFX:

- Patrol movement.
- Alert.
- Attack windup.
- Attack impact.
- Hurt.
- Death.
- Boss phase shift.

Seal And Progression SFX:

- Pickup.
- Upgrade.
- Rising Torii Seal.
- Shrine activation.
- Portal open.
- Portal unstable.
- World Break event.

## Zone Audio Direction

Modern City Outskirts:

- Sparse urban ambience.
- Distant traffic or electrical hum.
- Keep intrusion introduces low unnatural tone.

Rural Swamp Road:

- Road ambience fades into insects, mud, and distant thunder.

Swamp Outskirts:

- Wet ambience, insects, low drones.
- Combat sounds should cut through dense ambience.

Castle Gate:

- Stone wind, metal groans, distant gate impacts.

Samurai Castle Wing:

- Wood creaks, armor movement, distant drums, tense stealth layers.

Sakuramori Court:

- Calm shrine bells, soft wind, petals, light water.

World Break variants:

- More ash, distortion, unstable portals, harsher low tones.

Final Tower:

- Storm, falling debris, vertical wind.

Monster Belly:

- Organic pulse, liquid movement, muffled impacts.

Core:

- Low harmonic drone, portal instability, heartbeat-like pulse.

## Music State Rules

Rules:

- Boss music overrides zone music.
- Hub music resumes after menus.
- Combat stingers should not restart music constantly.
- World Break state can swap music layers or full tracks.
- Reduced audio fatigue matters for long hubs.

## Settings Requirements

Volume sliders:

- Master.
- Music.
- SFX.
- Ambience.
- UI, if later needed.

Accessibility:

- Subtitle support for voiced lines, if voices are added.
- Visual feedback should not depend solely on sound.
- Important combat cues should have visual counterparts.

## Implementation Notes

- Use named audio event IDs.
- Do not hardcode file paths into gameplay logic.
- Record source path and license for every imported audio asset.
- Keep placeholder audio clearly labeled.

## First Milestone Minimum

Required for milestone:

- Title confirm/cancel/move SFX.
- Save success SFX.
- Jump, land, dash, attack, hit, hurt.
- Enemy attack and death.
- Familiar attack and level up.
- Tag swap and tag attack.
- Seal pickup.
- Basic ambience for Swamp, Castle Gate, Samurai Castle, and Sakuramori Court.
- Masakiro boss music placeholder.

## Open Questions

- Which existing audio assets are usable?
- Does the project need generated placeholder SFX?
- Will the game use voiced dialogue?
- Which audio middleware or Godot-native system is preferred?
