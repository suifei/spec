Every load-bearing requirement carries three fields: an Intent, an Acceptance, and a Method.
The Intent states the purpose the requirement protects — that is, what would count as violating
it — and is tagged with its provenance: `[auto]` if the analyst derived it, or `[human]` if the
human set it. A `[human]`-set Intent must never be silently overwritten by a later `[auto]`
derivation; if they conflict, that is a spec conflict for the human to resolve, not a self-decision.
The Acceptance states the observable behaviour. The Method states how the acceptance is verified,
and is one of: Probed (a red-able probe script with a negative control), OPEN (no red-able check is
constructible yet, so the requirement stays visibly unclosed), or WEAK (the truth is unscriptable,
so a cited source or an independent judge signs off).

The Method's modality is derived from the nature of the acceptance. A pure function or logic
contract is verified by a unit probe. A service or API contract by an integration probe. A
user-visible or interaction behaviour must be verified end-to-end by driving the actually-running
product at its real entrypoint — never a component read in isolation; and that probe's negative
control must break the wiring or reachability (delete the mount, route, or call site so it goes red),
not merely corrupt the internal logic. Un-scriptable quality — "is the prose good, is the ending
earned" — is WEAK.

A gate is a proxy for an intent, and whoever builds against it is an optimizer that will satisfy the
cheapest reading of the check, which can diverge arbitrarily from the intent. So author every gate
adversarially: ask what the cheapest artifact is that turns the gate green while a knowledgeable
person would say the intent is not met. If such a path exists, the check is only a proxy — either
harden the measure so that cheap cheat becomes the probe's negative control, or accept the check as a
floor and require an intent-level review below. A quantity or threshold that the builder optimizes
toward (for example "≥4000 characters per chapter") is exactly this case: the count is a floor, never
a quality gate; pair it with anti-degeneracy guards whose negative control is the padding cheat
itself, and with an independent review for real quality.

For generated or quality work, green probes are necessary but not sufficient, because a probe can
pass metric-gamed output. Such work is done only when, in addition to green gates, an independent,
clean-context, adversarial review signs off — a reviewer that is not the context that produced the
artifact (which has every incentive to pass its own shortcuts), that verifies against the
requirement's recorded Intent field, and that cites the offending passage rather than offering a bare
"looks fine," which is not evidence.

When a later run adds, changes, or supersedes a requirement, the probe set must move with the spec or
the build re-runs a stale set and goes green against a spec it no longer matches. So on every re-run:
a new load-bearing requirement gets its probe authored; a changed acceptance gets its stale probe
replaced; a superseded requirement gets its probe retired. A `[locked]` requirement whose Method is
Probed but whose probe is missing is an incomplete gate — the build must not declare done on green,
but route back to `/spec`. The coherence invariant: every `[locked]` Probed requirement has an
existing probe file, and no probe is orphaned by a superseded requirement.
