#!/usr/bin/env bash
# Probe G3 — a server-side execution session survives a client disconnect.
# This is the one truth here that is BEHAVIORAL (not a researched platform fact),
# so it earns a runnable probe. Load-bearing: if a session died with its socket,
# long agent tasks couldn't run from a flaky browser — a different architecture.
# Dependency-free (Node built-ins only).
#
# Positive: a detached worker keeps advancing work while the "client" is gone;
#           after reconnect the counter has moved → session persisted.
# Negative control: a connection-bound worker is killed on disconnect and must
#           show NO progress after — proving the probe can go red.
set -euo pipefail
echo "== probe G3: session survives disconnect =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname) / $(uname -srm)"
echo "node: $(node --version)"; echo "----"
node <<'JS'
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawn } = require('child_process');

const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'g3-'));
const persF = path.join(dir, 'persistent.count');
const ephF  = path.join(dir, 'ephemeral.count');
fs.writeFileSync(persF, '0'); fs.writeFileSync(ephF, '0');

// a "session worker": increments a counter file every 30ms (= ongoing work)
const worker = (f) =>
  `const fs=require('fs');let n=0;setInterval(()=>{n++;fs.writeFileSync(${JSON.stringify(f)},String(n))},30);`;
const read = (f) => Number(fs.readFileSync(f, 'utf8')) || 0;
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const fail = (m) => { console.log('FAIL: ' + m); cleanup(); process.exit(1); };

// PERSISTENT session: detached, outlives the "connection"
const pers = spawn(process.execPath, ['-e', worker(persF)], { detached: true, stdio: 'ignore' });
pers.unref();
// EPHEMERAL neg-control: connection-bound, dies when the "connection" closes
const eph = spawn(process.execPath, ['-e', worker(ephF)], { stdio: 'ignore' });

function cleanup() {
  try { process.kill(pers.pid); } catch (_) {}
  try { process.kill(eph.pid); } catch (_) {}
  try { fs.rmSync(dir, { recursive: true, force: true }); } catch (_) {}
}

(async () => {
  await sleep(200);                       // both sessions warm up
  const p1 = read(persF), e1 = read(ephF);
  console.log(`client connected: persistent=${p1}, ephemeral=${e1}`);

  // --- client DISCONNECTS ---
  try { process.kill(eph.pid); } catch (_) {}   // connection-bound worker dies with the socket
  console.log('client disconnected (ephemeral session torn down with the connection)');
  await sleep(400);                        // time passes while nobody is connected

  // --- client RECONNECTS ---
  const p2 = read(persF), e2 = read(ephF);
  console.log(`client reconnected: persistent=${p2}, ephemeral=${e2}`);

  if (!(p2 > p1)) fail(`persistent session did NOT advance across disconnect (${p1}->${p2})`);
  console.log(`OK: persistent session kept working across the disconnect (${p1} -> ${p2})`);

  if (e2 !== e1) fail(`NEG CONTROL FAILED: ephemeral session advanced after teardown (${e1}->${e2})`);
  console.log(`neg-control: ephemeral session showed no progress after teardown (${e1} -> ${e2}) — probe can go red`);

  console.log('RESULT: server-side session survives client disconnect/reconnect');
  cleanup();
  process.exit(0);
})().catch((e) => fail(e.message));
JS
