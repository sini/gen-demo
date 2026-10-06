# shellcheck shell=bash
# ── row 43 -- a union over a member that is not a checker is refused by name (gen-types cyiuz,
#    mirrors C48's `union-member-refuses-by-name`) ──
# gen-types' combinators read each member's `verify` bare, and a gen-merge structural type carries
# `admits` and no `verify`, so `union [ (submodule …) str ]` aborted uncatchably on its first use
# (`attribute 'verify' missing`). The combinator now refuses a member that is not a checker by name.
# The arms differ by the MEMBERS only; the unplanted arm prints the value, so a union refusing every
# member cannot pass it.
row_union_over_a_member_that_is_not_a_checker='let
  genMerge = (builtins.getFlake (toString ./.)).inputs.gen.lib.modules.merge;
  keyed = genMerge.types.submodule {
    options.key = genMerge.mkOption { type = genMerge.types.str; default = "none"; };
  };
in builtins.toJSON (genMerge.evalModuleTree { } [
    { options.seam = genMerge.mkOption { type = genMerge.types.union MEMBERS; }; }
    { config.seam = DEF; }
  ]).config.seam'
row_union_over_a_member_that_is_not_a_checkera="${row_union_over_a_member_that_is_not_a_checker/MEMBERS/[ genMerge.types.str genMerge.types.int ]}"; row_union_over_a_member_that_is_not_a_checkerunplanted="${row_union_over_a_member_that_is_not_a_checkera/DEF/\"sateen\"}"
row_union_over_a_member_that_is_not_a_checkerb="${row_union_over_a_member_that_is_not_a_checker/MEMBERS/[ keyed genMerge.types.str ]}"; row_union_over_a_member_that_is_not_a_checkerplanted="${row_union_over_a_member_that_is_not_a_checkerb/DEF/{ key = \"sateen\"; \}}"
check "T5 union-over-a-member-that-is-not-a-checker unplanted (a union of checkers answers the value)" \
  "$row_union_over_a_member_that_is_not_a_checkerunplanted" 0 "" "$tmpdir/union-over-a-member-that-is-not-a-checker-green.err" '"sateen"'
check "T5 union-over-a-member-that-is-not-a-checker planted   (a submodule member, refused by name)" \
  "$row_union_over_a_member_that_is_not_a_checkerplanted" 1 "gen-types: union: member 'submodule' is not a checker" \
  "$tmpdir/union-over-a-member-that-is-not-a-checker-red.err"
check "T5 union-over-a-member-that-is-not-a-checker catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval (builtins.deepSeq ($row_union_over_a_member_that_is_not_a_checkerplanted) true)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/union-over-a-member-that-is-not-a-checker-catch.err" 'CAUGHT'
