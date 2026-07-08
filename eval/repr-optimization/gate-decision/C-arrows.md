req(load-bearing) = { Intent, Acceptance, Method }

Intent  := "what counts as a VIOLATION" · provenance ∈ {[auto] derived, [human] set}
           [human] --NOT-overwritable-by--> [auto]   (conflict ⇒ human resolves, not self-decide)
Method  := Probed(.sh + neg-control) | OPEN(no red-able check ⇒ req stays unclosed) | WEAK(cited/judge)

acceptance.kind ─▶ Method:
  pure logic/function       ─▶ Probed(unit)
  service/API               ─▶ Probed(integration)
  user-visible/interaction  ─▶ Probed(E2E, drive RUNNING app @ real entrypoint)   # NOT isolated component
                                 neg-control breaks WIRING/reachability, not just logic
  quantity/threshold        ─▶ FLOOR (not a quality gate): Probed(anti-degeneracy; neg-control = the cheat, padding→red)
                                 ∧ independent intent-review                        # count ≠ quality (Goodhart)
  unscriptable quality      ─▶ WEAK

gate = proxy(intent) ⇒ author adversarially:
  "cheapest artifact that turns gate green but misses intent?" ─▶ harden(cheat=neg-control) | floor + intent-review

done := gates.GREEN ∧ (generative/quality ⇒ indep-review.PASS)
indep-review := clean-context ∧ ¬self-review ∧ checks(recorded Intent) ∧ cites-evidence   # 'looks fine' ≠ evidence

spec-changed ⇒ reconcile probe SET (else /build re-runs stale set = false green):
  new req            ─▶ author probe
  changed acceptance ─▶ replace stale probe
  superseded req     ─▶ retire probe
  locked+Probed ∧ probe MISSING ─▶ incomplete gate ─▶ route /spec (NOT done)
  coherence: ∀ locked+Probed → ∃ .sh ; ∄ orphan probe
