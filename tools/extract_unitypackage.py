#!/usr/bin/env python3
"""Extract Unity .unitypackage assets into a stable Godot-facing tree.

Unity packages are tar archives where each asset lives in a GUID-named folder
with a `pathname` file and usually an `asset` payload. This tool preserves the
original Unity pathname in a JSON manifest while copying payloads into readable
project paths.
"""

from __future__ import annotations

import argparse
import json
import shutil
import tarfile
import tempfile
from collections import Counter
from pathlib import Path

GODOT_RUNTIME_EXTENSIONS = {
    ".fbx",
    ".jpeg",
    ".jpg",
    ".pdf",
    ".png",
    ".txt",
    ".webp",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--package", required=True, type=Path)
    parser.add_argument("--out-dir", required=True, type=Path)
    parser.add_argument(
        "--raw-out-dir",
        type=Path,
        help="Directory for Unity-only payloads. A .gdignore file is written here.",
    )
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--root-prefix", default="Assets/CharacterCreator2D/")
    parser.add_argument("--clean", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    package_path: Path = args.package
    out_dir: Path = args.out_dir
    raw_out_dir: Path | None = args.raw_out_dir
    manifest_path: Path = args.manifest

    if not package_path.exists():
        raise FileNotFoundError(package_path)

    if args.clean and out_dir.exists():
        shutil.rmtree(out_dir)
    if args.clean and raw_out_dir and raw_out_dir.exists():
        shutil.rmtree(raw_out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    if raw_out_dir:
        raw_out_dir.mkdir(parents=True, exist_ok=True)
        (raw_out_dir / ".gdignore").write_text("", encoding="utf-8")
    manifest_path.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="unitypackage_") as temp_name:
        temp_dir = Path(temp_name)
        with tarfile.open(package_path, "r:*") as archive:
            archive.extractall(temp_dir, filter="data")

        entries = []
        extension_counts: Counter[str] = Counter()
        category_counts: Counter[str] = Counter()
        copied_count = 0

        for guid_dir in sorted(path for path in temp_dir.iterdir() if path.is_dir()):
            pathname_file = guid_dir / "pathname"
            if not pathname_file.exists():
                continue

            unity_path = pathname_file.read_text(encoding="utf-8", errors="replace").strip()
            if not unity_path.startswith(args.root_prefix):
                continue

            relative_path = Path(unity_path.removeprefix(args.root_prefix))
            asset_file = guid_dir / "asset"
            meta_file = guid_dir / "asset.meta"
            preview_file = guid_dir / "preview.png"
            has_payload = asset_file.exists()
            extension = relative_path.suffix.lower()
            category = relative_path.parts[0] if relative_path.parts else ""
            copied_path = ""
            meta_path = ""
            preview_path = ""
            import_role = ""

            if has_payload:
                is_runtime_asset = extension in GODOT_RUNTIME_EXTENSIONS or raw_out_dir is None
                target_root = out_dir if is_runtime_asset else raw_out_dir
                assert target_root is not None
                import_role = "runtime" if is_runtime_asset else "unity_raw"
                copied_path = str((target_root / relative_path).as_posix())
                target = target_root / relative_path
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(asset_file, target)
                copied_count += 1
                extension_counts[extension or "<none>"] += 1
                if category:
                    category_counts[category] += 1

            if meta_file.exists():
                metadata_root = raw_out_dir if raw_out_dir else out_dir
                meta_target = metadata_root / "_unity_meta" / relative_path.with_suffix(relative_path.suffix + ".meta")
                meta_target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(meta_file, meta_target)
                meta_path = str(meta_target.as_posix())

            if preview_file.exists():
                preview_root = raw_out_dir if raw_out_dir else out_dir
                preview_target = preview_root / "_unity_previews" / relative_path.with_suffix(relative_path.suffix + ".preview.png")
                preview_target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(preview_file, preview_target)
                preview_path = str(preview_target.as_posix())

            entries.append(
                {
                    "guid": guid_dir.name,
                    "unity_path": unity_path,
                    "relative_path": relative_path.as_posix(),
                    "godot_path": copied_path,
                    "meta_path": meta_path,
                    "preview_path": preview_path,
                    "extension": extension,
                    "category": category,
                    "has_payload": has_payload,
                    "import_role": import_role,
                }
            )

    manifest = {
        "source_package": str(package_path.as_posix()),
        "root_prefix": args.root_prefix,
        "runtime_output_dir": str(out_dir.as_posix()),
        "raw_output_dir": str(raw_out_dir.as_posix()) if raw_out_dir else "",
        "entry_count": len(entries),
        "copied_asset_count": copied_count,
        "extension_counts": dict(sorted(extension_counts.items())),
        "category_counts": dict(sorted(category_counts.items())),
        "entries": entries,
    }
    manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")

    print("entries=%d copied=%d" % (len(entries), copied_count))
    print("manifest=%s" % manifest_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
