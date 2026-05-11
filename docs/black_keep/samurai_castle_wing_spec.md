# Samurai Castle Wing Spec

The Samurai Castle Wing is the first major identity dungeon and the first full proof of the Feudal Japan time-fragment direction.

## Role

- First major combat dungeon.
- First stealth/rescue sequence.
- Shadow recruitment.
- Lord Masakiro boss.
- Oni manipulation reveal.
- Rising Torii Seal reward.
- Exit to Sakuramori Court.

## Enemy Factions

Human soldiers:

- Patrols.
- Guards.
- Alarm callers.
- Basic melee/ranged pressure.

Cursed samurai:

- Stronger guard units.
- Slower, heavier attacks.
- Good for watchpost and antechamber encounters.

Oni forces:

- Rare early.
- Strong visual threat.
- Used to imply Masakiro is being manipulated.

## Proposed Room Flow

```text
Outer Wall
-> Patrol Hall
-> Watchpost
-> Optional Treasure Rafters
-> Oni Eavesdrop Room
-> Prison Approach
-> Shadow Prison
-> Alarm Escape
-> Boss Antechamber
-> Masakiro Arena
-> Seal Room
-> Exit Passage to Sakuramori Court
```

## Stealth Patrol Rules

- Guards have visible patrol paths.
- Detection starts a warning state before full alarm when possible.
- Crouch/cover or elevation should matter if supported by movement.
- Player can recover from detection without softlock.
- Some treasure requires clean or perfect stealth.

## Alarm Rules

| Result | Condition | Outcome |
|---|---|---|
| Perfect | No alarms | Best optional reward + unique Shadow reaction later. |
| Clean | One alarm | Normal reward. |
| Rough | Multiple alarms | Harder fights, less treasure. |
| Forced combat | Repeated detection | Miniboss guard appears. |
| Story minimum | Rescue still succeeds | No softlock. |

## Perfect Stealth Rewards

- Rare crafting material.
- Riftbow Carbine mod.
- Stealth charm accessory.
- Shadow affinity bonus.
- Oni lore note.
- Alternate Shadow dialogue later.

## Shadow Recruitment Scene

Build needs:

- Prison cell or restraint staging.
- Rescue interaction.
- Player naming prompt.
- Party roster update.
- Shadow tag attack intro.
- Alarm escape trigger.

Do not write final dialogue in this spec.

## Masakiro Boss Phases

1. Disciplined human warlord combat.
2. Calls soldiers and cursed samurai.
3. Oni blessing empowers him, but his control slips.
4. Defeat: oni consume him.

## Oni-Consumption Scene

Purpose:

- Shows Masakiro was not truly in control.
- Foreshadows the Oni-Worn Lord rematch.
- Confirms the oni are older and deeper than The Black Keep's surface politics.

## Rising Torii Seal Reward

After Masakiro:

- Spawn seal pickup.
- Unlock vertical ascent.
- Show short, safe traversal test.
- Route to Sakuramori Court.

## Locked Decisions

- The Shadow is recruited in this dungeon.
- Masakiro is the first major boss.
- Oni consume Masakiro after defeat.
- Rising Torii Seal unlocks vertical ascent.
- Dungeon exits to Sakuramori Court.

## Open Questions

- Exact enemy asset selections.
- Whether stealth uses line of sight, sound, light/dark, or simplified trigger zones.
- Whether perfect stealth rewards are mechanical in first milestone or tracked for later.
- Whether the Shadow is playable during the alarm escape or only after it.

## Implementation Notes

- Use explicit alarm state values: `none`, `warning`, `alarm`, `lockdown`.
- Track stealth result for rewards and later dialogue.
- Keep boss arena separate from stealth state to avoid broken boss starts.
- Save after Shadow recruitment and after Masakiro defeat.

