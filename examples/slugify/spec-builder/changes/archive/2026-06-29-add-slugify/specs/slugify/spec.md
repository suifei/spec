## ADDED Requirements

### Requirement: Slugify text
The system SHALL convert an input string into a URL-safe slug consisting of
lowercase ASCII words separated by single hyphens.

#### Scenario: Basic words
- **WHEN** `slugify("Hello World")` is called
- **THEN** it returns `"hello-world"`

#### Scenario: Collapse punctuation and whitespace
- **WHEN** `slugify("  Foo --   Bar!! ")` is called
- **THEN** it returns `"foo-bar"`

#### Scenario: Empty input
- **WHEN** `slugify("")` is called
- **THEN** it returns `""`
