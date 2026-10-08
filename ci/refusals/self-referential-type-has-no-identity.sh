# shellcheck shell=bash
# ── row 52 -- a self-referential type has no identity, so redeclaring it refuses by name
#    (gen-types, den-hoag-z3nrc) ──
# Row 51's `r = union [ int (listOf r) ]`, now DECLARED TWICE: merging two declarations of one
# option asks gen-merge's parametric relation whether the two types are one, and that relation
# reads each type's minted identity. `r`'s identity re-entered `r`'s own mint, an uncatchable
# `infinite recursion`. gen-types now bounds type nesting for identity with a step-indexed guard
# (128 levels), so `r` is unmintable and the relation refuses by name. The arms differ by TYPE
# only: the unplanted arm is the flat `union [ int (listOf int) ]`, which mints and merges. `union`
# is `modules.merge.types`' (it carries the relation); `checkedListOf` is gen-types' checker, not
# gen-merge's structural `listOf` (row 51's trap).
row_self_referential_type_has_no_identity='let
  modules = (builtins.getFlake (toString ./.)).inputs.gen.lib.modules;
  genMerge = modules.merge;
  M = genMerge.types;
  t = modules.types;
  r = M.union [ M.int (t.checkedListOf r) ];
  flat = M.union [ M.int (t.checkedListOf M.int) ];
  ty = TYPE;
in builtins.toJSON (genMerge.evalModuleTree { } [
    { options.tree = genMerge.mkOption { type = ty; }; }
    { options.tree = genMerge.mkOption { type = ty; }; }
    { config.tree = [ 1 2 ]; }
  ]).config.tree'
row_self_referential_type_has_no_identityunplanted="${row_self_referential_type_has_no_identity/TYPE/flat}"
row_self_referential_type_has_no_identityplanted="${row_self_referential_type_has_no_identity/TYPE/r}"
check "T5 self-referential-type-has-no-identity unplanted (a flat type declared twice merges and answers the value)" \
  "$row_self_referential_type_has_no_identityunplanted" 0 "" "$tmpdir/self-referential-type-has-no-identity-green.err" '[1,2]'
check "T5 self-referential-type-has-no-identity planted   (a self-referential type declared twice, refused by name)" \
  "$row_self_referential_type_has_no_identityplanted" 1 "whose parameters live behind their own predicate and cannot be compared" \
  "$tmpdir/self-referential-type-has-no-identity-red.err"
check "T5 self-referential-type-has-no-identity catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval (builtins.deepSeq ($row_self_referential_type_has_no_identityplanted) true)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/self-referential-type-has-no-identity-catch.err" 'CAUGHT'
