## Why

The library needs a canonical way to turn arbitrary text into URL-safe slugs so
callers stop hand-rolling inconsistent implementations.

## What Changes

- Add a `slugify` capability with a `slugify(text)` function.
- Lowercases, trims, collapses whitespace/punctuation into single hyphens.

## Capabilities

### New Capabilities
- `slugify`: converting arbitrary text into URL-safe slugs.

### Modified Capabilities
- (none)

## Impact

- New code in `src/textutils.py`; new tests in `tests/`.
