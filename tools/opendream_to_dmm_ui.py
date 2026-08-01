#!/usr/bin/env python3
"""
opendream_to_dmm_ui.py — Web UI for converting OpenDream JSON to .dmm map files.

Starts a local web server, opens a browser, and provides a graphical interface
for selecting the JSON file, setting export options, and downloading the result.

Usage:
    python tools/opendream_to_dmm_ui.py [port]

Defaults to port 8477. Opens browser automatically.
"""

import json
import os
import sys
import threading
import webbrowser
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
from pathlib import Path

# Reuse the core logic from the CLI tool
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from opendream_to_dmm import (
    format_value, format_var_overrides, build_cell_string, build_grid
)

# ─── State ───────────────────────────────────────────────────────────────────

loaded_data = None
loaded_path = None

# ─── HTML/CSS/JS ─────────────────────────────────────────────────────────────

HTML_PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>OpenDream → DMM Converter</title>
<style>
  :root {
    --bg: #1a1a2e;
    --surface: #16213e;
    --surface2: #0f3460;
    --accent: #e94560;
    --accent2: #533483;
    --text: #eee;
    --text-dim: #999;
    --border: #333;
    --success: #4ecca3;
    --error: #e94560;
    --radius: 8px;
  }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
    background: var(--bg);
    color: var(--text);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
  }
  .container {
    max-width: 720px;
    width: 100%;
  }
  h1 {
    font-size: 1.6rem;
    margin-bottom: 4px;
    background: linear-gradient(135deg, var(--accent), var(--accent2));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
  .subtitle { color: var(--text-dim); font-size: 0.85rem; margin-bottom: 24px; }
  .card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 24px;
    margin-bottom: 16px;
  }
  .card h2 {
    font-size: 0.8rem;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: var(--text-dim);
    margin-bottom: 16px;
  }
  .file-input-wrap {
    display: flex;
    gap: 12px;
    align-items: center;
  }
  input[type="text"], select {
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 6px;
    color: var(--text);
    padding: 10px 14px;
    font-size: 0.9rem;
    width: 100%;
    outline: none;
    transition: border-color 0.2s;
  }
  input[type="text"]:focus, select:focus { border-color: var(--accent); }
  input[type="number"] {
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 6px;
    color: var(--text);
    padding: 8px 12px;
    font-size: 0.85rem;
    width: 80px;
    outline: none;
  }
  input[type="number"]:focus { border-color: var(--accent); }
  .btn {
    background: linear-gradient(135deg, var(--accent), var(--accent2));
    color: white;
    border: none;
    border-radius: 6px;
    padding: 10px 24px;
    font-size: 0.9rem;
    cursor: pointer;
    transition: opacity 0.2s, transform 0.1s;
    font-weight: 600;
  }
  .btn:hover { opacity: 0.9; }
  .btn:active { transform: scale(0.97); }
  .btn:disabled { opacity: 0.4; cursor: not-allowed; }
  .btn-secondary {
    background: var(--surface2);
    border: 1px solid var(--border);
  }
  .btn-browse {
    white-space: nowrap;
    flex-shrink: 0;
  }
  .row { display: flex; gap: 12px; margin-bottom: 12px; align-items: center; }
  .row label { font-size: 0.85rem; color: var(--text-dim); min-width: 100px; }
  .checkbox-row {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 12px;
  }
  .checkbox-row input[type="checkbox"] {
    width: 18px; height: 18px; accent-color: var(--accent);
  }
  .checkbox-row label { color: var(--text); font-size: 0.85rem; cursor: pointer; }
  .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
  .grid-4 { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr; gap: 8px; }
  .status {
    padding: 12px 16px;
    border-radius: 6px;
    font-size: 0.85rem;
    margin-top: 12px;
    display: none;
  }
  .status.show { display: block; }
  .status.success { background: rgba(78,204,163,0.15); border: 1px solid var(--success); color: var(--success); }
  .status.error { background: rgba(233,69,96,0.15); border: 1px solid var(--error); color: var(--error); }
  .status.loading { background: rgba(83,52,131,0.15); border: 1px solid var(--accent2); color: var(--text); }
  .map-info {
    background: var(--surface2);
    border-radius: 6px;
    padding: 14px 16px;
    margin-top: 12px;
    font-size: 0.8rem;
    color: var(--text-dim);
    display: none;
  }
  .map-info.show { display: block; }
  .map-info span { color: var(--text); font-weight: 600; }
  .download-link {
    display: inline-block;
    margin-top: 12px;
    color: var(--accent);
    text-decoration: none;
    font-size: 0.9rem;
    font-weight: 600;
  }
  .download-link:hover { text-decoration: underline; }
  .spinner {
    display: inline-block;
    width: 14px; height: 14px;
    border: 2px solid var(--text-dim);
    border-top-color: var(--accent);
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
    margin-right: 8px;
    vertical-align: middle;
  }
  @keyframes spin { to { transform: rotate(360deg); } }
  .hint { font-size: 0.75rem; color: var(--text-dim); margin-top: 4px; }
  .z-select-wrap { display: flex; gap: 8px; align-items: center; }
  .divider { height: 1px; background: var(--border); margin: 16px 0; }
</style>
</head>
<body>
<div class="container">
  <h1>OpenDream &rarr; DMM Converter</h1>
  <p class="subtitle">Export saved world state from OpenDream's compiled JSON to an editable .dmm map file</p>

  <!-- Step 1: Load JSON -->
  <div class="card">
    <h2>1 &middot; Load JSON</h2>
    <div class="file-input-wrap">
      <input type="text" id="jsonPath" placeholder="Path to roguetown.json ..." />
      <button class="btn btn-secondary btn-browse" onclick="browseFile()">Browse</button>
      <button class="btn" onclick="loadJson()" id="loadBtn">Load</button>
    </div>
    <p class="hint">Enter the full path to the OpenDream compiled JSON file (e.g. C:\\...\\roguetown.json)</p>
    <div class="map-info" id="mapInfo"></div>
    <div class="status" id="loadStatus"></div>
  </div>

  <!-- Step 2: Export Options -->
  <div class="card" id="optionsCard" style="opacity:0.4; pointer-events:none;">
    <h2>2 &middot; Export Options</h2>

    <div class="row">
      <label>Z-level</label>
      <div class="z-select-wrap">
        <select id="zLevel" onchange="onZChange()">
          <option value="">All z-levels</option>
        </select>
      </div>
    </div>

    <div class="divider"></div>

    <div class="row">
      <label>Region</label>
      <div style="font-size:0.8rem; color:var(--text-dim);">Leave blank to export the full map</div>
    </div>
    <div class="grid-4">
      <div>
        <input type="number" id="minX" placeholder="Min X" disabled />
        <div class="hint">Min X</div>
      </div>
      <div>
        <input type="number" id="maxX" placeholder="Max X" disabled />
        <div class="hint">Max X</div>
      </div>
      <div>
        <input type="number" id="minY" placeholder="Min Y" disabled />
        <div class="hint">Min Y</div>
      </div>
      <div>
        <input type="number" id="maxY" placeholder="Max Y" disabled />
        <div class="hint">Max Y</div>
      </div>
    </div>

    <div class="divider"></div>

    <div class="checkbox-row">
      <input type="checkbox" id="noObjects" />
      <label for="noObjects">Skip objects (movables) &mdash; export only turfs and areas</label>
    </div>

    <div class="status" id="exportStatus"></div>
    <div style="margin-top:16px;">
      <button class="btn" onclick="exportDmm()" id="exportBtn" disabled>Export to .dmm</button>
      <a class="download-link" id="downloadLink" style="display:none;" href="#" download>&#8595; Download .dmm</a>
    </div>
  </div>
</div>

<script>
let mapBounds = null;

function setStatus(id, msg, type) {
  const el = document.getElementById(id);
  el.className = 'status show ' + type;
  el.innerHTML = msg;
}
function clearStatus(id) {
  const el = document.getElementById(id);
  el.className = 'status';
  el.innerHTML = '';
}

async function browseFile() {
  // We can't open a native file picker from a web page for arbitrary paths,
  // but we can prompt the user.
  const path = prompt('Enter the full path to the OpenDream JSON file:');
  if (path) document.getElementById('jsonPath').value = path;
}

async function loadJson() {
  const path = document.getElementById('jsonPath').value.trim();
  if (!path) { setStatus('loadStatus', 'Please enter a JSON file path.', 'error'); return; }

  setStatus('loadStatus', '<span class="spinner"></span>Loading JSON (this may take a moment for large files)...', 'loading');
  document.getElementById('loadBtn').disabled = true;

  try {
    const resp = await fetch('/api/load', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({path: path})
    });
    const data = await resp.json();
    if (data.error) {
      setStatus('loadStatus', 'Error: ' + data.error, 'error');
      document.getElementById('mapInfo').className = 'map-info';
      return;
    }
    mapBounds = data;
    const info = document.getElementById('mapInfo');
    info.className = 'map-info show';
    info.innerHTML = `Map: <span>${data.maxx}</span> x <span>${data.maxy}</span> x <span>${data.maxz}</span> &middot; <span>${data.cellCount}</span> cell definitions &middot; <span>${data.fileSize}</span>`;
    setStatus('loadStatus', 'Loaded successfully!', 'success');

    // Populate z-level dropdown
    const zSelect = document.getElementById('zLevel');
    zSelect.innerHTML = '<option value="">All z-levels</option>';
    for (let z = 1; z <= data.maxz; z++) {
      zSelect.innerHTML += `<option value="${z}">Z-level ${z}</option>`;
    }

    // Enable options
    const card = document.getElementById('optionsCard');
    card.style.opacity = '1';
    card.style.pointerEvents = 'auto';
    document.getElementById('exportBtn').disabled = false;
    ['minX','maxX','minY','maxY'].forEach(id => document.getElementById(id).disabled = false);

    // Set default region values
    document.getElementById('minX').placeholder = '1';
    document.getElementById('maxX').placeholder = data.maxx;
    document.getElementById('minY').placeholder = '1';
    document.getElementById('maxY').placeholder = data.maxy;
  } catch(e) {
    setStatus('loadStatus', 'Error: ' + e.message, 'error');
  } finally {
    document.getElementById('loadBtn').disabled = false;
  }
}

function onZChange() {}

async function exportDmm() {
  if (!mapBounds) return;

  const z = document.getElementById('zLevel').value;
  const minX = document.getElementById('minX').value;
  const maxX = document.getElementById('maxX').value;
  const minY = document.getElementById('minY').value;
  const maxY = document.getElementById('maxY').value;
  const noObjects = document.getElementById('noObjects').checked;

  const params = new URLSearchParams();
  if (z) params.set('z', z);
  if (minX) params.set('minX', minX);
  if (maxX) params.set('maxX', maxX);
  if (minY) params.set('minY', minY);
  if (maxY) params.set('maxY', maxY);
  if (noObjects) params.set('noObjects', '1');

  setStatus('exportStatus', '<span class="spinner"></span>Converting to DMM...', 'loading');
  document.getElementById('exportBtn').disabled = true;
  document.getElementById('downloadLink').style.display = 'none';

  try {
    const resp = await fetch('/api/export?' + params.toString());
    const data = await resp.json();
    if (data.error) {
      setStatus('exportStatus', 'Error: ' + data.error, 'error');
      return;
    }
    setStatus('exportStatus', `Done! Generated <span style="color:var(--success)">${data.size}</span> (${data.cells} cells, ${data.rows} grid rows)`, 'success');
    const dl = document.getElementById('downloadLink');
    dl.href = '/api/download/' + encodeURIComponent(data.filename);
    dl.download = data.filename;
    dl.style.display = 'inline-block';
  } catch(e) {
    setStatus('exportStatus', 'Error: ' + e.message, 'error');
  } finally {
    document.getElementById('exportBtn').disabled = false;
  }
}

// Enter key on path input triggers load
document.getElementById('jsonPath').addEventListener('keydown', e => {
  if (e.key === 'Enter') loadJson();
});
</script>
</body>
</html>"""

# ─── Server ──────────────────────────────────────────────────────────────────

class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass  # suppress default logging

    def do_GET(self):
        parsed = urlparse(self.path)

        if parsed.path == "/" or parsed.path == "/index.html":
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(HTML_PAGE.encode("utf-8"))
            return

        if parsed.path.startswith("/api/download/"):
            from urllib.parse import unquote
            filename = unquote(parsed.path[len("/api/download/"):])
            output_path = os.path.join(tempfile_dir, filename)
            if not os.path.exists(output_path):
                self.send_json({"error": "File not found: " + filename})
                return
            self.send_response(200)
            self.send_header("Content-Type", "application/octet-stream")
            self.send_header("Content-Disposition", f'attachment; filename="{filename}"')
            self.end_headers()
            with open(output_path, "rb") as f:
                self.wfile.write(f.read())
            return

        if parsed.path == "/api/export":
            self.handle_export(parse_qs(parsed.query))
            return

        self.send_response(404)
        self.end_headers()

    def do_POST(self):
        parsed = urlparse(self.path)

        if parsed.path == "/api/load":
            self.handle_load()
            return

        self.send_response(404)
        self.end_headers()

    def send_json(self, obj):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(obj).encode("utf-8"))

    def handle_load(self):
        global loaded_data, loaded_path
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length)
        try:
            req = json.loads(body)
            path = req.get("path", "").strip()
            if not path or not os.path.exists(path):
                self.send_json({"error": f"File not found: {path}"})
                return
            loaded_path = path
            with open(path, "r", encoding="utf-8") as f:
                loaded_data = json.load(f)
            if "Maps" not in loaded_data or not loaded_data["Maps"]:
                self.send_json({"error": "No maps found in JSON"})
                loaded_data = None
                return
            m = loaded_data["Maps"][0]
            size = os.path.getsize(path)
            size_str = f"{size / 1024 / 1024:.1f} MB" if size > 1024*1024 else f"{size / 1024:.0f} KB"
            self.send_json({
                "maxx": m["MaxX"],
                "maxy": m["MaxY"],
                "maxz": m["MaxZ"],
                "cellCount": len(m["CellDefinitions"]),
                "fileSize": size_str,
            })
        except Exception as e:
            self.send_json({"error": str(e)})
            loaded_data = None

    def handle_export(self, params):
        global loaded_data, loaded_path
        if loaded_data is None:
            self.send_json({"error": "No JSON loaded"})
            return

        try:
            m = loaded_data["Maps"][0]
            types = loaded_data["Types"]
            cell_defs = m["CellDefinitions"]
            blocks = m["Blocks"]
            maxx, maxy, maxz = m["MaxX"], m["MaxY"], m["MaxZ"]

            z = params.get("z", [None])[0]
            z = int(z) if z else None
            min_x = int(params["minX"][0]) if params.get("minX", [None])[0] else None
            max_x = int(params["maxX"][0]) if params.get("maxX", [None])[0] else None
            min_y = int(params["minY"][0]) if params.get("minY", [None])[0] else None
            max_y = int(params["maxY"][0]) if params.get("maxY", [None])[0] else None
            no_objects = params.get("noObjects", ["0"])[0] == "1"

            # Clone cell_defs if we need to filter objects
            if no_objects:
                cell_defs = {k: {**v, "Objects": None} for k, v in cell_defs.items()}
                cell_defs = {k: v for k, v in cell_defs.items() if "Objects" in v}
                # Actually just remove objects from each cell
                cell_defs = {}
                for k, v in m["CellDefinitions"].items():
                    cell = dict(v)
                    cell.pop("Objects", None)
                    cell_defs[k] = cell

            grid_lines = build_grid(
                blocks, cell_defs, maxx, maxy, maxz,
                z_filter=z, min_x=min_x, max_x=max_x,
                min_y=min_y, max_y=max_y
            )

            # Generate output filename
            stem = Path(loaded_path).stem if loaded_path else "map"
            suffix = f"_z{z}" if z else ""
            suffix += f"_crop" if any([min_x, max_x, min_y, max_y]) else ""
            suffix += "_noobj" if no_objects else ""
            filename = f"{stem}{suffix}.dmm"
            output_path = os.path.join(tempfile_dir, filename)

            # Write DMM
            with open(output_path, "w", encoding="utf-8", newline="\n") as f:
                f.write("//MAP CONVERTED BY opendream_to_dmm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE\n\n")
                for key in sorted(cell_defs.keys()):
                    cell = cell_defs[key]
                    cell_str = build_cell_string(cell, types)
                    f.write(f'"{key}" = (\n')
                    f.write(f'{cell_str})\n\n')
                for line in grid_lines:
                    f.write(line + "\n")

            size = os.path.getsize(output_path)
            size_str = f"{size / 1024:.0f} KB" if size > 1024 else f"{size} B"

            self.send_json({
                "filename": filename,
                "size": size_str,
                "cells": len(cell_defs),
                "rows": len(grid_lines),
            })
        except Exception as e:
            import traceback
            self.send_json({"error": str(e), "trace": traceback.format_exc()})


# ─── Main ────────────────────────────────────────────────────────────────────

import tempfile
tempfile_dir = tempfile.mkdtemp(prefix="dmm_export_")

def main():
    port = 8477
    if len(sys.argv) > 1:
        port = int(sys.argv[1])

    server = HTTPServer(("127.0.0.1", port), Handler)
    url = f"http://127.0.0.1:{port}"
    print(f"DMM Converter UI running at {url}")
    print(f"Output files saved to: {tempfile_dir}")
    print("Press Ctrl+C to stop.")
    threading.Timer(0.5, lambda: webbrowser.open(url)).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down.")
        server.shutdown()

if __name__ == "__main__":
    main()
