#!/usr/bin/env bash
# Probe G1 — Node.js toolchain present (needed by chosen build tool Vite)
set -euo pipefail
echo "== probe G1: node toolchain =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname) / $(uname -srm)"; echo "----"
command -v node >/dev/null || { echo "node NOT found on PATH"; exit 1; }
echo "node: $(node --version)"; echo "npm: $(npm --version 2>/dev/null || echo n/a)"
echo "RESULT: node toolchain present"
