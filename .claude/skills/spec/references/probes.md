# Writing probes (摸排探真)

A **probe** is a small, standalone script that proves a gate is real by exercising
it against the actual environment. Probes are the reason `/spec` can say "verified"
instead of "the user told me so." They live in `.spec/probes/<gate-id>_<slug>.sh`
and their output is captured to `.spec/evidence/<gate-id>-<timestamp>.log`.

## Rules every probe MUST follow

1. **Strict mode + honest exit code.** Start with `set -euo pipefail`. **Exit 0 =
   pass, any non-zero = fail.** Never `|| true` away a real failure.
2. **Print raw evidence, not verdicts.** Emit the *actual* facts: resolved absolute
   path, version string, `SELECT 1` result, `df -h` line, `docker info` server
   version. A human/CI must be able to audit the evidence, not trust a "PASS".
3. **Non-destructive, isolated, idempotent, self-cleaning.** Prefer read-only.
   Writes go to a temp/clearly-scoped location and are removed via `trap … EXIT`.
   Never delete user data; never mutate production.
4. **Negative control where feasible.** Demonstrate the probe *can* fail (e.g. also
   try an impossible path and confirm it errors), so a green result is meaningful.
5. **No secrets in the file or the evidence.** Read credentials from environment
   variables; never hard-code them; redact them in output.
6. **Record the environment.** Print `date -u`, `hostname`, `uname -a` first, so the
   evidence states *where/when* it was proven.
7. **Scope honesty.** A probe proves truth on the machine it ran. If the real target
   is production and unreachable here, probe a safe proxy or defer the gate — don't
   claim devbox ⇒ prod.

## Safety gate (ask before running)

If a probe would be destructive, irreversible, touch production, delete data, or
write to an external system, **confirm with the user (AskUserQuestion) before
running it.** Default probes must be safe to run unattended.

## Standard preamble (copy into every probe)

```bash
#!/usr/bin/env bash
# Probe: <gate-id> — <what truth this proves>
set -euo pipefail
echo "== probe <gate-id> =="
date -u +"when: %Y-%m-%dT%H:%M:%SZ"
echo "where: $(hostname) / $(uname -srm)"
echo "----"
```

## Example library

### Storage is writable at a path (e.g. SQLite location)
```bash
#!/usr/bin/env bash
# Probe: G1 — SQLite storage path is real and writable
set -euo pipefail
DB_DIR="${1:-./data}"
echo "== probe G1: storage =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname)"
mkdir -p "$DB_DIR"
ABS=$(cd "$DB_DIR" && pwd); echo "resolved path: $ABS"
df -h "$ABS" | awk 'NR==2{print "free space: "$4}'
TMP="$ABS/.probe_$$.db"
trap 'rm -f "$TMP"' EXIT
if command -v sqlite3 >/dev/null 2>&1; then
  sqlite3 "$TMP" "create table t(x); insert into t values(1); select 'rows='||count(*) from t;"
else
  # fall back to a raw write/read if sqlite3 isn't installed
  echo "probe-write" > "$TMP"; test "$(cat "$TMP")" = "probe-write" && echo "rows=1 (raw write/read OK)"
fi
# negative control: an impossible path must fail
if ( : > "/proc/definitely/not/writable" ) 2>/dev/null; then echo "NEG CONTROL FAILED"; exit 1; fi
echo "RESULT: storage writable"
```

### Docker is really present (and a specific service/image)
```bash
#!/usr/bin/env bash
# Probe: G2 — Docker daemon reachable and Postgres image/service present
set -euo pipefail
echo "== probe G2: docker =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname)"
command -v docker >/dev/null || { echo "docker CLI not found"; exit 1; }
docker info --format 'server version: {{.ServerVersion}}'   # exits non-zero if daemon down
echo "postgres images:"; docker images --format '{{.Repository}}:{{.Tag}}' | grep -i postgres || { echo "no postgres image"; exit 1; }
echo "running postgres containers:"; docker ps --format '{{.Names}} {{.Image}} {{.Status}}' | grep -i postgres || echo "(none running)"
echo "RESULT: docker present"
```

### Remote database reachable (credentials from env, never hard-coded)
```bash
#!/usr/bin/env bash
# Probe: G3 — Postgres reachable; SELECT 1 succeeds. Requires PGHOST/PGUSER/PGPASSWORD/PGDATABASE in env.
set -euo pipefail
echo "== probe G3: postgres =="; date -u +"when: %Y-%m-%dT%H:%M:%SZ"; echo "where: $(hostname)"
: "${PGHOST:?set PGHOST}"; : "${PGUSER:?set PGUSER}"; : "${PGDATABASE:?set PGDATABASE}"
echo "target: ${PGUSER}@${PGHOST}/${PGDATABASE}"   # note: no password echoed
command -v psql >/dev/null || { echo "psql not found"; exit 1; }
OUT=$(psql -At -c "select 'select1='||1;")          # PGPASSWORD read from env by libpq
echo "$OUT"; [ "$OUT" = "select1=1" ] || exit 1
echo "RESULT: postgres reachable"
```

### A TCP port is free / a service is listening
```bash
#!/usr/bin/env bash
set -euo pipefail
PORT="${1:?port}"
if command -v ss >/dev/null; then ss -ltn "( sport = :$PORT )" | grep -q ":$PORT" && { echo "port $PORT in use"; exit 1; }; fi
echo "RESULT: port $PORT appears free"
```

### A required binary exists at a required version
```bash
#!/usr/bin/env bash
set -euo pipefail
BIN="${1:?bin}"; MIN="${2:-}"
command -v "$BIN" >/dev/null || { echo "$BIN not found"; exit 1; }
V=$("$BIN" --version 2>&1 | head -1); echo "version: $V"
[ -n "$MIN" ] && echo "required >= $MIN (verify in evidence)"
echo "RESULT: $BIN present"
```

### An HTTP dependency is healthy
```bash
#!/usr/bin/env bash
set -euo pipefail
URL="${1:?url}"
CODE=$(curl -fsS -o /dev/null -w '%{http_code}' --max-time 10 "$URL") || { echo "unreachable"; exit 1; }
echo "http: $CODE for $URL"; [ "$CODE" = 200 ] || exit 1
echo "RESULT: dependency healthy"
```

## Running and recording

```bash
mkdir -p .spec/probes .spec/evidence
# author the probe, then run it and capture evidence + exit code:
bash .spec/probes/G1_storage.sh ./data 2>&1 | tee ".spec/evidence/G1-$(date -u +%Y%m%dT%H%M%SZ).log"
echo "exit: ${PIPESTATUS[0]}"
```

Then copy the key lines (resolved path, version, query result) into the gate's
**Evidence** block in `SPEC.md`, set the status to ✅/❌, and note when/where it ran.
Green ⇒ the gate is verified. Red ⇒ do not accept the answer; change the plan, fix
the environment, or defer the gate to a later phase.
