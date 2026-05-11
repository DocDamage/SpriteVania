# Sakuramori Court Spec

Sakuramori Court is the first Cherry Blossom Court hub and the first safe space
after the Samurai Castle Wing. It should feel protected, ancient, and fragile.

## Goals

- Give the player a safe recovery point after Masakiro.
- Introduce Cherry Blossom Courts as the hub pattern.
- Provide save, healing, and party management.
- Stage Harune as hub leader.
- Hint at Moonpetal Passage and future time-state travel.
- Provide a later World Break damaged-state example.

## Stable IDs

Hub ID:

- `sakuramori_court`

Rooms:

- `SakuramoriCourt_Entrance`
- `SakuramoriCourt_SaveShrine`
- `SakuramoriCourt_PartyShrine`
- `SakuramoriCourt_MarketWalk`
- `SakuramoriCourt_BlacksmithPavilion`
- `SakuramoriCourt_TrainingYard`
- `SakuramoriCourt_ArchiveNook`
- `SakuramoriCourt_MoonpetalPassage`

Story flags:

- `sakuramori_court_reached`
- `harune_intro_seen`
- `sakuramori_save_used`
- `party_shrine_unlocked`
- `moonpetal_passage_discovered`

Service IDs:

- `save_shrine`
- `inn_grove`
- `market_shop`
- `blacksmith`
- `party_shrine`
- `training_yard`
- `quest_board`
- `archive_nook`
- `naming_shrine`
- `dye_pavilion`
- `moonpetal_passage`

## Hub Layout

Milestone shell layout:

1. Arrival Gate.
2. Harune's Shrine.
3. Save Shrine.
4. Party Shrine.
5. Training Yard.
6. Locked or placeholder Market Walk.
7. Locked or placeholder Moonpetal Passage.

Expanded layout:

- Arrival Gate.
- Harune's Shrine.
- Save Shrine.
- Inn Grove.
- Market Walk.
- Blacksmith Pavilion.
- Quest Board.
- Training Yard.
- Archive Nook.
- Naming Shrine.
- Dye Pavilion.
- Moonpetal Passage Shrine.

## Room Details

### Entrance

Purpose:

- First arrival from Samurai Castle Wing.
- Establish hub atmosphere.
- Stage Harune intro.

Exits:

- Left exit back toward Samurai Castle path.
- Right exit to Save Shrine.
- Interior path to Party Shrine.
- Forward path to Market Walk placeholder.

Acceptance:

- Player cannot be attacked here.
- Hub checkpoint is set.

### Save Shrine

Purpose:

- Manual save and healing.

Services:

- Save.
- Restore party HP.
- Clear KO state.
- Restore familiar state.

Acceptance:

- Continue after saving loads safely into Sakuramori Court.

### Party Shrine

Purpose:

- First party management shell.

Milestone services:

- Display active party.
- Show current names and titles.
- Reorder active party if supported.
- Rename hook if name input is ready.
- Training handoff.

Acceptance:

- Opening and closing UI returns control cleanly.
- Party state does not corrupt if player cancels.

### Market Walk

Purpose:

- Shop and consumable space.

Milestone state:

- Placeholder or locked service.

Future services:

- Buy consumables.
- Sell materials.
- Purchase maps or hints.
- World Break inventory changes.

Acceptance:

- Placeholder clearly communicates unavailable service without blocking path.

### Blacksmith Pavilion

Purpose:

- Upgrade and equipment service.

Milestone state:

- Placeholder if equipment is not implemented.

Future services:

- Weapon upgrades.
- Armor upgrades.
- Familiar ability upgrade materials.
- Special character mastery upgrades.

### Training Yard

Purpose:

- Practice movement, combat, swapping, familiar attacks, and traversal seals.

Milestone services:

- Training dummy.
- Combo reset area.
- Swap practice.
- Vertical ascent practice after Rising Torii Seal.

Acceptance:

- Player can test attack, combo, dash, wall jump, slide attack, dive bomb, and
  tag swap without enemy death pressure.

### Archive Nook

Purpose:

- Bestiary, lore, and dialogue archive later.

Milestone state:

- Placeholder.

### Moonpetal Passage

Purpose:

- Future fast-travel and time-state shrine.

Milestone state:

- Visible but locked or dormant.

Acceptance:

- Player understands it is important later without being able to break sequence.

## Harune

High Priestess Harune:

- Public role: shrine priestess, healer, ritual guide, hub leader.
- Secret role: hereditary vessel or guardian of the Moonpetal Seal of Time.

Milestone behavior:

- Appears near Harune's Shrine.
- Provides non-final placeholder interaction.
- Directs player toward save and party shrine.
- Does not deliver final story dialogue yet.

## Services

Minimum first pass:

- Save shrine.
- Healing or inn function.
- Party management.
- Training yard.

Milestone placeholders:

- Shop.
- Blacksmith.
- Quest board.
- Archive.
- Renaming.
- Dye or costume service.
- Moonpetal Passage.

Later pass:

- Bestiary.
- Dialogue archive.
- Full quest board.
- Day/night schedule.
- World Break rebuild tasks.

## Day And Night Schedules

Schedule groups:

- Harune at shrine during day.
- Harune at Moonpetal Passage at night.
- Shopkeeper at Market Walk during day.
- Shopkeeper at Inn Grove at night.
- Blacksmith at pavilion during day.
- Blacksmith at workshop interior at night.
- Training NPC in yard during day.
- Training NPC at archive at night.

Milestone one:

- Day/night can be data-only or disabled.
- If disabled, default to day state.

## World Break Damaged State

Post-World Break changes:

- Cherry blossoms partially burned or ash-coated.
- Shrine cracked but still functional.
- Some NPCs displaced.
- Shop inventory changes.
- Quest board adds rescue and rebuild tasks.
- Moonpetal Passage becomes more important.
- Weather/parallax shifts toward red sky, ash, and broken portal effects.

State model:

- `world_break_state` equals `pre_break`, `breaking`, or `post_break`.
- Hub reads state and loads visual/service variants.
- Safe-zone rules remain active in all states.

## Service Interaction Rules

Rules:

- Services pause gameplay where appropriate.
- Closing a service restores player control.
- Service prompts respect controller glyph settings.
- Placeholder services cannot create invalid save state.
- Save shrine can be used repeatedly.
- Party shrine cannot remove the current visible character unless replacement is
  valid.

## Tests

Automated tests:

- Hub entrance instantiates.
- Save shrine writes current hub checkpoint.
- Save shrine clears KO state.
- Party shrine opens and closes.
- Party state remains valid after cancel.
- Training dummy can be damaged without awarding invalid progression.
- Moonpetal Passage is locked before unlock flag.
- Hub remains non-combat.

Manual tests:

- Enter hub from Samurai Castle.
- Save and continue.
- Open party shrine.
- Practice swap in training yard.
- Practice vertical ascent.
- Interact with placeholders.
- Verify no placeholder traps the player.

## Locked Decisions

- Sakuramori Court is the first Cherry Blossom Court hub.
- Harune leads the hub.
- It remains safe after World Break but visibly damaged.
- Moonpetal Passage is hinted before full unlock.
- First milestone requires at least save, healing, party shell, and training
  shell.

## Open Questions

- Exact screen count.
- Whether hub is one large map or several connected rooms.
- Which assets support cherry blossom court visuals.
- Whether party management happens through Harune, a shrine, or menu UI.
- Whether day/night appears in milestone one or remains data-only.

## Implementation Notes

- Build the hub with stable service node IDs.
- Separate normal and World Break variants through state flags.
- Keep service interactions modular so incomplete services can show locked or
  placeholder states without breaking flow.
- Avoid final Harune dialogue until story voice is locked.
