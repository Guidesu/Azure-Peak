#!/usr/bin/env python3
"""
opendream_to_dmm_ui.py — Web UI for converting OpenDream JSON to .dmm map files.

Usage:
    python tools/opendream_to_dmm_ui.py [port]

Defaults to port 8477. Opens browser automatically.
"""

import json
import os
import sys
import threading
import webbrowser
import tempfile
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs, unquote
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from opendream_to_dmm import (
    format_value, format_var_overrides, build_cell_string, build_grid
)

loaded_data = None
loaded_path = None
tempfile_dir = tempfile.mkdtemp(prefix="dmm_export_")

# ─── HTML ────────────────────────────────────────────────────────────────────

HTML_PAGE = r"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>OpenDream to DMM</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:system-ui,-apple-system,sans-serif;background:#1a1a2e;color:#eee;display:flex;align-items:center;justify-content:center;min-height:100vh;padding:20px}
.c{max-width:640px;width:100%}
h1{font-size:1.5rem;margin-bottom:4px;background:linear-gradient(135deg,#e94560,#533483);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.sub{color:#999;font-size:.85rem;margin-bottom:20px}
.card{background:#16213e;border:1px solid #333;border-radius:8px;padding:20px;margin-bottom:14px}
.card h2{font-size:.75rem;text-transform:uppercase;letter-spacing:1px;color:#999;margin-bottom:14px}
.dz{border:2px dashed #444;border-radius:8px;padding:40px 20px;text-align:center;cursor:pointer;transition:.2s;margin-bottom:12px}
.dz:hover{border-color:#e94560;background:rgba(233,69,96,.05)}
.dz.over{border-color:#e94560;background:rgba(233,69,96,.12)}
.dz-ic{font-size:2rem;margin-bottom:8px;opacity:.4}
.dz-tx{font-size:.95rem;margin-bottom:2px}
.dz-hn{font-size:.75rem;color:#666}
input[type=text],select{background:#0f3460;border:1px solid #333;border-radius:6px;color:#eee;padding:10px 12px;font-size:.9rem;width:100%;outline:none}
input[type=text]:focus,select:focus{border-color:#e94560}
input[type=number]{background:#0f3460;border:1px solid #333;border-radius:6px;color:#eee;padding:8px 10px;font-size:.85rem;width:100%;outline:none}
input[type=number]:focus{border-color:#e94560}
input[type=checkbox]{width:18px;height:18px;accent-color:#e94560}
.btn{background:linear-gradient(135deg,#e94560,#533483);color:#fff;border:none;border-radius:6px;padding:10px 22px;font-size:.9rem;cursor:pointer;font-weight:600;transition:.15s}
.btn:hover{opacity:.88}.btn:active{transform:scale(.97)}.btn:disabled{opacity:.35;cursor:not-allowed}
.row{display:flex;gap:10px;align-items:center;margin-bottom:10px}
.row label{font-size:.85rem;color:#999;min-width:80px}
.g4{display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:8px}
.cb{display:flex;align-items:center;gap:8px;margin:10px 0}
.cb label{font-size:.85rem;cursor:pointer}
.st{padding:10px 14px;border-radius:6px;font-size:.85rem;margin-top:10px;display:none}
.st.show{display:block}
.st.ok{background:rgba(78,204,163,.12);border:1px solid #4ecca3;color:#4ecca3}
.st.err{background:rgba(233,69,96,.12);border:1px solid #e94560;color:#e94560}
.st.load{background:rgba(83,52,131,.12);border:1px solid #533483;color:#ccc}
.mi{background:#0f3460;border-radius:6px;padding:12px 14px;margin-top:10px;font-size:.8rem;color:#999;display:none}
.mi.show{display:block}
.mi b{color:#eee;font-weight:600}
.dl{display:inline-block;margin-top:10px;color:#e94560;text-decoration:none;font-size:.9rem;font-weight:600}
.dl:hover{text-decoration:underline}
.sp{display:inline-block;width:14px;height:14px;border:2px solid #555;border-top-color:#e94560;border-radius:50%;animation:sp .7s linear infinite;margin-right:6px;vertical-align:middle}
@keyframes sp{to{transform:rotate(360deg)}}
.hn{font-size:.75rem;color:#555;margin-top:4px}
.or{display:flex;align-items:center;text-align:center;margin:12px 0;color:#555;font-size:.75rem}
.or::before,.or::after{content:'';flex:1;height:1px;background:#333}
.or span{padding:0 10px}
.div{height:1px;background:#333;margin:14px 0}
.fw{display:flex;gap:10px}
.fw input{flex:1}
</style>
</head>
<body>
<div class="c">
  <h1>OpenDream &rarr; DMM</h1>
  <p class="sub">Convert compiled JSON to an editable .dmm map file</p>

  <div class="card">
    <h2>1 &middot; Load JSON</h2>
    <div class="dz" id="dz">
      <div class="dz-ic">&#128193;</div>
      <div class="dz-tx" id="dzTx">Drop roguetown.json here</div>
      <div class="dz-hn">or click to browse</div>
    </div>
    <input type="file" id="fi" accept=".json,application/json" style="display:none">
    <div class="or"><span>or paste path</span></div>
    <div class="fw">
      <input type="text" id="jp" placeholder="C:\...\roguetown.json">
      <button class="btn" id="lb">Load</button>
    </div>
    <div class="mi" id="mi"></div>
    <div class="st" id="ls"></div>
  </div>

  <div class="card" id="oc" style="opacity:.35;pointer-events:none">
    <h2>2 &middot; Export</h2>
    <div class="row">
      <label>Z-level</label>
      <select id="zl"><option value="">All</option></select>
    </div>
    <div class="div"></div>
    <div class="row"><label>Region</label><span style="font-size:.8rem;color:#666">Leave blank for full map</span></div>
    <div class="g4">
      <div><input type="number" id="x1" placeholder="Min X" disabled><div class="hn">Min X</div></div>
      <div><input type="number" id="x2" placeholder="Max X" disabled><div class="hn">Max X</div></div>
      <div><input type="number" id="y1" placeholder="Min Y" disabled><div class="hn">Min Y</div></div>
      <div><input type="number" id="y2" placeholder="Max Y" disabled><div class="hn">Max Y</div></div>
    </div>
    <div class="div"></div>
    <div class="cb"><input type="checkbox" id="no"><label for="no">Skip objects (turfs/areas only)</label></div>
    <div class="st" id="es"></div>
    <div style="margin-top:12px">
      <button class="btn" id="eb" disabled>Export to .dmm</button>
      <a class="dl" id="dl" style="display:none">&#8595; Download</a>
    </div>
  </div>
</div>

<script>
const $ = id => document.getElementById(id);
let mb = null;

function st(id, m, t) { const e = $(id); e.className = 'st show ' + t; e.innerHTML = m; }

// ─── File input (hidden, triggered by dropzone click) ───────────────────────
const dz = $('dz');
const fi = $('fi');

dz.addEventListener('click', () => fi.click());

fi.addEventListener('change', () => {
  if (fi.files.length) handleFile(fi.files[0]);
});

// ─── Drag & drop on dropzone ────────────────────────────────────────────────
['dragenter','dragover'].forEach(ev => dz.addEventListener(ev, e => { e.preventDefault(); dz.classList.add('over'); }));
['dragleave','drop'].forEach(ev => dz.addEventListener(ev, e => { e.preventDefault(); dz.classList.remove('over'); }));
dz.addEventListener('drop', e => { if (e.dataTransfer.files.length) handleFile(e.dataTransfer.files[0]); });

// ─── Drag & drop anywhere on page (prevent browser from opening the file) ──
['dragover'].forEach(ev => document.addEventListener(ev, e => e.preventDefault()));
document.addEventListener('drop', e => {
  e.preventDefault();
  if (e.dataTransfer.files.length && !dz.contains(e.target)) handleFile(e.dataTransfer.files[0]);
});

// ─── Handle a file (from input or drag-drop) ────────────────────────────────
async function handleFile(file) {
  $('dzTx').textContent = file.name;
  st('ls', '<span class="sp"></span>Uploading ' + file.name + ' (' + (file.size/1024/1024).toFixed(1) + ' MB)...', 'load');
  try {
    const fd = new FormData();
    fd.append('file', file);
    const r = await fetch('/api/upload', { method: 'POST', body: fd });
    const d = await r.json();
    if (d.error) { st('ls', 'Error: ' + d.error, 'err'); return; }
    loaded(d, file.name);
  } catch(e) { st('ls', 'Error: ' + e.message, 'err'); }
}

// ─── Load by path ───────────────────────────────────────────────────────────
$('lb').addEventListener('click', loadPath);
$('jp').addEventListener('keydown', e => { if (e.key === 'Enter') loadPath(); });

async function loadPath() {
  const p = $('jp').value.trim();
  if (!p) { st('ls', 'Enter a path first.', 'err'); return; }
  st('ls', '<span class="sp"></span>Loading...', 'load');
  $('lb').disabled = true;
  try {
    const r = await fetch('/api/load', { method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify({path:p}) });
    const d = await r.json();
    if (d.error) { st('ls', 'Error: ' + d.error, 'err'); return; }
    $('dzTx').textContent = p.split(/[\\\/]/).pop();
    loaded(d, p);
  } catch(e) { st('ls', 'Error: ' + e.message, 'err'); }
  finally { $('lb').disabled = false; }
}

// ─── Common: data loaded ────────────────────────────────────────────────────
function loaded(d, name) {
  mb = d;
  $('mi').className = 'mi show';
  $('mi').innerHTML = 'Map: <b>' + d.maxx + '</b> x <b>' + d.maxy + '</b> x <b>' + d.maxz + '</b> &middot; <b>' + d.cellCount + '</b> cells &middot; <b>' + d.fileSize + '</b>';
  st('ls', 'Loaded ' + name, 'ok');

  let opts = '<option value="">All</option>';
  for (let z = 1; z <= d.maxz; z++) opts += '<option value="' + z + '">Z-level ' + z + '</option>';
  $('zl').innerHTML = opts;

  const c = $('oc');
  c.style.opacity = '1'; c.style.pointerEvents = 'auto';
  $('eb').disabled = false;
  ['x1','x2','y1','y2'].forEach(id => $(id).disabled = false);
  $('x1').placeholder = '1'; $('x2').placeholder = d.maxx;
  $('y1').placeholder = '1'; $('y2').placeholder = d.maxy;
}

// ─── Export ─────────────────────────────────────────────────────────────────
$('eb').addEventListener('click', async () => {
  if (!mb) return;
  const p = new URLSearchParams();
  const z = $('zl').value; if (z) p.set('z', z);
  if ($('x1').value) p.set('minX', $('x1').value);
  if ($('x2').value) p.set('maxX', $('x2').value);
  if ($('y1').value) p.set('minY', $('y1').value);
  if ($('y2').value) p.set('maxY', $('y2').value);
  if ($('no').checked) p.set('noObjects', '1');

  st('es', '<span class="sp"></span>Converting...', 'load');
  $('eb').disabled = true; $('dl').style.display = 'none';
  try {
    const r = await fetch('/api/export?' + p);
    const d = await r.json();
    if (d.error) { st('es', 'Error: ' + d.error, 'err'); return; }
    st('es', 'Done! <b>' + d.size + '</b> (' + d.cells + ' cells, ' + d.rows + ' rows)', 'ok');
    $('dl').href = '/api/download/' + encodeURIComponent(d.filename);
    $('dl').download = d.filename;
    $('dl').style.display = 'inline-block';
  } catch(e) { st('es', 'Error: ' + e.message, 'err'); }
  finally { $('eb').disabled = false; }
});
</script>
</body>
</html>"""

# ─── Server ──────────────────────────────────────────────────────────────────

class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        pass

    def do_GET(self):
        parsed = urlparse(self.path)

        if parsed.path in ("/", "/index.html"):
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(HTML_PAGE.encode("utf-8"))))
            self.end_headers()
            self.wfile.write(HTML_PAGE.encode("utf-8"))
            return

        if parsed.path.startswith("/api/download/"):
            filename = unquote(parsed.path[len("/api/download/"):])
            output_path = os.path.join(tempfile_dir, filename)
            if not os.path.exists(output_path):
                self._json({"error": "File not found: " + filename})
                return
            with open(output_path, "rb") as f:
                data = f.read()
            self.send_response(200)
            self.send_header("Content-Type", "application/octet-stream")
            self.send_header("Content-Disposition", f'attachment; filename="{filename}"')
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
            return

        if parsed.path == "/api/export":
            self.handle_export(parse_qs(parsed.query))
            return

        self.send_response(404)
        self.send_header("Content-Length", "0")
        self.end_headers()

    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path == "/api/load":
            self.handle_load()
            return
        if parsed.path == "/api/upload":
            self.handle_upload()
            return
        self.send_response(404)
        self.send_header("Content-Length", "0")
        self.end_headers()

    def _json(self, obj):
        data = json.dumps(obj).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def handle_load(self):
        global loaded_data, loaded_path
        cl = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(cl)
        try:
            req = json.loads(body)
            path = req.get("path", "").strip()
            if not path or not os.path.exists(path):
                self._json({"error": f"File not found: {path}"})
                return
            loaded_path = path
            with open(path, "r", encoding="utf-8") as f:
                loaded_data = json.load(f)
            if "Maps" not in loaded_data or not loaded_data["Maps"]:
                self._json({"error": "No maps found in JSON"})
                loaded_data = None
                return
            m = loaded_data["Maps"][0]
            size = os.path.getsize(path)
            sz = f"{size/1024/1024:.1f} MB" if size > 1024*1024 else f"{size/1024:.0f} KB"
            self._json({"maxx": m["MaxX"], "maxy": m["MaxY"], "maxz": m["MaxZ"],
                        "cellCount": len(m["CellDefinitions"]), "fileSize": sz})
        except Exception as e:
            self._json({"error": str(e)})
            loaded_data = None

    def handle_upload(self):
        global loaded_data, loaded_path
        ct = self.headers.get("Content-Type", "")
        if "multipart/form-data" not in ct:
            self._json({"error": "Expected multipart/form-data"})
            return

        cl = int(self.headers.get("Content-Length", 0))

        # Extract boundary
        boundary = None
        for part in ct.split(";"):
            part = part.strip()
            if part.startswith("boundary="):
                boundary = part[len("boundary="):].strip('"')
                break
        if not boundary:
            self._json({"error": "No boundary"})
            return

        try:
            body = self.rfile.read(cl)
            bb = ("--" + boundary).encode()

            # Find filename= in the body
            fn_idx = body.find(b'filename=')
            if fn_idx == -1:
                self._json({"error": "No file in upload"})
                return

            # Find the boundary line before the filename
            b_start = body.rfind(bb, 0, fn_idx)
            if b_start == -1:
                self._json({"error": "Boundary not found"})
                return

            # Find headers end
            hs = b_start + len(bb)
            if body[hs:hs+2] == b"\r\n":
                hs += 2
            he = body.find(b"\r\n\r\n", hs)
            if he == -1:
                self._json({"error": "Headers not found"})
                return

            # Parse filename
            hdr = body[hs:he].decode("utf-8", errors="replace")
            filename = "uploaded.json"
            for line in hdr.split("\r\n"):
                if "filename=" in line:
                    i = line.find('filename="')
                    if i != -1:
                        i += len('filename="')
                        j = line.find('"', i)
                        if j != -1:
                            filename = line[i:j]

            # File data between headers and next boundary
            ds = he + 4
            de = body.find(b"\r\n" + bb, ds)
            if de == -1:
                de = len(body)
            file_data = body[ds:de]

            loaded_data = json.loads(file_data.decode("utf-8"))
            loaded_path = os.path.basename(filename)
            if "Maps" not in loaded_data or not loaded_data["Maps"]:
                self._json({"error": "No maps in JSON"})
                loaded_data = None
                return
            m = loaded_data["Maps"][0]
            size = len(file_data)
            sz = f"{size/1024/1024:.1f} MB" if size > 1024*1024 else f"{size/1024:.0f} KB"
            self._json({"maxx": m["MaxX"], "maxy": m["MaxY"], "maxz": m["MaxZ"],
                        "cellCount": len(m["CellDefinitions"]), "fileSize": sz})
        except Exception as e:
            self._json({"error": str(e)})
            loaded_data = None

    def handle_export(self, params):
        global loaded_data, loaded_path
        if loaded_data is None:
            self._json({"error": "No JSON loaded"})
            return
        try:
            m = loaded_data["Maps"][0]
            types = loaded_data["Types"]
            cell_defs = m["CellDefinitions"]
            blocks = m["Blocks"]
            maxx, maxy, maxz = m["MaxX"], m["MaxY"], m["MaxZ"]

            z = int(params["z"][0]) if params.get("z", [None])[0] else None
            min_x = int(params["minX"][0]) if params.get("minX", [None])[0] else None
            max_x = int(params["maxX"][0]) if params.get("maxX", [None])[0] else None
            min_y = int(params["minY"][0]) if params.get("minY", [None])[0] else None
            max_y = int(params["maxY"][0]) if params.get("maxY", [None])[0] else None
            no_objects = params.get("noObjects", ["0"])[0] == "1"

            if no_objects:
                cd = {}
                for k, v in m["CellDefinitions"].items():
                    c = dict(v)
                    c.pop("Objects", None)
                    cd[k] = c
                cell_defs = cd

            grid_lines = build_grid(blocks, cell_defs, maxx, maxy, maxz,
                                    z_filter=z, min_x=min_x, max_x=max_x,
                                    min_y=min_y, max_y=max_y)

            stem = Path(loaded_path).stem if loaded_path else "map"
            suffix = f"_z{z}" if z else ""
            suffix += "_crop" if any([min_x, max_x, min_y, max_y]) else ""
            suffix += "_noobj" if no_objects else ""
            filename = f"{stem}{suffix}.dmm"
            out = os.path.join(tempfile_dir, filename)

            with open(out, "w", encoding="utf-8", newline="\n") as f:
                f.write("//MAP CONVERTED BY opendream_to_dmm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE\n")
                for key in sorted(cell_defs.keys()):
                    cell = cell_defs[key]
                    cs = build_cell_string(cell, types)
                    f.write(f'"{key}" = (\n{cs})\n')
                for line in grid_lines:
                    f.write(line + "\n")

            size = os.path.getsize(out)
            sz = f"{size/1024:.0f} KB" if size > 1024 else f"{size} B"
            self._json({"filename": filename, "size": sz,
                        "cells": len(cell_defs), "rows": len(grid_lines)})
        except Exception as e:
            self._json({"error": str(e)})


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8477
    server = HTTPServer(("127.0.0.1", port), Handler)
    url = f"http://127.0.0.1:{port}"
    print(f"DMM Converter UI running at {url}")
    print(f"Output dir: {tempfile_dir}")
    print("Ctrl+C to stop.")
    threading.Timer(0.5, lambda: webbrowser.open(url)).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down.")
        server.shutdown()

if __name__ == "__main__":
    main()
