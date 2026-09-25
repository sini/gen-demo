# shellcheck shell=bash
# ── rows 84/85 -- a caller closure's wrong return at the raw-closure applicators is refused BY NAME,
#    catchably, at gen-aspects' door (den-hoag-khnhi; ADR-0025 item 1, den-hoag-g8lo) ──
# A closure returning a closure used to abort inside gen-merge's module reader (`expected a set but
# found a function`, which `tryEval` cannot contain), or, curried, to materialise an aspect SILENTLY
# with its residual handed the module args. Row 84 plants it at the public `wrapFn`; row 85 at the
# NATIVE path, a bare guard closure in an aspect tree, which the aspect type wraps for its author.
# Each unplanted arm is the same site with a well-formed closure and asserts a STDOUT VALUE, so a
# door that refused everything cannot pass it.
rowWrapHeader='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  cnf = { keySemantics.classOne.category = "class"; };
  selfF = let f = _: f; in f;
  good = { host, ... }: { description = "d-${host}"; };
  under = p: q: { description = "x"; };
  native = v: (genAspects.aspectType cnf).merge [ "stitch" ] [ { file = "<row85>"; value = v; } ];
'
row84="${rowWrapHeader}"'in ((genAspects.wrapFn cnf "hem" CLOSURE) { host = "bobbin"; }).description'
check "T5 row84 unplanted (a closure returning aspect content applies)" \
  "${row84/CLOSURE/good}" 0 "" \
  "$tmpdir/row84-green.err" 'd-bobbin'
check "T5 row84 planted   (a closure returning a closure is refused by name at wrapFn)" \
  "${row84/CLOSURE/selfF}" 1 \
  "gen-aspects.wrapFn: the closure at \`hem\` must return aspect content" \
  "$tmpdir/row84-red.err"
check "T5 row84 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${rowWrapHeader}"'in if (builtins.tryEval (builtins.deepSeq ((genAspects.wrapFn cnf "hem" selfF) { host = "bobbin"; }) true)).success then "ADMITTED" else "CAUGHT"' 0 "" \
  "$tmpdir/row84-catch.err" 'CAUGHT'
row85="${rowWrapHeader}"'in ((native CLOSURE) { host = "bobbin"; }).description'
check "T5 row85 unplanted (a bare guard closure in an aspect applies)" \
  "${row85/CLOSURE/good}" 0 "" \
  "$tmpdir/row85-green.err" 'd-bobbin'
check "T5 row85 planted   (an under-applied guard closure is refused by name, naming the aspect)" \
  "${row85/CLOSURE/under}" 1 \
  "gen-aspects.aspectType: the closure at aspect \`stitch\` must return aspect content" \
  "$tmpdir/row85-red.err"
