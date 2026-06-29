<!--
Delta spec for a single capability, inside a change:
  spec-builder/changes/<change-name>/specs/<capability>/spec.md

Include ONLY the operation sections you need. Use `##` for operation headers,
`###` for requirements, and EXACTLY `####` for scenarios.
Every requirement needs at least one scenario. Use SHALL/MUST.
-->

## ADDED Requirements

### Requirement: <!-- requirement name -->
The system SHALL <!-- normative statement -->.

#### Scenario: <!-- scenario name -->
- **WHEN** <!-- condition -->
- **THEN** <!-- expected outcome -->

## MODIFIED Requirements

<!-- Paste the updated requirement block (copied from the main spec and edited). -->

### Requirement: <!-- existing requirement name (must match main spec) -->
The system SHALL <!-- full updated statement -->.

#### Scenario: <!-- scenario name -->
- **WHEN** <!-- condition -->
- **THEN** <!-- expected outcome -->

## REMOVED Requirements

### Requirement: <!-- requirement name -->
**Reason**: <!-- why it is being removed -->
**Migration**: <!-- what to do instead -->

## RENAMED Requirements

- FROM: `### Requirement: <!-- old name -->`
- TO: `### Requirement: <!-- new name -->`
