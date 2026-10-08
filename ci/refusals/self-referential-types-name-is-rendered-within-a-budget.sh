# shellcheck shell=bash
# ── row 51 -- a self-referential type's name is rendered within a budget, so its refusal returns
#    (gen-types, den-hoag-ns1z9) ──
# `r = union [ int (listOf r) ]` holds itself, and gen-types built a combinator's name by
# interpolating its members' names, so rendering `r`'s name in a refusal needed its own value: the
# option ACCEPTED a well-typed tree but aborted with `infinite recursion` (uncatchable) on an
# ill-typed one. A composite name is now rendered within a byte budget handed down to its members,
# so the refusal names `union<int,listOf<union<int,listOf<…`. The constructors are gen-types'
# checkers (`modules.types`; the list checker is `checkedListOf`), not gen-merge's structural
# `listOf`, which is not a checker and would refuse `r` on both arms. The arms differ by DEF only; the unplanted arm asserts the value.
row_self_referential_types_name_is_rendered_within_a_budget='let
  modules = (builtins.getFlake (toString ./.)).inputs.gen.lib.modules;
  genMerge = modules.merge;
  t = modules.types;
  r = t.union [ t.int (t.checkedListOf r) ];
in builtins.toJSON (genMerge.evalModuleTree { } [
    { options.tree = genMerge.mkOption { type = r; }; }
    { config.tree = DEF; }
  ]).config.tree'
row_self_referential_types_name_is_rendered_within_a_budgetunplanted="${row_self_referential_types_name_is_rendered_within_a_budget/DEF/[ 1 [ 2 ] ]}"
row_self_referential_types_name_is_rendered_within_a_budgetplanted="${row_self_referential_types_name_is_rendered_within_a_budget/DEF/[ 1 [ \"a\" ] ]}"
check "T5 self-referential-types-name-is-rendered-within-a-budget unplanted (a well-typed tree answers the value)" \
  "$row_self_referential_types_name_is_rendered_within_a_budgetunplanted" 0 "" "$tmpdir/self-referential-types-name-is-rendered-within-a-budget-green.err" '[1,[2]]'
check "T5 self-referential-types-name-is-rendered-within-a-budget planted   (an ill-typed tree, refused by name with a bounded type name)" \
  "$row_self_referential_types_name_is_rendered_within_a_budgetplanted" 1 "is not of the expected type: expected type 'union<int,listOf<union<int,listOf<" \
  "$tmpdir/self-referential-types-name-is-rendered-within-a-budget-red.err"
check "T5 self-referential-types-name-is-rendered-within-a-budget catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval (builtins.deepSeq ($row_self_referential_types_name_is_rendered_within_a_budgetplanted) true)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/self-referential-types-name-is-rendered-within-a-budget-catch.err" 'CAUGHT'
