# `monotone-separation` — C19, den-hoag-0hwn. `discreteCtx` clears a context's declared
# `ctx.inFlight` accessors at gen-select's seven non-monotone positions (Datafun's discrete/monotone
# split, applied at evaluation time since gen has no type-level ∆/Γ to clear instead). A two-node
# fixture over `adapters.registry.mkContext` exercises the writable cycle at both seeds: `not`,
# `attrs` and `when` refuse catchably when the accessor they would read is declared in flight, while
# a frozen ctx, the monotone `has`, and `parentMatches` over the untouched `parent` accessor all
# still answer — the class is the read an accessor is put to, not the tag carrying it. A9 (the
# refusal is actionable) is not asserted here; it is a pairing on `ci/refusals.sh` instead, since
# `tryEval` exposes only `success`, never the thrown text.
#
# C19 — THE DISCRETE/MONOTONE SEPARATION (den-hoag-0hwn). `sel.not` (and six
# more positions — `attrs`, `when`, `entity`, `kind`, `coord`, `parentMatches`) is
# ANTITONE in `ctx`: growing the graph under construction can flip such a
# selector's answer, and nothing in gen refused a negative edge in a cycle being
# written against it. `discreteCtx` clears a context's declared `inFlight`
# accessors at exactly those non-monotone positions — Datafun's discrete/monotone
# split (Arntzenius & Krishnaswami 2016), applied at evaluation time because gen
# has no type-level ∆/Γ to clear instead.
#
# O1/O2 are the writable cycle itself, both seeds: "b" is a child of "a" iff "b"
# does not already carry the key its own admission would give it, unstable either
# way (RED's own `fromEmpty=true, fromB=false`). O3/O5/O6b are the controls that
# keep O1/O4/O6a from reading as a blanket refusal: the class is the READ an
# accessor is put to, not the tag carrying it. A9 (the refusal is actionable) is
# NOT asserted here — `tryEval` exposes only `{success, value}`, never the thrown
# text — and is instead a new pairing on `ci/refusals.sh` /
# `ci/tests/refusals-pairing.nix` (den-hoag-9mo), alongside its existing pairings.
{
  asserts,
  c19Ctx,
  c19NegTerm,
  genSelect,
}:
{
  construct = [ "C19" ];
  check = asserts (
    # O1 — the cycle REFUSES when `children` is declared in flight, at BOTH seeds
    # (the refusal fires at `not`'s own site, before `acc` is ever read).
    !(builtins.tryEval (
      builtins.deepSeq (genSelect.matches c19NegTerm "a" (c19Ctx [ ] [ "children" ])) true
    )).success
    && !(builtins.tryEval (
      builtins.deepSeq (genSelect.matches c19NegTerm "a" (c19Ctx [ "b" ] [ "children" ])) true
    )).success
    # O2 — CONTROL. the SAME selector and fixture, `inFlight = [ ]`: it ANSWERS, and
    # the two seeds give the two values RED gives — so O1 is not a blanket refusal.
    && genSelect.matches c19NegTerm "a" (c19Ctx [ ] [ ]) == true
    && genSelect.matches c19NegTerm "a" (c19Ctx [ "b" ] [ ]) == false
    # O3 — CONTROL. the Datafun-permitted case: `not` over a DISCRETE accessor
    # (`parent`, never declared in flight) still answers inside the same in-flight
    # context O1 refuses in.
    &&
      genSelect.matches (genSelect.not (genSelect.parentMatches genSelect.star)) "a" (
        c19Ctx [ "b" ] [ "children" ]
      ) == true
    # O4 — `sel.when` reaching an in-flight accessor refuses with NO `not` anywhere
    # in the term — the class is the read, not a negation syntactically present.
    && !(builtins.tryEval (
      builtins.deepSeq (genSelect.matches (genSelect.when (id: c: c.children id != [ ])) "a" (
        c19Ctx [ "b" ] [ "children" ]
      )) true
    )).success
    # O5 — CONTROL. a MONOTONE observation of the SAME in-flight accessor
    # (`sel.has`, no `not`) is not refused.
    &&
      genSelect.matches (genSelect.has (genSelect.attrs { key = "b"; })) "a" (
        c19Ctx [ "b" ] [ "children" ]
      ) == true
    # O6a — the class is the READ: `sel.attrs` refuses against an in-flight `data`.
    && !(builtins.tryEval (
      builtins.deepSeq (genSelect.matches (genSelect.attrs { key = "b"; }) "b" (
        c19Ctx [ "b" ] [ "data" ]
      )) true
    )).success
    # O6b — CONTROL. the SAME `sel.attrs` answers against an in-flight `children`,
    # which `attrs` never itself observes.
    && genSelect.matches (genSelect.attrs { key = "b"; }) "b" (c19Ctx [ "b" ] [ "children" ]) == true
  );
}
