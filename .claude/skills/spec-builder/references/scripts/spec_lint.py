#!/usr/bin/env python3
"""
spec_lint.py — validate Spec-Builder spec/delta files against the strict format
rules that otherwise fail silently. Dependency-free.

Checks:
  - every `### Requirement:` has at least one `#### Scenario:`
  - no malformed 3-hash `### Scenario:` (must be 4 hashes)
  - delta files use only known operation headers
    (## ADDED|MODIFIED|REMOVED|RENAMED Requirements)
  - REMOVED requirements include **Reason** and **Migration**
  - RENAMED sections use FROM:/TO: lines

Usage:
  spec_lint.py [--root spec-builder] [PATHS...]
Exits 0 if clean, 1 if any error is found.
"""
from __future__ import annotations
import argparse, glob, os, re, sys

WORKSPACE_DIRNAME = "spec-builder"

SCEN4 = re.compile(r'^#### Scenario:', re.M)
SCEN3 = re.compile(r'^### Scenario:', re.M)
OP = re.compile(r'^## (ADDED|MODIFIED|REMOVED|RENAMED) Requirements\s*$', re.M)
BAD_OP = re.compile(r'^## ([A-Z][A-Z ]+) Requirements\s*$', re.M)


def split_requirements(text: str):
    parts = re.split(r'(^### Requirement: .+$)', text, flags=re.M)
    return [(parts[i], parts[i + 1]) for i in range(1, len(parts), 2)]


def is_delta(path: str) -> bool:
    return "/changes/" in path.replace(os.sep, "/")


def _in_removed_section(text: str, header: str) -> bool:
    before = text[:text.find(header)]
    last_op = None
    for m in OP.finditer(before):
        last_op = m.group(1)
    return last_op == "REMOVED"


def lint_file(path: str) -> list[str]:
    errs: list[str] = []
    s = open(path, encoding="utf-8").read()

    if SCEN3.search(s):
        errs.append("found '### Scenario' (scenarios MUST use 4 hashes '####')")

    for header, body in split_requirements(s):
        name = header.replace("### Requirement: ", "").strip()
        if is_delta(path) and _in_removed_section(s, header):
            if "**Reason**" not in body or "**Migration**" not in body:
                errs.append(f"REMOVED requirement '{name}' must include **Reason** and **Migration**")
            continue
        if not SCEN4.search(body):
            errs.append(f"requirement '{name}' has no '#### Scenario:'")

    if is_delta(path):
        for m in BAD_OP.finditer(s):
            if not OP.match(m.group(0)):
                errs.append(f"unknown delta operation header: '{m.group(0).strip()}'")
        if "## RENAMED Requirements" in s:
            rblock = s.split("## RENAMED Requirements", 1)[1]
            rblock = re.split(r'^## ', rblock, flags=re.M)[0]
            if rblock.strip() and ("FROM:" not in rblock or "TO:" not in rblock):
                errs.append("RENAMED section must use FROM:/TO: lines")
    return errs


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=None)
    ap.add_argument("paths", nargs="*")
    args = ap.parse_args()

    paths = list(args.paths)
    if not paths:
        root = args.root or WORKSPACE_DIRNAME
        paths = glob.glob(os.path.join(root, "specs", "**", "*.md"), recursive=True)
        paths += glob.glob(os.path.join(root, "changes", "**", "specs", "**", "*.md"), recursive=True)
    paths = sorted(set(paths))

    if not paths:
        print("no spec files found", file=sys.stderr)
        return 0

    bad = 0
    for p in paths:
        errs = lint_file(p)
        if errs:
            bad += 1
            for e in errs:
                print(f"FAIL {p}: {e}")
        else:
            print(f"OK   {p}")
    if bad:
        print(f"\n{bad} file(s) with errors")
        return 1
    print(f"\nall {len(paths)} spec file(s) valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())
