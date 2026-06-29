# Slugify Specification

## Purpose
Convert arbitrary text into URL-safe slugs so callers share one consistent
implementation.

## Requirements

### Requirement: Slugify text
The system SHALL convert an input string into a URL-safe slug consisting of
lowercase ASCII words separated by single separators (default `-`).

#### Scenario: Basic words
- **WHEN** `slugify("Hello World")` is called
- **THEN** it returns `"hello-world"`

#### Scenario: Collapse punctuation and whitespace
- **WHEN** `slugify("  Foo --   Bar!! ")` is called
- **THEN** it returns `"foo-bar"`

#### Scenario: Empty input
- **WHEN** `slugify("")` is called
- **THEN** it returns `""`

#### Scenario: Underscores are treated as separators
- **WHEN** `slugify("foo_bar baz")` is called
- **THEN** it returns `"foo-bar-baz"`

### Requirement: Custom separator
The system SHALL allow the caller to choose the separator character via a `sep`
argument, defaulting to `-`.

#### Scenario: Underscore separator
- **WHEN** `slugify("Hello World", sep="_")` is called
- **THEN** it returns `"hello_world"`
