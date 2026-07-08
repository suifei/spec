A load-bearing requirement is a record { intent, acceptance, method }.

    intent  = { def_of_violation, provenance }        # provenance ∈ { AUTO, HUMAN }
    # a HUMAN-set intent is never overwritten by a later AUTO derivation:
    if new.provenance == AUTO and existing.provenance == HUMAN and conflict:
        raise SpecConflict   # human resolves; do NOT self-decide

    method ∈ { PROBED(script, negative_control), OPEN, WEAK }
    #   PROBED = a red-able .sh with a negative control
    #   OPEN   = no red-able check constructible yet  -> requirement stays UNCLOSED
    #   WEAK   = truth is unscriptable -> cited source or independent judge signs off

    def choose_method(acceptance):
        match acceptance.kind:
            case PURE_LOGIC:            return PROBED(unit)
            case SERVICE_OR_API:        return PROBED(integration)
            case USER_VISIBLE:          # drive the RUNNING app at its real entrypoint
                                        # negative control breaks WIRING/reachability, not just logic
                                        return PROBED(e2e_at_real_entrypoint)
            case QUANTITY_THRESHOLD:    # a count is a FLOOR, never a quality gate (builder optimizes it)
                                        return PROBED(anti_degeneracy,
                                                      negative_control = the_cheat_itself)  # e.g. padding -> red
                                        # AND require independent_review below
            case UNSCRIPTABLE_QUALITY:  return WEAK

    # A gate is a PROXY for an intent; the builder optimizes the cheapest reading (Goodhart).
    def author_gate(intent):
        cheat = cheapest_artifact_that_passes_but_misses(intent)
        if cheat is not None:
            harden_so(cheat becomes the negative_control)   # or:
            accept_as_floor + require(independent_review)

    def is_done(requirement):
        if not gates_green(requirement):        return False
        if requirement.is_generative_or_quality:
            return independent_review(requirement).passed   # green probe can pass metric-gamed output
        return True

    def independent_review(req):
        assert reviewer.context is CLEAN and reviewer is not producer   # no self-review
        return reviewer.checks(req.recorded_intent) and reviewer.cites_evidence   # "looks fine" != evidence

    # On any spec change, reconcile the probe SET or /build re-runs a stale set = false green:
    def reconcile_probes(spec_change):
        for req in spec_change:
            if req.is_new:                author_probe(req)
            elif req.acceptance_changed:  replace_stale_probe(req)
            elif req.superseded:          retire_probe(req)
        # coherence invariant:
        for req in locked_and_probed(spec):
            assert exists(req.probe_file)           # locked+PROBED but probe missing -> incomplete gate -> /spec (NOT done)
        assert no_orphan_probes(spec)
