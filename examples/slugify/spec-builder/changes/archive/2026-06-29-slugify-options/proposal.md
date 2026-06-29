## Why

Callers need to choose the separator character and want the existing underscore
behavior documented as a guaranteed scenario.

## What Changes

- Add an optional `sep` parameter to `slugify`.
- Clarify that underscores are treated as separators (new scenario).

## Capabilities

### New Capabilities
- (none)

### Modified Capabilities
- `slugify`: add a custom-separator requirement and an underscore scenario.

## Impact

- `src/textutils.py` (`slugify` signature gains `sep`), plus tests.
