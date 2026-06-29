#!/usr/bin/env bash
# Probe G2 — Vite dev port (5173) is actually bindable (+ negative control)
set -euo pipefail
PORT="${1:-5173}"
echo "== probe G2: port $PORT =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname)"; echo "----"
python3 - "$PORT" <<'PY'
import socket,sys
p=int(sys.argv[1]); s=socket.socket(); s.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)
s.bind(("0.0.0.0",p)); s.listen(1); print(f"bind+listen OK on 0.0.0.0:{p}")
n=socket.socket()
try: n.bind(("0.0.0.0",p)); print("NEG CONTROL FAILED: rebound in-use port"); sys.exit(1)
except OSError as e: print(f"neg-control: second bind refused (errno {e.errno})")
finally: n.close(); s.close()
PY
echo "RESULT: port $PORT bindable"
