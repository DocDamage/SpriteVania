# Milestone Visual Review Checklist

Date: 2026-05-11

Scope:

- Castle Gate blockout rooms.
- Samurai Castle Wing blockout rooms.
- Masakiro boss arena.
- Rising Torii Seal room.
- Sakuramori Court hub rooms.

Automated checks:

- `tests/test_asset_integration.gd` verifies derived character, enemy, boss, VFX, and blockout tileset resources load.
- `tests/test_asset_integration.gd` verifies Masakiro uses derived boss frames and an oni overlay.
- `tests/test_asset_integration.gd` verifies representative milestone rooms instantiate runtime zone art.
- `tests/test_scene_instantiation.gd` verifies committed scenes instantiate.

Review status:

- Castle Gate has runtime castle backdrop art and readable ground silhouette.
- Samurai Castle has runtime Feudal Japan backdrop art and Masakiro prototype boss frames.
- Sakuramori Court has runtime hub backdrop art, save shrine, party shrine, training yard, and locked Moonpetal placeholder.
- Combat VFX resources exist for hit spark and Rising Torii Seal pickup.

Known visual limitations:

- Character and boss prototype frame resources currently use single source frames per action.
- Blockout rooms still need final tile layout, prop placement, parallax depth tuning, and final palette pass.
- Masakiro phase 3 is represented by an oni overlay VFX resource rather than a full alternate sprite.
