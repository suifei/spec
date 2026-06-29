#!/usr/bin/env bash
# Probe G0 — Godot engine present? (human assumed a native desktop build)
set -euo pipefail
echo "== probe G0: godot engine =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname)"; echo "----"
command -v godot >/dev/null || { echo "godot NOT found on PATH"; exit 1; }
echo "godot: $(godot --version)"; echo "RESULT: godot present"
