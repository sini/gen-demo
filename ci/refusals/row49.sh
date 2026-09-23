# shellcheck shell=bash
# ── row 49 -- a type refusal renders its value shallowly, so a cyclic definition is refused by
#    name and not aborted (gen-types 14y3k) ──
# gen-types' `toPretty` recursed through every member of the value it rendered, so an `int` option
# defined as a cyclic set overflowed the stack inside the refusal (uncatchable) instead of refusing.
# The renderer now reads the value and never a member: `{ self = …; }`. The arms differ by DEF only;
# the unplanted arm asserts the value, so a type refusing every definition cannot pass it.
row49='let
  genMerge = (builtins.getFlake (toString ./.)).inputs.gen.lib.modules.merge;
in builtins.toJSON (genMerge.evalModuleTree {
  modules = [
    { options.port = genMerge.mkOption { type = genMerge.types.int; }; }
    { config.port = DEF; }
  ];
}).config.port'
row49unplanted="${row49/DEF/7}"
row49planted="${row49/DEF/let s = { self = s; \}; in s}"
check "T5 row49 unplanted (an int definition answers the value)" \
  "$row49unplanted" 0 "" "$tmpdir/row49-green.err" '7'
check "T5 row49 planted   (a cyclic set, refused by name with a shallow rendering)" \
  "$row49planted" 1 "is not of the expected type: expected type 'int' but value {" \
  "$tmpdir/row49-red.err"
check "T5 row49 catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval (builtins.deepSeq ($row49planted) true)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/row49-catch.err" 'CAUGHT'
