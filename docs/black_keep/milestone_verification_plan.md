# Milestone Verification Plan

This document defines the first milestone verification pass. It combines
automated tests, manual playtests, controller checks, and visual acceptance
criteria.

## Goals

- Catch route-blocking bugs before art polish.
- Verify the playtest issues are fixed.
- Keep save and continue reliable.
- Ensure controller support is real, not assumed.
- Confirm graphics fill the screen and rooms have visible boundaries.

## Blocking Issues To Prevent

The milestone is not ready if:

- The player can disappear offscreen and cannot return.
- The camera shows void or unfinished room edges in normal play.
- Dash looks like an instant teleport.
- Attack input is unclear.
- Regular attacks cannot damage enemies.
- Enemies cannot damage the player.
- Enemies do not patrol or attack.
- Enemy paths get stuck in normal rooms.
- Room re-entry fails to respawn standard enemies.
- Double jump, dash, air dash, wall jump, wall hang, dash strike, or dive bomb
  cannot be tested.
- Familiar state is lost on save, continue, or room transition.
- Continue loads the wrong room or broken position.
- Boss defeat or recruitment can repeat incorrectly.

## Automated Test Groups

### Scene Instantiation

Tests:

- Every milestone room scene loads headless.
- Every room has a bounds node or equivalent room-bound data.
- Every room has at least one valid spawn marker.
- Every exit points to an existing room ID.
- Every checkpoint points to an existing room and spawn marker.

### Room Transition Graph

Tests:

- Adjacent room pairs transition correctly.
- Locked story exits stay locked before required flags.
- Locked exits unlock after required flags.
- One-way exits have an explicit reason.
- Returning from a prior room places the player at the correct marker.

### Player Bounds And Camera

Tests:

- Left edge of first controllable room blocks or transitions safely.
- Camera clamps inside room bounds.
- Player spawn positions are inside room bounds.
- Player cannot spawn inside solid collision.

### Combat

Tests:

- Attack input creates an active hitbox or projectile.
- Attack hitbox damages an enemy hurtbox.
- Enemy hurt, death, and XP events fire.
- Three-hit combo advances and resets.
- Dash strike creates a forward combat hitbox during dash movement.
- Dive bomb damages an enemy and bounces the player.
- Hitstop and screen shake respect settings values.

### Enemy AI

Tests:

- Patrol enemy follows path nodes.
- Enemy detects player in aggro range.
- Enemy attacks when in range.
- Enemy attack damages player.
- Enemy leashes or returns after losing player.
- Standard enemies respawn on room re-entry.
- Persistent defeated enemies stay defeated.

### Movement

Tests:

- Dash moves over multiple physics frames.
- Dash stops on solid collision.
- Air dash is limited before landing.
- Double jump is limited before landing.
- Wall hang holds briefly.
- Wall hang/fall behavior remains controlled without a separate slide mechanic.
- Wall jump pushes away from wall.
- Dash strike creates the merged dash/combat burst.
- Dive bomb does not tunnel through floor collision.

### Party And Recruitment

Tests:

- Witch recruitment flag saves.
- Witch naming saves.
- Tag tutorial unlocks two-character swap.
- Shadow recruitment flag saves.
- Shadow naming saves.
- Active party expands to three.
- Party order saves and loads.
- KO auto-switch selects a living active character.

### Familiar

Tests:

- Familiar follows after room transition.
- Familiar attacks enemy in range.
- Familiar receives XP.
- Familiar level saves and loads.
- Familiar evolution saves and loads.
- Familiar ability upgrades save and load.

### Save And Load

Tests:

- Settings save without creating a game save.
- Continue is disabled without valid saves.
- Continue loads the most recent valid save.
- Load Game lists occupied slots.
- Corrupted save shows an error instead of crashing.
- Legacy save migration fills new defaults.
- Save after recruitment reloads correctly.
- Save after boss defeat reloads correctly.
- Save after seal pickup reloads correctly.

## Manual Playtest Routes

### Keyboard Route

Steps:

1. Start New Game.
2. Select each starter in separate runs.
3. Confirm name entry.
4. Reach Swamp.
5. Attack and defeat first enemy.
6. Test double jump and dash.
7. Test wall hang and wall jump.
8. Test dash strike.
9. Test dive bomb on enemy.
10. Recruit Witch.
11. Complete tag tutorial.
12. Rescue Shadow.
13. Defeat Masakiro.
14. Collect Rising Torii Seal.
15. Reach Sakuramori Court.
16. Save, quit, continue.

Pass condition:

- Route can be completed without debug tools.

### Xbox Controller Route

Steps:

- Repeat the keyboard route with Xbox-style controller.
- Confirm button prompts match expected glyphs or fallback labels.
- Confirm menu navigation, remapping, pause, and settings work.

Pass condition:

- Full route can be completed without keyboard.

### PlayStation Controller Route

Steps:

- Repeat critical route sections with PlayStation-style controller.
- Confirm glyph style can be selected or detected.
- Confirm face-button layout is understandable.

Pass condition:

- Combat, dash, jump, interact, swap, pause, and menu navigation work.

### Reduced Motion Route

Steps:

- Enable reduced motion.
- Test title screen.
- Test dash.
- Test hit effects.
- Test tag attack.
- Test boss phase change.

Pass condition:

- Gameplay remains readable with reduced motion and avoids intense camera or
  particle effects.

## Visual Review Checklist

Screen fill:

- No visible void at screen edges.
- Camera clamps in every room.
- Parallax fills the viewport.
- Title screen fills the viewport.
- UI does not overlap gameplay-critical elements.

Swamp trees:

- Tree roots connect to ground.
- Canopies do not look cut off.
- Foreground does not hide enemies unfairly.
- Collision matches visible terrain.

Dash:

- Trail communicates movement.
- Character remains visible.
- Dash start and end are readable.

Combat:

- Attack arcs or projectiles are visible.
- Enemy hit flashes are visible.
- Damage feedback is immediate.
- Enemy windups are readable.

Hub:

- Save shrine is visible.
- Party shrine placeholder is visible.
- NPCs do not block core routes.

## Performance Checks

Targets:

- Stable frame pacing in milestone rooms.
- No repeated asset loading hitch during normal room transitions.
- No runaway particle counts.
- No familiar or enemy pathfinding loops causing frame drops.

Manual checks:

- Run through Swamp with familiar and enemies active.
- Run Samurai Castle alarm escape with multiple guards.
- Run Masakiro with adds.
- Toggle title screen effects.

## Release Candidate Checklist

Before calling the milestone ready:

- All blocking tests pass.
- Keyboard route passes.
- Xbox route passes.
- At least one PlayStation-style controller check passes or is documented.
- Save and continue pass from every checkpoint.
- Load Game slot screen opens.
- No room-transition softlocks found.
- No repeated recruitment or boss reward bugs.
- Art placeholders are documented.
- Remaining known issues are listed in release notes.
