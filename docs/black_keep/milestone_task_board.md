# Milestone Task Board

This document turns the first Black Keep milestone into an ordered task board.
It is not a final issue tracker, but each item is shaped to become a ticket.

## Board Rules

- Work from top to bottom unless a dependency is blocked.
- Keep each task small enough to verify.
- Add tests when a task touches saves, movement, combat, room transitions, or
  party state.
- Use prototype assets when final art is blocked.
- Do not block core systems on final dialogue.

## Phase 0: Stabilize Current State

Task: Clean planning branch status.

- Confirm intended docs are tracked.
- Confirm unrelated generated files are understood.
- Decide whether root `BLACK_KEEP_MASTER_PLAN.md` should be tracked or removed.
- Decide whether generated `.import` and `.uid` files should be tracked.

Done when:

- Branch status is intentional before code work resumes.

Task: Run current test suite.

- Run existing Godot tests.
- Record failing tests.
- Separate known warnings from actionable failures.

Done when:

- Baseline test status is known.

## Phase 1: Save And Settings Foundation

Task: Add global settings file.

- Implement `user://black_keep_settings.json`.
- Load settings before title menu.
- Save settings without creating game save.
- Clamp invalid values.

Done when:

- Settings persist across app restart without game save.

Task: Build save-slot metadata.

- Add slot label.
- Add current room.
- Add current zone.
- Add party summary.
- Add play time.
- Add timestamp.

Done when:

- Load Game can display real slot cards.

Task: Implement real Load Game screen.

- Replace placeholder Continue behavior.
- List empty, valid, and damaged slots.
- Load selected slot.
- Back returns to title.

Done when:

- Load Game and Continue are distinct.

## Phase 2: Character Creation

Task: Add starter definitions.

- Add Ronin definition.
- Add Arc-Gunner definition.
- Add Iron Knight definition.
- Mark Witch and Shadow as not starter-selectable.

Done when:

- Starter screen can read definitions by ID.

Task: Build starter select screen.

- Add three cards.
- Add role text.
- Add sprite preview placeholder.
- Add controller navigation.

Done when:

- Player can select one starter with keyboard or controller.

Task: Build name input and confirmation.

- Validate names.
- Confirm initial save state.
- Prevent blank save creation before confirmation.

Done when:

- New Game creates a valid starter save.

## Phase 3: Movement And Combat Fixes

Task: Replace dash teleport.

- Implement velocity dash.
- Add ground dash.
- Add air dash.
- Add dash trail.
- Stop on collision.

Done when:

- Dash visibly travels and cannot pass through walls.

Task: Add modern movement kit.

- Add double jump.
- Add wall hang.
- Add controlled wall fall.
- Add wall jump.

Done when:

- Movement sandbox verifies all actions.

Task: Add attack clarity and combo.

- Add attack prompt.
- Add three-hit combo.
- Add hit sparks.
- Add enemy flash.
- Add hitbox debug toggle.

Done when:

- A new player can identify attack and damage an enemy.

Task: Add dash strike and dive bomb.

- Add forward dash-strike hitbox.
- Add airborne down plus attack dive.
- Add enemy bounce.

Done when:

- Dash strike and dive bomb pass manual and automated checks.

## Phase 4: Enemy AI

Task: Add enemy patrol path nodes.

- Add path data.
- Add wait times.
- Add ledge handling.

Done when:

- Standard enemy patrols without getting stuck.

Task: Add enemy attack states.

- Add windup.
- Add active damage frame.
- Add recovery.
- Add cooldown.

Done when:

- Enemies can damage the player fairly.

Task: Add room respawn policy.

- Add room-owned spawn data.
- Add `room_reentry`.
- Add `persistent_defeat`.

Done when:

- Standard enemies respawn on room re-entry.

## Phase 5: Familiar

Task: Stabilize follow and transition behavior.

- Keep familiar near player.
- Prevent familiar collision blocking.
- Preserve familiar on room transition.

Done when:

- Familiar follows through multiple room transitions.

Task: Add familiar attack and XP.

- Target nearby enemies.
- Attack with cooldown.
- Gain XP from enemy defeats.

Done when:

- Familiar can help kill enemies and level.

Task: Add evolution and upgrades.

- Add evolution state.
- Add ability upgrade state.
- Save and load both.

Done when:

- Familiar evolution persists.

## Phase 6: Party And Recruitment

Task: Add Witch recruitment.

- Add damaged shrine trigger.
- Add Witch name input.
- Add slot 2.
- Save recruitment flag.

Done when:

- Witch joins once and can be loaded.

Task: Add tag swap tutorial.

- Add Momentum UI.
- Add swap input.
- Add Ashen Hexburst placeholder.

Done when:

- Player can swap between starter and Witch.

Task: Add Shadow rescue.

- Add prison interaction.
- Add Shadow name input.
- Add slot 3.
- Save recruitment flag.

Done when:

- Three-character active party works.

Task: Add KO auto-switch.

- Detect visible character KO.
- Switch to living active character.
- Trigger death if none remain.

Done when:

- KO auto-switch is reliable.

## Phase 7: Rooms And Hub

Task: Fix first-screen bounds.

- Add left boundary or valid transition.
- Clamp camera.
- Add regression test.

Done when:

- Player cannot disappear off the first screen.

Task: Finish swamp visual pass.

- Replace unfinished trees.
- Add grounded trunks and canopy.
- Verify collision readability.

Done when:

- First-stage trees pass visual review.

Task: Build Castle Gate and shrine route.

- Add causeway.
- Add broken portcullis.
- Add damaged shrine.
- Add tag tutorial room.

Done when:

- Player reaches Samurai Castle route after Witch tutorial.

Task: Build Samurai Castle Wing.

- Add patrol hall.
- Add watchpost.
- Add prison.
- Add alarm escape.
- Add boss antechamber.

Done when:

- Player can rescue Shadow and reach boss.

Task: Build Masakiro and seal rooms.

- Add boss arena.
- Add boss phases.
- Add defeat flag.
- Add Rising Torii Seal pickup.
- Add ascent test.

Done when:

- Player can defeat boss and unlock vertical ascent.

Task: Build Sakuramori Court shell.

- Add entrance.
- Add save shrine.
- Add party shrine.
- Add training yard.
- Add placeholders.

Done when:

- Player can save in Sakuramori Court.

## Phase 8: Milestone Release Candidate

Task: Run full verification plan.

- Keyboard route.
- Xbox controller route.
- PlayStation-style check if available.
- Reduced-motion check.
- Save/continue checks.

Done when:

- No blocker remains.

Task: Write milestone known-issues list.

- Document prototype art.
- Document deferred services.
- Document known tuning issues.

Done when:

- Milestone can be reviewed without hidden assumptions.
