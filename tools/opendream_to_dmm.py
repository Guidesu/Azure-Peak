#!/usr/bin/env python3
"""
opendream_to_dmm.py — Convert OpenDream's compiled JSON to an editable .dmm map file.

Usage:
    python opendream_to_dmm.py <input.json> [output.dmm] [--z Z] [--min-x X] [--max-x X] [--min-y Y] [--max-y Y]

If no output path is given, writes to <input_stem>.dmm.
By default exports all z-levels. Use --z to export a single z-level.
Use --min-x/--max-x/--min-y/--max-y to crop the exported region.

The tool reads the OpenDream compiled JSON (roguetown.json) which contains:
  - Types[]: array of type definitions, each with a "Path" field
  - Maps[0].CellDefinitions: dict mapping DMM keys to cell contents
  - Maps[0].Blocks: grid blocks (column-major: X, Y, Z, Width, Height, Cells[])

It reconstructs the DMM text format (TGM-compatible) so the output can be
opened in Dream Maker or any DMM editor.
"""

import json
import sys
import argparse
from pathlib import Path


def load_json(path: str) -> dict:
    print(f"Loading {path} ...")
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def format_value(v) -> str:
    """Format a DM value for DMM var overrides."""
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, str):
        # Check if it's a path (starts with /)
        if v.startswith("/"):
            return v
        # Check if it's a file reference (contains .dmi, .ogg, etc.)
        if "'" in v:
            # Already quoted
            return v
        # Escape and quote as string
        escaped = v.replace("\\", "\\\\").replace('"', '\\"')
        return f'"{escaped}"'
    if isinstance(v, list):
        return "list(" + ", ".join(format_value(x) for x in v) + ")"
    if v is None:
        return "null"
    return str(v)


def format_var_overrides(overrides: dict) -> str:
    """Format a VarOverrides dict into DMM {...} block."""
    if not overrides:
        return ""
    lines = []
    for name, value in overrides.items():
        lines.append(f"\t{name} = {format_value(value)};")
    # Remove trailing semicolon from last line
    if lines:
        lines[-1] = lines[-1].rstrip(";")
    return "{" + "\n" + "\n".join(lines) + "\n}"


def build_cell_string(cell: dict, types: list) -> str:
    """Build the DMM cell definition string for a single cell key."""
    parts = []

    # Objects (movables) come first
    if "Objects" in cell:
        for obj in cell["Objects"]:
            type_idx = obj["Type"]
            type_path = types[type_idx].get("Path", f"<unknown:{type_idx}>")
            overrides = obj.get("VarOverrides", {})
            override_str = format_var_overrides(overrides)
            if override_str:
                parts.append(f"{type_path}{override_str}")
            else:
                parts.append(type_path)

    # Turf
    if "Turf" in cell:
        turf = cell["Turf"]
        type_idx = turf["Type"]
        type_path = types[type_idx].get("Path", f"<unknown:{type_idx}>")
        overrides = turf.get("VarOverrides", {})
        override_str = format_var_overrides(overrides)
        if override_str:
            parts.append(f"{type_path}{override_str}")
        else:
            parts.append(type_path)

    # Area (always last)
    if "Area" in cell:
        area = cell["Area"]
        type_idx = area["Type"]
        type_path = types[type_idx].get("Path", f"<unknown:{type_idx}>")
        overrides = area.get("VarOverrides", {})
        override_str = format_var_overrides(overrides)
        if override_str:
            parts.append(f"{type_path}{override_str}")
        else:
            parts.append(type_path)

    return ",\n".join(parts)


def build_grid(blocks: list, cell_defs: dict, maxx: int, maxy: int, maxz: int,
               z_filter: int = None, min_x: int = None, max_x: int = None,
               min_y: int = None, max_y: int = None) -> list[str]:
    """
    Build the DMM grid lines.

    OpenDream stores blocks in column-major order (each block is one column:
    X, Y=1, Width=1, Height=maxy, Cells=[bottom-to-top]).

    DMM format is:
    (1,1,1) = {"keykeykeykey"
    keykeykeykey"}
    (1,2,1) = {"keykeykeykey"
    keykeykeykey"}

    Each (x,y,z) line is followed by a quoted string of keys.
    The string wraps at line_len characters (typically the width of the map).
    """

    # Build a 3D grid: grid[z][y][x] = cell_key
    # OpenDream blocks are column-major: each block covers (X, Y..Y+Height-1, Z)
    grid = {}
    for block in blocks:
        x = block["X"]
        y_start = block["Y"]
        z = block["Z"]
        w = block["Width"]
        h = block["Height"]
        cells = block["Cells"]

        for dy in range(h):
            for dx in range(w):
                idx = dy * w + dx
                if idx < len(cells):
                    cx = x + dx
                    cy = y_start + dy
                    grid[(cx, cy, z)] = cells[idx]

    # Determine output bounds
    if z_filter is not None:
        zs = [z_filter]
    else:
        zs = sorted(set(z for (_, _, z) in grid.keys()))

    if min_x is None:
        min_x = 1
    if max_x is None:
        max_x = maxx
    if min_y is None:
        min_y = 1
    if max_y is None:
        max_y = maxy

    key_len = len(next(iter(cell_defs.keys()))) if cell_defs else 2

    # DMM/TGM grid format: each (x,y,z) entry is a COLUMN (x fixed, keys span Y).
    # X increments first, Y starts at min_y and goes UP.
    # Keys within each entry go from y=min_y to y=max_y (bottom to top).
    lines = []
    for z in zs:
        for x in range(min_x, max_x + 1):
            coord = f"({x},{min_y},{z})"
            lines.append(f'{coord} = {{"')

            for y in range(min_y, max_y + 1):
                key = grid.get((x, y, z), "aa")
                lines.append(key)

            lines.append('"}')

    return lines


def write_dmm(output_path: str, cell_defs: dict, types: list, grid_lines: list[str],
              key_len: int):
    """Write the complete DMM file."""
    print(f"Writing {output_path} ...")

    with open(output_path, "w", encoding="utf-8", newline="\n") as f:
        # Header (no blank line after, matching dmm2tgm.py format)
        f.write("//MAP CONVERTED BY opendream_to_dmm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE\n")

        # Cell definitions (TGM format, no blank lines between entries)
        for key in sorted(cell_defs.keys()):
            cell = cell_defs[key]
            cell_str = build_cell_string(cell, types)
            f.write(f'"{key}" = (\n')
            f.write(f'{cell_str})\n')

        # Grid
        for line in grid_lines:
            f.write(line + "\n")

    size = Path(output_path).stat().st_size
    print(f"Done! {output_path} ({size:,} bytes)")


def main():
    parser = argparse.ArgumentParser(
        description="Convert OpenDream compiled JSON to an editable .dmm map file."
    )
    parser.add_argument("input", help="Path to the OpenDream compiled JSON (e.g. roguetown.json)")
    parser.add_argument("output", nargs="?", default=None, help="Output .dmm path (default: <input_stem>.dmm)")
    parser.add_argument("--z", type=int, default=None, help="Export only this z-level (default: all)")
    parser.add_argument("--min-x", type=int, default=None, help="Min X coordinate (default: 1)")
    parser.add_argument("--max-x", type=int, default=None, help="Max X coordinate (default: map max)")
    parser.add_argument("--min-y", type=int, default=None, help="Min Y coordinate (default: 1)")
    parser.add_argument("--max-y", type=int, default=None, help="Max Y coordinate (default: map max)")
    parser.add_argument("--no-objects", action="store_true", help="Skip objects (movables) — export only turfs and areas")

    args = parser.parse_args()

    data = load_json(args.input)

    if "Maps" not in data or not data["Maps"]:
        print("ERROR: No maps found in JSON")
        sys.exit(1)

    map_data = data["Maps"][0]
    types = data["Types"]
    cell_defs = map_data["CellDefinitions"]
    blocks = map_data["Blocks"]
    maxx = map_data["MaxX"]
    maxy = map_data["MaxY"]
    maxz = map_data["MaxZ"]

    print(f"Map: {maxx}x{maxy}x{maxz}, {len(cell_defs)} cell definitions, {len(blocks)} blocks")

    # Filter objects if requested
    if args.no_objects:
        for cell in cell_defs.values():
            cell.pop("Objects", None)

    # Determine output path
    if args.output:
        output_path = args.output
    else:
        stem = Path(args.input).stem
        output_path = f"{stem}.dmm"

    # Get key length
    key_len = len(next(iter(cell_defs.keys()))) if cell_defs else 2

    # Build grid
    grid_lines = build_grid(
        blocks, cell_defs, maxx, maxy, maxz,
        z_filter=args.z,
        min_x=args.min_x, max_x=args.max_x,
        min_y=args.min_y, max_y=args.max_y
    )

    # Write DMM
    write_dmm(output_path, cell_defs, types, grid_lines, key_len)


if __name__ == "__main__":
    main()
