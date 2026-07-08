Let a load-bearing requirement r = (I, A, M).

  I = (viol, p),  p ∈ {auto, human}                    (I = the definition of a violation)
  (p=human) ⇒ ¬ overwrite by later (p=auto);  conflict ⇒ resolve_by(human)

  M ∈ { Probed(s, n), Open, Weak }
      Probed(s, n): s a red-able script, n its negative control
      Open  ⇒ r unclosed              (no red-able check exists yet)
      Weak  ⇒ sign-off by cited-source ∨ independent-judge   (truth unscriptable)

  M = μ(A), where μ maps the acceptance's kind:
      A ∈ logic            ↦ Probed(unit)
      A ∈ service/api      ↦ Probed(integration)
      A ∈ user-visible     ↦ Probed(e2e @ real-entrypoint),  n breaks wiring/reachability (¬ logic-only)
      A ∈ quantity/thresh  ↦ Probed(anti-deg),  n = the cheat itself (padding ↦ red);  ∧ independent-review
                             — the count is a floor, ¬ a quality gate
      A ∈ quality           ↦ Weak

  gate g is a proxy for I. Let c(g) = cheapest artifact with pass(g) ∧ ¬meets(I).
      c(g) ≠ ∅ ⇒ harden(g) so c(g) becomes n,  ∨  ( floor(g) ∧ require(independent-review) )

  done(r) ⇔ green(r) ∧ ( generative(r) ⇒ pass(independent-review(r)) )
      independent-review := clean-context ∧ reviewer ≠ producer ∧ checks(I_recorded) ∧ cites(evidence)
      ( pass(green) alone ⇏ done  for generative r:  ∃ output. green ∧ metric-gamed )

  On spec change Δ, reconcile the probe set P (else build runs stale P ⇒ false-green):
      ∀ r ∈ Δ:  new(r) ↦ author(P_r);  changed(A_r) ↦ replace(P_r);  superseded(r) ↦ retire(P_r)
      coherence:  ∀ r ∈ locked ∧ Probed(r).  ∃ P_r   (missing ⇒ incomplete gate ⇒ /spec, ¬done)
                  ∧  ∄ orphan probe
