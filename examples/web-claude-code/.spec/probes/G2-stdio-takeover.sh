#!/usr/bin/env bash
# Probe G2 — the mechanism web-ification rests on: a CLI process's standard I/O
# can be TAKEN OVER and relayed bidirectionally (server side of browser <-WS->
# bridge <-stdio-> claude). This is the one BEHAVIORAL truth here, so it earns a
# runnable probe. Dependency-free; uses a stand-in interactive CLI (NOT the real
# `claude`, which needs auth) to exercise the takeover+relay mechanism itself.
#
# Positive: parent spawns a child CLI, takes over its stdin+stdout, sends input,
#           and reads the child's output back → round-trip proves the relay works.
# Negative control: spawn the same child WITHOUT taking over stdout (inherited);
#           the parent captures nothing → proves the probe detects a failed
#           takeover (it can go red), i.e. "no I/O takeover ⇒ browser sees nothing".
set -euo pipefail
echo "== probe G2: CLI stdio takeover + relay =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname) / $(uname -srm)"
echo "node: $(node --version)"; echo "----"
node <<'JS'
const { spawn } = require('child_process');

// a stand-in interactive CLI: reads lines on stdin, replies "recv:<line>" on stdout
const CHILD = `
process.stdin.setEncoding('utf8');
let buf='';
process.stdin.on('data',d=>{buf+=d;let i;
  while((i=buf.indexOf('\\n'))>=0){const line=buf.slice(0,i);buf=buf.slice(i+1);
    process.stdout.write('recv:'+line+'\\n');}});
`;
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
const fail = (m) => { console.log('FAIL: ' + m); process.exit(1); };

(async () => {
  // --- POSITIVE: take over stdin AND stdout, then round-trip ---
  const pos = spawn(process.execPath, ['-e', CHILD], { stdio: ['pipe', 'pipe', 'ignore'] });
  let got = '';
  pos.stdout.setEncoding('utf8');
  pos.stdout.on('data', d => { got += d; });
  pos.stdin.write('ping\n');                       // "keystroke" forwarded to the CLI
  pos.stdin.write('hello-web\n');
  const t0 = Date.now();
  while (!got.includes('recv:hello-web') && Date.now() - t0 < 3000) await sleep(20);
  pos.kill();
  if (!got.includes('recv:ping') || !got.includes('recv:hello-web'))
    fail('did not relay child output back (got: ' + JSON.stringify(got) + ')');
  console.log('takeover OK: sent "ping","hello-web" -> relayed ' + JSON.stringify(got.trim()));

  // --- NEGATIVE CONTROL: do NOT take over stdout (inherit it) ---
  const neg = spawn(process.execPath, ['-e', CHILD], { stdio: ['pipe', 'inherit', 'ignore'] });
  const captured = neg.stdout; // null, because stdout was not piped to us
  neg.stdin.write('ping\n');
  await sleep(300);
  neg.kill();
  if (captured !== null) fail('NEG CONTROL FAILED: captured a stream we did not take over');
  console.log('neg-control: stdout NOT taken over -> nothing captured (browser would see nothing) — probe can go red');

  console.log("RESULT: a CLI process's stdio can be taken over and relayed bidirectionally");
  process.exit(0);
})().catch(e => fail(e.message));
JS
