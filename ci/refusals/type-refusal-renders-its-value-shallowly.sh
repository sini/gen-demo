# shellcheck shell=bash
# ── row 49 -- a type refusal renders its value shallowly, so a cyclic definition is refused by
#    name and not aborted (gen-types 14y3k) ──
# gen-types' `toPretty` recursed through every member of the value it rendered, so an `int` option
# defined as a cyclic set overflowed the stack inside the refusal (uncatchable) instead of refusing.
# The renderer now reads the value and never a member: `{ self = …; }`. The arms differ by DEF only;
# the unplanted arm asserts the value, so a type refusing every definition cannot pass it.
row_type_refusal_renders_its_value_shallowly='let
  genMerge = (builtins.getFlake (toString ./.)).inputs.gen.lib.modules.merge;
in builtins.toJSON (genMerge.evalModuleTree { } [
    { options.port = genMerge.mkOption { type = genMerge.types.int; }; }
    { config.port = DEF; }
  ]).config.port'
row_type_refusal_renders_its_value_shallowlyunplanted="${row_type_refusal_renders_its_value_shallowly/DEF/7}"
row_type_refusal_renders_its_value_shallowlyplanted="${row_type_refusal_renders_its_value_shallowly/DEF/let s = { self = s; \}; in s}"
check "T5 type-refusal-renders-its-value-shallowly unplanted (an int definition answers the value)" \
  "$row_type_refusal_renders_its_value_shallowlyunplanted" 0 "" "$tmpdir/type-refusal-renders-its-value-shallowly-green.err" '7'
check "T5 type-refusal-renders-its-value-shallowly planted   (a cyclic set, refused by name with a shallow rendering)" \
  "$row_type_refusal_renders_its_value_shallowlyplanted" 1 "is not of the expected type: expected type 'int' but value {" \
  "$tmpdir/type-refusal-renders-its-value-shallowly-red.err"
check "T5 type-refusal-renders-its-value-shallowly catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval (builtins.deepSeq ($row_type_refusal_renders_its_value_shallowlyplanted) true)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/type-refusal-renders-its-value-shallowly-catch.err" 'CAUGHT'
