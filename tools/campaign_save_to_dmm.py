#!/usr/bin/env python3
"""Merge a DreamValley campaign checkpoint into its static DMM map."""

import argparse
import json
import re
import string
from collections import OrderedDict
from copy import deepcopy
from pathlib import Path

from opendream_to_dmm import format_value

CELL_HEADER = re.compile(r'^"([A-Za-z]+)" = \($')
GRID_HEADER = re.compile(r'^\((\d+),(\d+),(\d+)\) = \{"$')
VAR_LINE = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*;?$')
KEY_ALPHABET = string.ascii_lowercase + string.ascii_uppercase


def brace_delta(text):
    depth = 0
    quoted = False
    escaped = False
    for char in text:
        if quoted:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
            continue
        if char == '"':
            quoted = True
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
    return depth


def split_entries(text):
    entries = []
    start = 0
    depth = 0
    quoted = False
    escaped = False
    for index, char in enumerate(text):
        if quoted:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quoted = False
            continue
        if char == '"':
            quoted = True
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
        elif char == "," and depth == 0:
            value = text[start:index].strip()
            if value:
                entries.append(value)
            start = index + 1
    value = text[start:].strip()
    if value:
        entries.append(value)
    return entries


def parse_vars(text):
    result = OrderedDict()
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        match = VAR_LINE.match(line)
        if match:
            result[match.group(1)] = match.group(2)
    return result


def parse_entry(text):
    brace = text.find("{")
    if brace == -1:
        return {"path": text.strip(), "vars": OrderedDict()}
    close = text.rfind("}")
    if close < brace:
        return {"path": text.strip(), "vars": OrderedDict()}
    return {
        "path": text[:brace].strip(),
        "vars": parse_vars(text[brace + 1:close]),
    }


def clone_entries(entries):
    return deepcopy(entries)


def parse_dmm(path):
    lines = Path(path).read_text(encoding="utf-8", errors="replace").splitlines()
    cell_defs = OrderedDict()
    prefix = []
    grid_records = []
    index = 0

    while index < len(lines):
        header = CELL_HEADER.match(lines[index])
        if not header:
            if GRID_HEADER.match(lines[index]):
                break
            if not cell_defs:
                prefix.append(lines[index])
            index += 1
            continue

        key = header.group(1)
        block = [lines[index]]
        index += 1
        braces = 0
        while index < len(lines):
            line = lines[index]
            block.append(line)
            braces += brace_delta(line)
            index += 1
            if braces == 0 and line.rstrip().endswith(")"):
                break

        final_line = block[-1]
        if final_line.rstrip().endswith(")"):
            final_line = final_line.rstrip()[:-1]
        body = "\n".join(block[1:-1])
        if final_line:
            body += ("\n" if body else "") + final_line
        cell_defs[key] = [parse_entry(entry) for entry in split_entries(body)]

    while index < len(lines):
        header = GRID_HEADER.match(lines[index])
        if not header:
            index += 1
            continue
        x, y, z = (int(value) for value in header.groups())
        index += 1
        keys = []
        while index < len(lines) and lines[index] != '"}':
            key = lines[index].strip()
            if key:
                keys.append(key)
            index += 1
        if index < len(lines):
            index += 1
        grid_records.append((x, y, z, keys))

    if not cell_defs or not grid_records:
        raise ValueError(f"{path} is not a readable DMM map")

    grid = {}
    for x, y, z, keys in grid_records:
        for offset, key in enumerate(keys):
            grid[(x, y + len(keys) - 1 - offset, z)] = key

    return {
        "prefix": prefix,
        "cell_defs": cell_defs,
        "grid_records": grid_records,
        "grid": grid,
        "key_len": len(next(iter(cell_defs))),
    }


def encode_key(number, key_len):
    base = len(KEY_ALPHABET)
    chars = []
    for _ in range(key_len):
        chars.append(KEY_ALPHABET[number % base])
        number //= base
    if number:
        raise ValueError("DMM key space exhausted")
    return "".join(reversed(chars))


def render_entry(entry):
    path = entry["path"]
    variables = entry["vars"]
    if not variables:
        return path
    lines = [f"{path}{{"]
    items = list(variables.items())
    for index, (name, value) in enumerate(items):
        suffix = ";" if index < len(items) - 1 else ""
        lines.append(f"\t{name} = {value}{suffix}")
    lines.append("}")
    return "\n".join(lines)


def render_cell(entries):
    rendered = []
    for index, entry in enumerate(entries):
        value = render_entry(entry)
        suffix = "," if index < len(entries) - 1 else ""
        rendered.append(value + suffix)
    return "\n".join(rendered)


def cell_signature(entries):
    return tuple((entry["path"], tuple(entry["vars"].items())) for entry in entries)


def format_saved_vars(values):
    result = OrderedDict()
    if not isinstance(values, dict):
        return result
    for name, value in values.items():
        result[name] = format_value(value)
    return result


def merge(base_path, save_path, output_path, z_filter=None, z_offset=1):
    dmm = parse_dmm(base_path)
    save = json.loads(Path(save_path).read_text(encoding="utf-8"))
    snapshot = save.get("snapshot", {})
    cell_defs = dmm["cell_defs"]
    grid = dmm["grid"]
    working = {}
    stats = {
        "turf_changes": 0,
        "mapped_objects": 0,
        "new_objects": 0,
        "skipped_out_of_bounds": 0,
        "skipped_invalid": 0,
        "modified_cells": 0,
    }

    def get_cell(coord):
        if coord not in grid:
            stats["skipped_out_of_bounds"] += 1
            return None
        if coord not in working:
            working[coord] = clone_entries(cell_defs[grid[coord]])
        return working[coord]

    for state in snapshot.get("turfs", []):
        if not isinstance(state, dict):
            stats["skipped_invalid"] += 1
            continue
        x, y, world_z = state.get("x"), state.get("y"), state.get("z")
        turf_type = state.get("type")
        if not all(isinstance(value, int) for value in (x, y, world_z)) or not isinstance(turf_type, str):
            stats["skipped_invalid"] += 1
            continue
        if z_filter is not None and world_z != z_filter:
            continue
        map_z = world_z - z_offset
        entries = get_cell((x, y, map_z))
        if entries is None:
            continue
        turf = next((entry for entry in entries if entry["path"].startswith("/turf")), None)
        if turf is None:
            stats["skipped_invalid"] += 1
            continue
        turf["path"] = turf_type
        turf["vars"] = OrderedDict()
        stats["turf_changes"] += 1

    used_mapped = {}
    for state in snapshot.get("objects", []):
        if not isinstance(state, dict):
            stats["skipped_invalid"] += 1
            continue
        x, y, world_z = state.get("x"), state.get("y"), state.get("z")
        object_type = state.get("type")
        if not all(isinstance(value, int) for value in (x, y, world_z)) or not isinstance(object_type, str):
            stats["skipped_invalid"] += 1
            continue
        if z_filter is not None and world_z != z_filter:
            continue
        map_z = world_z - z_offset
        entries = get_cell((x, y, map_z))
        if entries is None:
            continue
        saved_vars = format_saved_vars(state.get("vars"))
        if state.get("mapped"):
            match_key = ((x, y, map_z), object_type)
            start = used_mapped.get(match_key, 0)
            matches = [entry for entry in entries if entry["path"] == object_type]
            if start >= len(matches):
                stats["skipped_invalid"] += 1
                continue
            target = matches[start]
            used_mapped[match_key] = start + 1
            target["vars"].update(saved_vars)
            stats["mapped_objects"] += 1
        else:
            entries.insert(-1, {"path": object_type, "vars": saved_vars})
            stats["new_objects"] += 1

    signatures = {cell_signature(entries): key for key, entries in cell_defs.items()}
    next_key = 0
    used_keys = set(cell_defs)

    for coord, entries in working.items():
        signature = cell_signature(entries)
        key = signatures.get(signature)
        if key is None:
            while True:
                key = encode_key(next_key, dmm["key_len"])
                next_key += 1
                if key not in used_keys:
                    break
            used_keys.add(key)
            signatures[signature] = key
            cell_defs[key] = entries
        grid[coord] = key
        stats["modified_cells"] += 1

    with open(output_path, "w", encoding="utf-8", newline="\n") as output:
        for line in dmm["prefix"]:
            output.write(line + "\n")
        for key, entries in cell_defs.items():
            output.write(f'"{key}" = (\n{render_cell(entries)})\n')
        for x, y, z, keys in dmm["grid_records"]:
            output.write(f'({x},{y},{z}) = {{"\n')
            for offset in range(len(keys)):
                output.write(grid[(x, y + len(keys) - 1 - offset, z)] + "\n")
            output.write('"}\n')

    stats["output_bytes"] = Path(output_path).stat().st_size
    return stats


def main():
    parser = argparse.ArgumentParser(description="Merge a DreamValley save.json into a static BYOS DMM.")
    parser.add_argument("base_dmm", help="Static map, e.g. _maps/map_files/byos/byos.dmm")
    parser.add_argument("save_json", help="Campaign save, e.g. data/dreamvalley/save.json")
    parser.add_argument("output_dmm", nargs="?", help="Merged output path")
    parser.add_argument("--z", type=int, default=None, help="Only apply save entries for this world z-level")
    parser.add_argument("--z-offset", type=int, default=1, help="Subtract this runtime-to-DMM z offset (default: 1 for BYOS)")
    args = parser.parse_args()

    output = args.output_dmm or f"{Path(args.base_dmm).stem}_saved.dmm"
    stats = merge(args.base_dmm, args.save_json, output, args.z, args.z_offset)
    print(f"Wrote {output} ({stats['output_bytes']:,} bytes)")
    print(json.dumps(stats, indent=2))


if __name__ == "__main__":
    main()
