legend: R=requirement I=Intent A=Acceptance M=Method  P=Probed O=OPEN W=WEAK
  @=at-real-entrypoint  ¬=not  !=must  ✗=violation  ~cheat=negative-control-is-the-cheat  G=green
  prov=provenance{auto,human}  indR=independent-review

R! = {I,A,M}
I = def(✗) ; prov ; human ¬overwrite-by-auto (conflict→human)
M ∈ { P(.sh,+~broken) , O(no-redable→R unclosed) , W(cited|judge) }

A.kind→M:
  logic→P.unit
  api→P.integration
  ui/interaction→P.E2E @ ; ~cheat=break-WIRING(¬logic)     # ¬isolated-component
  quantity/threshold→FLOOR(¬quality): P.antideg(~cheat=padding→red) ∧ indR   # count≠quality
  unscriptable-quality→W

gate=proxy(I) → author-adversarial: min-cost artifact G-but-✗-I? → harden(~cheat) | floor+indR

done = G ∧ (generative→indR.pass)
indR = clean-ctx ∧ ¬self ∧ check(recorded I) ∧ cite     # "looks fine"≠evidence

spec-change → reconcile probe-SET (else stale G = false-green):
  new→author ; changed→replace-stale ; superseded→retire
  locked∧P∧probe-missing → incomplete-gate → /spec (¬done)
  coherence: ∀(locked∧P)∃.sh ; ∄orphan
