#!/usr/bin/env python3
"""Convert CharacterCreator2D bulk-exported sheets into a Godot SpriteFrames resource."""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path


PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--export-root", type=Path, help="Folder containing <animation_id>_sheet.png files.")
    parser.add_argument("--source-spec", type=Path, help="Optional JSON spec overriding sheet discovery.")
    parser.add_argument("--profile", required=True, type=Path)
    parser.add_argument("--set-id", default="first_slice_player")
    parser.add_argument("--sets", default=Path("resources/character_creator_2d/base_fantasy_bulk_export_sets.json"), type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--frame-width", type=int)
    parser.add_argument("--frame-height", type=int)
    parser.add_argument("--fps", type=float)
    parser.add_argument("--columns", type=int)
    parser.add_argument("--res-root", default=Path("."), type=Path)
    return parser.parse_args()


def png_size(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        signature = handle.read(8)
        if signature != PNG_SIGNATURE:
            raise ValueError(f"{path} is not a PNG")
        chunk_length = struct.unpack(">I", handle.read(4))[0]
        chunk_type = handle.read(4)
        if chunk_type != b"IHDR" or chunk_length < 8:
            raise ValueError(f"{path} is missing a PNG IHDR chunk")
        width, height = struct.unpack(">II", handle.read(8))
        return width, height


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def res_path(path: Path, res_root: Path) -> str:
    resolved_path = path.resolve()
    resolved_root = res_root.resolve()
    relative = resolved_path.relative_to(resolved_root)
    return "res://" + relative.as_posix()


def animation_ids_for_set(sets_path: Path, set_id: str) -> list[str]:
    data = load_json(sets_path)
    return list(data["sets"][set_id]["animations"])


def source_entries(args: argparse.Namespace) -> list[dict]:
    if args.source_spec:
        spec = load_json(args.source_spec)
        return list(spec.get("animations", []))

    if not args.export_root:
        raise ValueError("--export-root or --source-spec is required")

    profile = load_json(args.profile)
    game_exports = profile.get("game_animation_exports", {})
    entries = []
    for animation_id in animation_ids_for_set(args.sets, args.set_id):
        export = game_exports.get(animation_id, {})
        if not export.get("available", False):
            continue
        sheet_path = args.export_root / f"{animation_id}_sheet.png"
        if not sheet_path.exists():
            continue
        entries.append(
            {
                "id": animation_id,
                "sheet": sheet_path.as_posix(),
                "loop": bool(export.get("loop", False)),
                "fps": args.fps,
                "columns": args.columns,
                "frame_width": args.frame_width,
                "frame_height": args.frame_height,
            }
        )
    return entries


def normalize_entry(entry: dict, args: argparse.Namespace, profile: dict) -> dict:
    animation_id = str(entry["id"])
    sheet_path = Path(str(entry["sheet"]))
    width, height = png_size(sheet_path)
    columns = int(entry.get("columns") or args.columns or profile.get("godot_sheet_target", {}).get("columns", 8))
    frame_width = int(entry.get("frame_width") or args.frame_width or 0)
    frame_height = int(entry.get("frame_height") or args.frame_height or 0)
    frame_count = int(entry.get("frame_count", 0))

    if frame_width <= 0:
        frame_width = width // columns if columns > 0 else width
    if frame_height <= 0:
        if frame_count > 0 and columns > 0:
            rows = max(1, (frame_count + columns - 1) // columns)
            frame_height = height // rows
        else:
            frame_height = height
    if frame_count <= 0:
        frames_per_row = max(1, width // frame_width)
        rows = max(1, height // frame_height)
        frame_count = frames_per_row * rows
        columns = frames_per_row

    return {
        "id": animation_id,
        "sheet": sheet_path,
        "sheet_width": width,
        "sheet_height": height,
        "frame_width": frame_width,
        "frame_height": frame_height,
        "frame_count": frame_count,
        "columns": columns,
        "loop": bool(entry.get("loop", profile.get("game_animation_exports", {}).get(animation_id, {}).get("loop", False))),
        "fps": float(entry.get("fps") or args.fps or profile.get("default_export", {}).get("target_fps", 12)),
    }


def write_spriteframes(entries: list[dict], out_path: Path, res_root: Path) -> None:
    ext_resources = []
    sub_resources = []
    animations = []
    ext_index = 1

    for entry in entries:
        ext_id = f"{ext_index}_{entry['id']}"
        ext_index += 1
        ext_resources.append(
            f'[ext_resource type="Texture2D" path="{res_path(entry["sheet"], res_root)}" id="{ext_id}"]'
        )
        frame_refs = []
        for frame_index in range(entry["frame_count"]):
            sub_id = f"AtlasTexture_{entry['id']}_{frame_index}"
            column = frame_index % entry["columns"]
            row = frame_index // entry["columns"]
            x = column * entry["frame_width"]
            y = row * entry["frame_height"]
            sub_resources.extend(
                [
                    f'[sub_resource type="AtlasTexture" id="{sub_id}"]',
                    f'atlas = ExtResource("{ext_id}")',
                    f'region = Rect2({x}, {y}, {entry["frame_width"]}, {entry["frame_height"]})',
                    "",
                ]
            )
            frame_refs.append('{"duration": 1.0, "texture": SubResource("%s")}' % sub_id)
        animations.append(
            '{\n'
            f'"frames": [{", ".join(frame_refs)}],\n'
            f'"loop": {"true" if entry["loop"] else "false"},\n'
            f'"name": &"{entry["id"]}",\n'
            f'"speed": {entry["fps"]:.3f}\n'
            "}"
        )

    load_steps = 1 + len(ext_resources) + sum(entry["frame_count"] for entry in entries)
    lines = [f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]', ""]
    lines.extend(ext_resources)
    lines.append("")
    lines.extend(sub_resources)
    lines.append("[resource]")
    lines.append("animations = [%s]" % ", ".join(animations))
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    profile = load_json(args.profile)
    entries = [normalize_entry(entry, args, profile) for entry in source_entries(args)]
    if not entries:
        raise ValueError("No exported sheets found.")

    write_spriteframes(entries, args.out, args.res_root)
    manifest = {
        "set_id": args.set_id,
        "spriteframes": args.out.as_posix(),
        "animation_count": len(entries),
        "animations": [
            {
                "id": entry["id"],
                "sheet": entry["sheet"].as_posix(),
                "frame_width": entry["frame_width"],
                "frame_height": entry["frame_height"],
                "frame_count": entry["frame_count"],
                "columns": entry["columns"],
                "loop": entry["loop"],
                "fps": entry["fps"],
            }
            for entry in entries
        ],
    }
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print("animations=%d" % len(entries))
    print("spriteframes=%s" % args.out)
    print("manifest=%s" % args.manifest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
