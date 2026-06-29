#!/usr/bin/env bash
# Probe G6 — server-authoritative realtime transport is feasible on this platform:
# a WebSocket server can bind, complete the RFC6455 handshake, and round-trip a
# message to a client. Dependency-free (Node built-ins only; no `ws` package).
# Negative control: a client dialing a port with no server MUST fail to connect.
set -euo pipefail
PORT="${1:-8787}"
echo "== probe G6: ws transport round-trip on $PORT =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname) / $(uname -srm)"
echo "node: $(node --version)"; echo "----"
node - "$PORT" <<'JS'
const http = require('http');
const crypto = require('crypto');
const PORT = parseInt(process.argv[2], 10);
const GUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';

// --- minimal RFC6455 server (text frames only), built-ins only ---
function encodeFrame(str) {
  const payload = Buffer.from(str);
  const len = payload.length; // probe payloads are tiny (<126)
  const head = Buffer.from([0x81, len]); // FIN + text opcode, unmasked, short len
  return Buffer.concat([head, payload]);
}
function decodeFrame(buf) {
  const len = buf[1] & 0x7f;
  const masked = (buf[1] & 0x80) !== 0;
  let off = 2;
  const mask = masked ? buf.slice(off, off + 4) : null;
  if (masked) off += 4;
  const data = buf.slice(off, off + len);
  if (masked) for (let i = 0; i < data.length; i++) data[i] ^= mask[i % 4];
  return data.toString();
}

const server = http.createServer();
server.on('upgrade', (req, socket) => {
  const key = req.headers['sec-websocket-key'];
  const accept = crypto.createHash('sha1').update(key + GUID).digest('base64');
  socket.write(
    'HTTP/1.1 101 Switching Protocols\r\n' +
    'Upgrade: websocket\r\nConnection: Upgrade\r\n' +
    'Sec-WebSocket-Accept: ' + accept + '\r\n\r\n'
  );
  socket.on('data', (buf) => {
    const msg = decodeFrame(buf);
    socket.write(encodeFrame('echo:' + msg)); // server-authoritative echo
  });
});

function fail(m) { console.log('FAIL: ' + m); process.exit(1); }

server.listen(PORT, '127.0.0.1', () => {
  // --- positive: native client (Node 22 global WebSocket) round-trips ---
  const ws = new WebSocket('ws://127.0.0.1:' + PORT);
  const t = setTimeout(() => fail('round-trip timed out'), 3000);
  ws.onopen = () => { console.log('handshake OK (101)'); ws.send('ping'); };
  ws.onmessage = (ev) => {
    clearTimeout(t);
    if (ev.data !== 'echo:ping') fail('bad echo: ' + ev.data);
    console.log('round-trip OK: sent "ping" -> got "' + ev.data + '"');
    ws.close();
    // --- negative control: dial an unused port, MUST fail ---
    const deadPort = PORT + 1;
    const bad = new WebSocket('ws://127.0.0.1:' + deadPort);
    const nt = setTimeout(() => fail('NEG CONTROL FAILED: no error on dead port ' + deadPort), 2500);
    bad.onopen = () => { clearTimeout(nt); fail('NEG CONTROL FAILED: connected to dead port ' + deadPort); };
    bad.onerror = () => {
      clearTimeout(nt);
      console.log('neg-control: dial to unused port ' + deadPort + ' refused (as expected)');
      console.log('RESULT: ws transport round-trip works; server-authoritative echo verified');
      server.close();
      process.exit(0); // raw upgraded socket lingers; exit explicitly (self-cleaning)
    };
  };
  ws.onerror = (e) => fail('client error: ' + (e.message || e.type));
});
JS
