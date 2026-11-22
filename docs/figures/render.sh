#!/bin/bash
# Render every docs/figures/*.mmd (and docs/*.mmd) to PNG (cropped) and vector PDF.
# Uses Microsoft Edge from Windows in headless mode (no installation needed in WSL) and
# mermaid 10.9.1 from jsDelivr. The PDF page size is set to the size of the diagram.
# Usage: docs/figures/render.sh [file.mmd ...]
set -euo pipefail
cd "$(dirname "$0")/../.."
EDGE="/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
TMP=/mnt/c/Users/Kacper/AppData/Local/Temp/mmd_render
mkdir -p "$TMP"
FILES=("$@")
[ ${#FILES[@]} -gt 0 ] || FILES=(docs/figures/*.mmd docs/*.mmd)

for SRC in "${FILES[@]}"; do
  NAME=$(basename "$SRC" .mmd)
  OUTDIR=$(dirname "$SRC")
  python3 -I - "$SRC" "$TMP/$NAME.html" <<'EOF'
import json, sys
src = open(sys.argv[1]).read()
page = """<!doctype html><html><head><meta charset="utf-8">
<style>html,body{margin:0;background:#fff} #out{display:inline-block;padding:12px} #err{color:#c00;white-space:pre}</style>
<script src="https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js"></script></head>
<body><div id="out"></div><div id="err"></div><script>
mermaid.initialize({startOnLoad:false, theme:"neutral",
  themeVariables:{fontSize:"16px", fontFamily:"DejaVu Sans, Arial, sans-serif"},
  flowchart:{htmlLabels:true, curve:"basis", useMaxWidth:false},
  sequence:{mirrorActors:false, useMaxWidth:false, wrap:false}});
mermaid.render("g", SRC).then(r => {
  const out = document.getElementById("out"); out.innerHTML = r.svg;
  const b = out.getBoundingClientRect();
  const st = document.createElement("style");
  st.textContent = "@page{size:" + Math.ceil(b.width) + "px " + Math.ceil(b.height) + "px;margin:0}";
  document.head.appendChild(st);
}).catch(e => { document.getElementById("err").textContent = "MERMAID ERROR: " + e; });
</script></body></html>""".replace("SRC", json.dumps(src))
open(sys.argv[2], "w").write(page)
EOF
  URL="file:///$(wslpath -w "$TMP/$NAME.html")"
  timeout 90 "$EDGE" --headless=new --disable-gpu --hide-scrollbars --window-size=2200,2600 \
    --force-device-scale-factor=2 --virtual-time-budget=15000 --screenshot="$(wslpath -w "$TMP")\\$NAME.png" "$URL" >/dev/null 2>&1
  timeout 90 "$EDGE" --headless=new --disable-gpu --no-pdf-header-footer --window-size=2200,2600 \
    --virtual-time-budget=15000 --print-to-pdf="$(wslpath -w "$TMP")\\$NAME.pdf" "$URL" >/dev/null 2>&1
  cp "$TMP/$NAME.png" "$OUTDIR/$NAME.png"
  cp "$TMP/$NAME.pdf" "$OUTDIR/$NAME.pdf"
  # crop the PNG to the drawing (white page background around it)
  .venv/bin/python -I - "$OUTDIR/$NAME.png" <<'EOF'
import sys
import matplotlib.image as mpimg
import numpy as np
f = sys.argv[1]
im = mpimg.imread(f)
ys, xs = np.where((im[..., :3] < 0.97).any(axis=2))
mpimg.imsave(f, im[max(ys.min() - 10, 0):ys.max() + 10, max(xs.min() - 10, 0):xs.max() + 10])
EOF
  echo "$SRC -> $OUTDIR/$NAME.png, $OUTDIR/$NAME.pdf"
done
