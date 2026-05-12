#!/usr/bin/env python3
"""Build a Godot-facing CharacterCreator2D animation export profile."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


GAME_ANIMATION_MAP = {
    "idle": {"base": "Idle", "aim": "None", "loop": True},
    "walk": {"base": "Walk", "aim": "None", "loop": True},
    "run": {"base": "Run", "aim": "None", "loop": True},
    "dash": {"base": "Sprint", "aim": "None", "loop": False},
    "jump": {"base": "Jump", "aim": "None", "loop": False},
    "fall": {"base": "Fall", "aim": "None", "loop": True},
    "climb_up": {"base": "Climb Up", "aim": "None", "loop": True},
    "climb_down": {"base": "Climb Down", "aim": "None", "loop": True},
    "crouch": {"base": "Crouch", "aim": "None", "loop": False},
    "hurt": {"base": "Hit", "aim": "None", "loop": False},
    "death": {"base": "Die", "aim": "None", "loop": False},
    "melee_1": {"base": "Attack Main Hand 1", "aim": "None", "loop": False},
    "melee_2": {"base": "Attack Main Hand 2", "aim": "None", "loop": False},
    "melee_3": {"base": "Attack Main Hand 3", "aim": "None", "loop": False},
    "heavy": {"base": "Attack Two Handed 1", "aim": "None", "loop": False},
    "cast": {"base": "Cast 1", "aim": "None", "loop": False},
    "guard": {"base": "Shield Block", "aim": "None", "loop": False},
    "shoot": {"base": "Idle", "aim": "Shot Main Hand", "loop": False},
    "rifle_shoot": {"base": "Idle Holding Rifle", "aim": "Shot Rifle", "loop": False},
}

LOOP_HINTS = ("idle", "walk", "run", "sprint", "swim", "climb", "aim")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--raw-dir", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    return parser.parse_args()


def state_names(asset_path: Path) -> list[str]:
    names: list[str] = []
    in_state_names = False
    for line in asset_path.read_text(encoding="utf-8", errors="replace").splitlines():
        stripped = line.strip()
        if stripped == "stateName:":
            in_state_names = True
            continue
        if in_state_names and stripped.startswith("- "):
            names.append(stripped.removeprefix("- ").strip())
        elif in_state_names and stripped and not stripped.startswith("- "):
            break
    return names


def export_id_for_state(prefix: str, state_name: str) -> str:
    return prefix + ":" + state_name.lower().replace(" ", "_")


def loop_hint(state_name: str) -> bool:
    normalized = state_name.lower()
    return any(hint in normalized for hint in LOOP_HINTS)


def main() -> int:
    args = parse_args()
    raw_dir: Path = args.raw_dir
    out_path: Path = args.out
    animation_list_dir = raw_dir / "Creator UI" / "Animation List"

    base_states = state_names(animation_list_dir / "Base Layer.asset")
    aim_states = state_names(animation_list_dir / "Aim Layer.asset")
    export_states = state_names(animation_list_dir / "Export PNG.asset")
    available_base = set(base_states)
    available_aim = set(aim_states)

    game_exports = {}
    for alias_id, export in GAME_ANIMATION_MAP.items():
        game_exports[alias_id] = {
            **export,
            "available": export["base"] in available_base and export["aim"] in available_aim,
        }

    all_animation_exports = {}
    for state_name in base_states:
        export_id = export_id_for_state("base", state_name)
        all_animation_exports[export_id] = {
            "id": export_id,
            "layer": "base",
            "base": state_name,
            "aim": "None",
            "loop": loop_hint(state_name),
            "available": True,
            "source_path": f"Data/Animations/Base/{state_name}.anim",
        }
    for state_name in aim_states:
        if state_name == "None":
            continue
        export_id = export_id_for_state("aim", state_name)
        all_animation_exports[export_id] = {
            "id": export_id,
            "layer": "aim",
            "base": "Idle",
            "aim": state_name,
            "loop": loop_hint(state_name),
            "available": True,
            "source_path": f"Data/Animations/Aim/{state_name}.anim",
        }

    profile = {
        "source": {
            "raw_dir": raw_dir.as_posix(),
            "animation_lists": [
                "Creator UI/Animation List/Base Layer.asset",
                "Creator UI/Animation List/Aim Layer.asset",
                "Creator UI/Animation List/Export PNG.asset",
            ],
        },
        "capabilities": {
            "port_target": "godot_native",
            "export_modes": ["SingleImage", "PNGSequence", "SpriteSheet"],
            "backgrounds": ["Transparent", "Black", "White", "Gray", "Magenta", "Green"],
            "scale_modes": ["Automatic", "ActualPixelSize"],
            "supports_base_layer": True,
            "supports_aim_layer": True,
            "supports_atlas_export": "Atlas" in export_states,
            "supports_emotes": True,
            "supports_color_palettes": True,
        },
        "default_export": {
            "target_fps": 12,
            "width": 512,
            "height": 512,
            "background": "Transparent",
            "export_mode": "PNGSequence",
            "scale_mode": "Automatic",
            "super_sampling": 2,
        },
        "godot_sheet_target": {
            "columns": 8,
            "frame_anchor": "bottom_center",
            "transparent_background": True,
            "trim_empty_margin": False,
        },
        "base_layer_states": base_states,
        "aim_layer_states": aim_states,
        "export_states": export_states,
        "all_animation_exports": all_animation_exports,
        "game_animation_exports": game_exports,
    }

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(profile, indent=2), encoding="utf-8")
    print(
        "base_states=%d aim_states=%d all_exports=%d game_aliases=%d"
        % (len(base_states), len(aim_states), len(all_animation_exports), len(game_exports))
    )
    print("profile=%s" % out_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
