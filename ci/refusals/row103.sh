# shellcheck shell=bash
# ── row 103 -- a raw `get` on a quotient-converged instance is refused BY NAME, catchably
#    (den-hoag-q8pwl; C89) ──
# A quotient carrier converges on a class representative, so gen-scope serves it only through the
# named demand `getRepresentative`, tagged; the raw `get` refuses by name before evaluating. The
# unplanted arm reads the same instance through `getRepresentative` and asserts a STDOUT VALUE, so an
# evaluator refusing every demand cannot pass it. Every addressing is bound in the prelude: a `}`
# inside a `${row103/BODY/...}` replacement would end the expansion early.
row103='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  S = gen.lib.substrate.scope;
  r = S.eval { } {
      children = _: _: { };
      imports = _: _: [ ];
      weave = S.circular { carrier = { bottom = { }; leq = a: b: builtins.all (k: b ? ${k}) (builtins.attrNames a); height = 1; quotient = true; }; } (_: _: _: { warp0 = 0; });
    } (S.buildRoots { parentGraph = S.vertex "loom"; importGraph = S.empty; decls.loom = { }; types = { }; });
  green = builtins.toJSON (r.getRepresentative "loom" "weave");
  red = builtins.toJSON (r.get "loom" "weave");
  caught = if (builtins.tryEval (builtins.deepSeq (r.get "loom" "weave") true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row103 unplanted (the named demand answers the tagged representative)" \
  "${row103/BODY/green}" 0 "" "$tmpdir/row103-green.err" \
  '{"_type":"gen-scope/quotient-representative","representative":{"warp0":0}}'
check "T5 row103 planted   (the raw get on a quotient carrier is refused by name)" \
  "${row103/BODY/red}" 1 \
  "gen-scope: self.get 'weave' on 'loom' demands a raw value of a quotient-converged instance" \
  "$tmpdir/row103-red.err"
check "T5 row103 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row103/BODY/caught}" 0 "" "$tmpdir/row103-catch.err" 'CAUGHT'
