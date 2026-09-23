# shellcheck shell=bash
# ── row 52 -- a self-referential type has no identity, so redeclaring it refuses by name
#    (gen-types, den-hoag-z3nrc) ──
# Row 51's `r = union [ int (listOf r) ]`, now DECLARED TWICE: merging two declarations of one
# option asks gen-merge's parametric relation whether the two types are one, and that relation
# reads each type's minted identity. `r`'s identity re-entered `r`'s own mint, an uncatchable
# `infinite recursion`. gen-types now bounds type nesting for identity with a step-indexed guard
# (128 levels), so `r` is unmintable and the relation refuses by name. The arms differ by TYPE
# only: the unplanted arm is the flat `union [ int (listOf int) ]`, which mints and merges. `union`
# is `modules.merge.types`' (it carries the relation); `listOf` is gen-types' checker, not
# gen-merge's structural `listOf` (row 51's trap).
row52='let
  modules = (builtins.getFlake (toString ./.)).inputs.gen.lib.modules;
  genMerge = modules.merge;
  M = genMerge.types;
  t = modules.types;
  r = M.union [ M.int (t.listOf r) ];
  flat = M.union [ M.int (t.listOf M.int) ];
  ty = TYPE;
in builtins.toJSON (genMerge.evalModuleTree {
  modules = [
    { options.tree = genMerge.mkOption { type = ty; }; }
    { options.tree = genMerge.mkOption { type = ty; }; }
    { config.tree = [ 1 2 ]; }
  ];
}).config.tree'
row52unplanted="${row52/TYPE/flat}"
row52planted="${row52/TYPE/r}"
check "T5 row52 unplanted (a flat type declared twice merges and answers the value)" \
  "$row52unplanted" 0 "" "$tmpdir/row52-green.err" '[1,2]'
check "T5 row52 planted   (a self-referential type declared twice, refused by name)" \
  "$row52planted" 1 "whose parameters live behind their own predicate and cannot be compared" \
  "$tmpdir/row52-red.err"
check "T5 row52 catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval (builtins.deepSeq ($row52planted) true)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/row52-catch.err" 'CAUGHT'
