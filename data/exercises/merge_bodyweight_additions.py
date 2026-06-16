#!/usr/bin/env python3
"""Merge bodyweight_additions.json into difficulty files (skip duplicate IDs)."""

from __future__ import annotations

import json
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent


def load_json(path: Path) -> list:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def save_json(path: Path, data: list) -> None:
    with path.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")


def main() -> None:
    additions_path = SCRIPT_DIR / "bodyweight_additions.json"
    with additions_path.open(encoding="utf-8") as f:
        additions = json.load(f)

    mapping = {
        "beginner": SCRIPT_DIR / "beginner.json",
        "intermediate": SCRIPT_DIR / "intermediate.json",
        "advanced": SCRIPT_DIR / "advanced.json",
    }

    total_added = 0
    for level, target_path in mapping.items():
        existing = load_json(target_path)
        existing_ids = {ex["id"] for ex in existing}
        to_add = []
        for ex in additions.get(level, []):
            if ex["id"] in existing_ids:
                print(f"  skip duplicate {ex['id']} in {level}")
                continue
            ex = dict(ex)
            ex_id = ex["id"]
            ex["nameKey"] = f"exercise_{ex_id}_name"
            ex["descriptionKey"] = f"exercise_{ex_id}_description"
            if ex.get("beginnerTips"):
                ex["beginnerTipsKey"] = f"exercise_{ex_id}_beginner_tips"
            to_add.append(ex)

        if not to_add:
            continue

        # Insert work exercises before rest_* entries when present.
        rest_index = next(
            (i for i, ex in enumerate(existing) if ex["id"].startswith("rest_")),
            len(existing),
        )
        updated = existing[:rest_index] + to_add + existing[rest_index:]
        save_json(target_path, updated)
        total_added += len(to_add)
        print(f"✅ {level}: added {len(to_add)} exercises -> {target_path.name}")

    print(f"\nTotal added: {total_added}")
    if total_added:
        print("Next: python data/exercises/combine_exercises.py")
        print("Next: python data/exercises/generate_localization_keys.py")
        print("Next: python data/exercises/translate_exercises.py  (optional FR names)")


if __name__ == "__main__":
    main()
