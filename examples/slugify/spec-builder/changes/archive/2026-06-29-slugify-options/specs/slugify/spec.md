<!--
NOTE: This delta deliberately uses a PARTIAL "MODIFIED" block — it lists only the
NEW scenario plus a reworded description, without repeating the existing scenarios.
The archive merge preserves the untouched scenarios and folds in this one. See the
merged result in spec-builder/specs/slugify/spec.md.
-->

## MODIFIED Requirements

### Requirement: Slugify text
The system SHALL convert an input string into a URL-safe slug consisting of
lowercase ASCII words separated by single separators (default `-`).

#### Scenario: Underscores are treated as separators
- **WHEN** `slugify("foo_bar baz")` is called
- **THEN** it returns `"foo-bar-baz"`

## ADDED Requirements

### Requirement: Custom separator
The system SHALL allow the caller to choose the separator character via a `sep`
argument, defaulting to `-`.

#### Scenario: Underscore separator
- **WHEN** `slugify("Hello World", sep="_")` is called
- **THEN** it returns `"hello_world"`
