# shellcheck shell=bash
# ── row 43 -- a union over a member that is not a checker is refused by name (gen-types cyiuz,
#    mirrors C48's `union-member-refuses-by-name`) ──
# gen-types' combinators read each member's `verify` bare, and a gen-merge structural type carries
# `admits` and no `verify`, so `union [ (submodule …) str ]` aborted uncatchably on its first use
# (`attribute 'verify' missing`). The combinator now refuses a member that is not a checker by name.
# The arms differ by the MEMBERS only; the unplanted arm prints the value, so a union refusing every
# member cannot pass it.
row43='let
  genMerge = (builtins.getFlake (toString ./.)).inputs.gen.lib.modules.merge;
  keyed = genMerge.types.submodule {
    options.key = genMerge.mkOption { type = genMerge.types.str; default = "none"; };
  };
in builtins.toJSON (genMerge.evalModuleTree {
  modules = [
    { options.seam = genMerge.mkOption { type = genMerge.types.union MEMBERS; }; }
    { config.seam = DEF; }
  ];
}).config.seam'
row43a="${row43/MEMBERS/[ genMerge.types.str genMerge.types.int ]}"; row43unplanted="${row43a/DEF/\"sateen\"}"
row43b="${row43/MEMBERS/[ keyed genMerge.types.str ]}"; row43planted="${row43b/DEF/{ key = \"sateen\"; \}}"
check "T5 row43 unplanted (a union of checkers answers the value)" \
  "$row43unplanted" 0 "" "$tmpdir/row43-green.err" '"sateen"'
check "T5 row43 planted   (a submodule member, refused by name)" \
  "$row43planted" 1 "gen-types: union: member 'submodule' is not a checker" \
  "$tmpdir/row43-red.err"
check "T5 row43 catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval (builtins.deepSeq ($row43planted) true)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/row43-catch.err" 'CAUGHT'
