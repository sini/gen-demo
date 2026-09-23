# shellcheck shell=bash
# ── row 51 -- a self-referential type's name is rendered within a budget, so its refusal returns
#    (gen-types, den-hoag-ns1z9) ──
# `r = union [ int (listOf r) ]` holds itself, and gen-types built a combinator's name by
# interpolating its members' names, so rendering `r`'s name in a refusal needed its own value: the
# option ACCEPTED a well-typed tree but aborted with `infinite recursion` (uncatchable) on an
# ill-typed one. A composite name is now rendered within a byte budget handed down to its members,
# so the refusal names `union<int,listOf<union<int,listOf<…`. The constructors are gen-types'
# checkers (`modules.types`), not gen-merge's structural `listOf`, which is not a checker and would
# refuse `r` on both arms. The arms differ by DEF only; the unplanted arm asserts the value.
row51='let
  modules = (builtins.getFlake (toString ./.)).inputs.gen.lib.modules;
  genMerge = modules.merge;
  t = modules.types;
  r = t.union [ t.int (t.listOf r) ];
in builtins.toJSON (genMerge.evalModuleTree {
  modules = [
    { options.tree = genMerge.mkOption { type = r; }; }
    { config.tree = DEF; }
  ];
}).config.tree'
row51unplanted="${row51/DEF/[ 1 [ 2 ] ]}"
row51planted="${row51/DEF/[ 1 [ \"a\" ] ]}"
check "T5 row51 unplanted (a well-typed tree answers the value)" \
  "$row51unplanted" 0 "" "$tmpdir/row51-green.err" '[1,[2]]'
check "T5 row51 planted   (an ill-typed tree, refused by name with a bounded type name)" \
  "$row51planted" 1 "is not of the expected type: expected type 'union<int,listOf<union<int,listOf<" \
  "$tmpdir/row51-red.err"
check "T5 row51 catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval (builtins.deepSeq ($row51planted) true)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/row51-catch.err" 'CAUGHT'
