# Production Readiness Checklist

This checklist defines what must be true before the Black Keep first milestone
is considered ready for review, merge, or a broader playtest.

## Checklist Rules

- A checked item must be verified, not assumed.
- Prototype art is allowed only when documented.
- Known issues must be visible.
- Save, load, and controller support are release blockers.
- No route-critical bug should be waived without an explicit decision.

## Documentation Readiness

Required:

- Master plan is valid Markdown.
- Black Keep README links all active specs.
- First milestone production spec is current.
- Milestone room graph matches implemented room IDs.
- Asset integration tasks reflect current prototype art.
- Verification plan reflects current tests.
- Known issues list is current.

Done when:

- A new contributor can find the route, systems, assets, and test plan from the
  README.

## Branch Readiness

Required:

- Git status is reviewed.
- Intended docs are tracked.
- Intended Godot import files are tracked or ignored by rule.
- Generated temporary files are ignored or removed.
- No unrelated user changes are reverted.
- Branch name and target are clear.

Done when:

- The branch diff contains only intentional changes.

## Save And Settings Readiness

Required:

- Continue works.
- Load Game works.
- Save slots show valid metadata.
- Corrupt saves do not crash.
- Settings persist without game save.
- Save migration behavior is tested.
- Current checkpoint loads safely.
- Current room ID validates.

Blockers:

- Continue loads wrong room.
- Save data is corrupted.
- Settings create blank saves.
- Corrupt save crashes title screen.

## Character Creation Readiness

Required:

- Ronin can start a new save.
- Arc-Gunner can start a new save.
- Iron Knight can start a new save.
- Witch is not starter-selectable.
- Shadow is not starter-selectable.
- Name input validates correctly.
- Confirmation writes initial party state.
- Occupied-save overwrite confirmation is bound to the current starter/name
  choice.
- Back navigation works.
- Controller navigation works.

Blockers:

- New Game can create invalid save.
- Starter ID saves as display string only.
- Empty name bypasses validation.

## Movement Readiness

Required:

- Dash travels over time.
- Ground dash works.
- Air dash works.
- Double jump works.
- Wall hang works.
- Wall hang/fall behavior works without a separate slide mechanic.
- Wall jump works.
- Dash strike works as the merged dash/combat burst.
- Dive bomb works.
- Dive bomb bounces on enemy hit.
- Dash and dive bomb do not tunnel through collision.

Blockers:

- Player can clip through walls.
- Player can disappear offscreen.
- Required movement cannot be performed with controller.

## Combat Readiness

Required:

- Attack input is discoverable.
- Light combo works.
- Player attacks damage enemies.
- Enemies show hit feedback.
- Enemy attacks damage player.
- Damage ownership records player or familiar source.
- XP is awarded once.
- Hit effects respect settings.

Blockers:

- Player cannot attack monsters.
- Monsters cannot attack player.
- Combat softlocks after enemy death.

## Enemy AI Readiness

Required:

- Standard patrol enemy works.
- Crawler or small enemy works.
- Ranged or watch enemy works.
- Cursed samurai works.
- Oni brute prototype works.
- Enemies patrol.
- Enemies aggro.
- Enemies attack.
- Enemies leash or reset.
- Standard enemies respawn on room re-entry.

Blockers:

- Enemies get stuck in required rooms.
- Enemy attacks are unavoidable from offscreen.
- Room re-entry leaves required enemy state broken.

## Familiar Readiness

Required:

- Familiar follows.
- Familiar survives room transition.
- Familiar attacks.
- Familiar gains XP.
- Familiar levels.
- Familiar evolves.
- Familiar upgrades save.
- Familiar state loads.

Blockers:

- Familiar blocks player movement.
- Familiar state corrupts save.
- Familiar attacks crash or damage wrong target.

## Party Readiness

Required:

- Witch recruitment works once.
- Witch name saves.
- Two-character swap works.
- Witch tag attack works.
- Shadow recruitment works once.
- Shadow name saves.
- Three-character swap works.
- KO auto-switch works.
- Party order saves and loads.
- Party Shrine reorder/rename commits are atomic; rejected payloads do not
  mutate party state.

Blockers:

- Recruitment repeats.
- Swap loses player control.
- KO state softlocks the game.

## Room Route Readiness

Required:

- Modern City route works.
- Rural Road route works.
- Swamp route works.
- Castle Gate route works.
- Damaged Shrine works.
- Tag Tutorial works.
- Samurai Castle route works.
- Masakiro Arena works.
- Rising Torii Seal room works.
- Ascent Test works.
- Sakuramori Court loads.

Blockers:

- Any required transition targets missing room.
- Player spawns in collision.
- Camera shows void in normal play.

## Hub Readiness

Required:

- Sakuramori Court is non-combat.
- Save shrine works.
- Healing clears KO state.
- Party shrine opens and closes.
- Training dummy works.
- Placeholder services are safe.
- Moonpetal Passage placeholder is locked.

Blockers:

- Hub service traps player.
- Save shrine writes invalid state.
- Placeholder service corrupts party state.

## Asset Readiness

Required:

- Prototype starter sprites are imported or intentionally placeholder.
- Witch prototype is imported.
- Shadow prototype is selected or documented as placeholder.
- Standard enemy art is imported.
- Cursed samurai art is imported.
- Oni brute prototype is imported.
- Masakiro prototype is selected.
- Swamp trees pass visual review.
- Title screen imports with pixel-art-safe settings.
- VFX placeholders exist for core combat feedback.

Blockers:

- Gameplay-critical sprite is unreadable.
- Collision does not match required terrain.
- Asset source or license is unknown for release-bound art.

## UI Readiness

Required:

- Title menu works.
- Settings menu works.
- Load Game screen works.
- Accessibility route works.
- Character creation UI works.
- Party HUD works.
- Party HUD shows KO state for active party members.
- Momentum rings are readable.
- Familiar HUD is readable.
- Controller prompts are accurate or safely generic.

Blockers:

- UI text overflows at supported font scale.
- Controller cannot navigate a required screen.
- Accessibility cannot be reached before gameplay.

## Test Readiness

Required:

- Full headless suite passes or known failures are documented.
- Scene-instantiation tests pass.
- Save tests pass.
- Movement tests pass.
- Combat tests pass.
- Enemy AI tests pass.
- Party tests pass.
- Familiar tests pass.
- Room graph tests pass.
- Character creation overwrite tests pass.
- Sakuramori service tests pass.

Manual:

- Keyboard full route passes.
- Xbox-style controller route passes.
- Reduced-motion route passes.
- Save/continue from every checkpoint passes.
- Visual screen-fill review passes.

Blockers:

- Test failures are unexplained.
- Non-fatal warnings hide real failures.
- Full route has untriaged softlock.

## Merge Readiness

Before merging:

- No blocker issues remain.
- High-risk known issues are documented.
- Tests are run and recorded.
- Docs match implementation.
- Prototype art risks are listed.
- Save migration risk is documented.
- Branch diff is reviewed.

Ready means:

- The milestone can be played from New Game to Sakuramori Court.
- The player can save, quit, continue, and load.
- Movement, combat, enemies, familiar, and party systems are testable.
- Remaining work is content expansion or polish, not hidden core breakage.
