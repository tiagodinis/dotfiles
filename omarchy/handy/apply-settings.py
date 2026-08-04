#!/usr/bin/env python3
"""Merge desired Handy settings into its tauri settings store.

Usage: apply-settings.py <settings_store.json> <desired.json>

Only keys listed in <desired.json> are touched (anything starting with "_" is
skipped so the desired file can carry comments). Handy must be stopped while
this runs: its store plugin keeps settings in memory and rewrites the file on
the next change, which would silently undo the merge.

Prints one line per changed setting so the caller can report what it did.
"""

import json
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    store_path, desired_path = sys.argv[1], sys.argv[2]

    with open(store_path) as fh:
        store = json.load(fh)
    with open(desired_path) as fh:
        desired = {k: v for k, v in json.load(fh).items() if not k.startswith("_")}

    if not isinstance(store, dict):
        print(f"{store_path}: store is not a JSON object", file=sys.stderr)
        return 1

    settings = store.setdefault("settings", {})
    if not isinstance(settings, dict):
        print(f"{store_path}: 'settings' is not a JSON object", file=sys.stderr)
        return 1

    for key, value in desired.items():
        if settings.get(key) != value:
            print(f"   {key}: {settings.get(key)!r} -> {value!r}")
            settings[key] = value

    with open(store_path, "w") as fh:
        json.dump(store, fh, indent=4)
        fh.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
