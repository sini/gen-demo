# ── C19 — the discrete/monotone separation (den-hoag-0hwn; ADR-0019, ADR-0020, ADR-0012)
#
# Arntzenius & Krishnaswami (2016) split a typing context into a discrete ∆ and a monotone
# Γ, and type every non-monotone operation (¬, =, a caller-supplied function) under a
# CLEARED Γ. gen has no type-level split, so `gen-select/lib/match.nix`'s `discreteCtx`
# clears the VALUE instead: a context declares which of its accessors read a graph still
# under construction (`ctx.inFlight`), and the non-monotone positions — `not`, `attrs`,
# `when`, `parentMatches` among them — refuse to observe a declared accessor rather than
# answer against a value that has not settled.
#
# ONE two-node fixture, built through `adapters.registry.mkContext` like C16's own context
# above: "b" is a child of "a", and carries `key = "b"` in its own data, under the SAME
# condition — `builtins.elem "b" acc` — closing `parent`/`data` over one accumulator
# rather than a live fixpoint, which is all a two-value probe needs to exhibit both the
# answer RED gives and the refusal GREEN gives at the same read.
{ genSelect }:
let
  c19Ctx =
    acc: inFlight:
    genSelect.adapters.registry.mkContext {
      nodes = [
        "a"
        "b"
      ];
      data = id: if id == "b" && builtins.elem "b" acc then { key = "b"; } else { };
      parent = id: if id == "b" && builtins.elem "b" acc then "a" else null;
      entryFor = _: null; # neither node is entity-backed; kind matching is not this cell's business
      inherit inFlight;
    };
  # the writable cycle §1.1 names: "a" admits "b" as a child iff "b" does NOT already carry
  # the key its own admission would give it.
  c19NegTerm = genSelect.not (genSelect.has (genSelect.attrs { key = "b"; }));
in
{
  inherit c19Ctx c19NegTerm;
}
