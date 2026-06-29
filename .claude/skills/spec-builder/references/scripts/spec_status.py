#!/usr/bin/env python3
"""
spec_status.py — deterministic, dependency-free status for a Spec-Builder
workspace. Derives everything from the filesystem (no daemon, no CLI state).

Artifact graph (spec-driven):
    proposal : requires []
    specs    : requires [proposal]
    design   : requires [proposal]      (OPTIONAL — never blocks)
    tasks    : requires [specs]         (design is soft/optional)
    apply    : requires [tasks]

Status values per artifact:
    done     - the artifact's file(s) exist and are non-empty
    ready    - all hard dependencies are done, but it doesn't exist yet
    blocked  - a hard dependency is still missing
    optional - design only: not present, but does not block (treated satisfied)

Usage:
    spec_status.py [--root spec-builder] [--change NAME] [--json]
    spec_status.py --list            # list active changes (one per line)
    spec_status.py --capabilities    # list capabilities under specs/

Exit code is 0 on success, 2 if the workspace root cannot be found.
"""
from __future__ import annotations
import argparse, json, os, re, sys

WORKSPACE_DIRNAME = "spec-builder"

CHECK_PENDING = re.compile(r"^\s*[-*]\s*\[ \]", re.M)
CHECK_DONE = re.compile(r"^\s*[-*]\s*\[[xX]\]", re.M)


def find_root(start: str) -> str | None:
    cur = os.path.abspath(start)
    while True:
        cand = os.path.join(cur, WORKSPACE_DIRNAME)
        if os.path.isdir(cand):
            return cand
        parent = os.path.dirname(cur)
        if parent == cur:
            return None
        cur = parent


def nonempty_file(path: str) -> bool:
    return os.path.isfile(path) and os.path.getsize(path) > 0


def list_spec_files(specs_dir: str) -> list[str]:
    out = []
    if os.path.isdir(specs_dir):
        for dirpath, _dirs, files in os.walk(specs_dir):
            for f in files:
                if f.endswith(".md"):
                    out.append(os.path.join(dirpath, f))
    return sorted(out)


def delta_capabilities(specs_dir: str) -> list[str]:
    """Capability folder names that contain a spec.md delta."""
    caps = []
    if os.path.isdir(specs_dir):
        for name in sorted(os.listdir(specs_dir)):
            if nonempty_file(os.path.join(specs_dir, name, "spec.md")):
                caps.append(name)
    return caps


def task_counts(tasks_path: str) -> dict:
    if not nonempty_file(tasks_path):
        return {"exists": False, "total": 0, "complete": 0, "pending": 0}
    text = open(tasks_path, encoding="utf-8").read()
    done = len(CHECK_DONE.findall(text))
    pending = len(CHECK_PENDING.findall(text))
    return {"exists": True, "total": done + pending, "complete": done, "pending": pending}


def change_status(change_dir: str) -> dict:
    name = os.path.basename(change_dir.rstrip("/"))
    proposal = os.path.join(change_dir, "proposal.md")
    design = os.path.join(change_dir, "design.md")
    tasks = os.path.join(change_dir, "tasks.md")
    specs_dir = os.path.join(change_dir, "specs")

    proposal_done = nonempty_file(proposal)
    spec_files = list_spec_files(specs_dir)
    specs_done = len(spec_files) > 0
    design_done = nonempty_file(design)
    tcounts = task_counts(tasks)
    tasks_done = tcounts["exists"] and tcounts["total"] > 0

    def st(done, hard_deps_done):
        if done:
            return "done"
        return "ready" if hard_deps_done else "blocked"

    artifacts = {
        "proposal": {"status": st(proposal_done, True), "path": rel(proposal)},
        "specs": {
            "status": st(specs_done, proposal_done),
            "files": [rel(p) for p in spec_files],
        },
        "design": {
            # design never blocks tasks; report done or optional
            "status": "done" if design_done else "optional",
            "path": rel(design),
        },
        "tasks": {
            # hard dependency is specs only (design is soft)
            "status": st(tasks_done, specs_done),
            "path": rel(tasks),
            "progress": tcounts,
        },
    }

    apply_ready = tasks_done
    is_complete = (
        proposal_done and specs_done and tasks_done and tcounts["pending"] == 0
    )

    return {
        "name": name,
        "path": rel(change_dir),
        "schema": "spec-driven",
        "artifacts": artifacts,
        "applyReady": apply_ready,
        "isComplete": is_complete,
        "tasks": tcounts,
        "deltaCapabilities": delta_capabilities(specs_dir),
    }


ROOT = ""  # set in main; used by rel()


def rel(p: str) -> str:
    try:
        return os.path.relpath(p, os.path.dirname(ROOT))
    except ValueError:
        return p


def active_changes(root: str) -> list[str]:
    changes_dir = os.path.join(root, "changes")
    out = []
    if os.path.isdir(changes_dir):
        for name in os.listdir(changes_dir):
            full = os.path.join(changes_dir, name)
            if name == "archive" or not os.path.isdir(full):
                continue
            out.append(full)
    out.sort(key=lambda p: os.path.getmtime(p), reverse=True)  # most recent first
    return out


def capabilities(root: str) -> list[str]:
    return delta_capabilities(os.path.join(root, "specs"))


def human(report: dict) -> str:
    lines = []
    lines.append(f"Spec-Builder root: {report['workspaceRoot']}")
    caps = report["capabilities"]
    lines.append(f"Capabilities ({len(caps)}): " + (", ".join(caps) or "—"))
    lines.append("")
    if not report["changes"]:
        lines.append("No active changes.")
        return "\n".join(lines)
    for c in report["changes"]:
        flag = "complete" if c["isComplete"] else ("apply-ready" if c["applyReady"] else "in progress")
        lines.append(f"● {c['name']}  [{flag}]")
        for aid in ("proposal", "specs", "design", "tasks"):
            a = c["artifacts"][aid]
            extra = ""
            if aid == "tasks" and a["progress"]["exists"]:
                p = a["progress"]
                extra = f"  ({p['complete']}/{p['total']} tasks)"
            if aid == "specs" and a["files"]:
                extra = f"  ({len(a['files'])} spec file(s))"
            lines.append(f"    {aid:9s} {a['status']}{extra}")
        if c["deltaCapabilities"]:
            lines.append(f"    delta caps: {', '.join(c['deltaCapabilities'])}")
        lines.append("")
    return "\n".join(lines).rstrip()


def main() -> int:
    global ROOT
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=None, help=f"path to the {WORKSPACE_DIRNAME}/ directory")
    ap.add_argument("--change", default=None, help="report a single change")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--list", action="store_true", help="list active change names")
    ap.add_argument("--capabilities", action="store_true", help="list capabilities")
    args = ap.parse_args()

    root = args.root or find_root(os.getcwd())
    if not root or not os.path.isdir(root):
        print(f"error: could not find a {WORKSPACE_DIRNAME}/ directory", file=sys.stderr)
        return 2
    ROOT = os.path.abspath(root)

    if args.list:
        for full in active_changes(ROOT):
            print(os.path.basename(full))
        return 0
    if args.capabilities:
        for c in capabilities(ROOT):
            print(c)
        return 0

    if args.change:
        change_dir = os.path.join(ROOT, "changes", args.change)
        if not os.path.isdir(change_dir):
            print(f"error: no such change: {args.change}", file=sys.stderr)
            return 2
        rep = change_status(change_dir)
        print(json.dumps(rep, indent=2) if args.json else human(
            {"workspaceRoot": rel(ROOT), "capabilities": capabilities(ROOT), "changes": [rep]}
        ))
        return 0

    report = {
        "workspaceRoot": rel(ROOT),
        "capabilities": capabilities(ROOT),
        "changes": [change_status(c) for c in active_changes(ROOT)],
    }
    print(json.dumps(report, indent=2) if args.json else human(report))
    return 0


if __name__ == "__main__":
    sys.exit(main())
