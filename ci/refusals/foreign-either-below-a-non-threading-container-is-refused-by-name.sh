# shellcheck shell=bash
# ── a foreign `either` below a non-threading container is refused by name (den-hoag-p06j3; mirrors
#    `cells/foreign-either-below-a-non-threading-container.nix`; ADR-0039, ADR-0025 item 1) ──
# nixpkgs serves `coercedTo int f (either <gen submodule> str)`; gen-merge refuses it by name, the
# container "cannot thread the evaluation to that nested tree": an open defect (the parity-defect rule),
# not a price. The cell's tryEval conjunct says that it refuses; this row says what the refusal names.
# The unplanted arm is the same chain with gen's own `either`, which serves.
row_foreign_either_below_a_non_threading_container_is_refused_by_name='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  np = flake.inputs.nixpkgs.lib.types;
  t = genMerge.types;
  sub = t.submodule { options.a = genMerge.mkOption { type = t.int; default = 0; }; };
  either = EITHER;
in toString (genMerge.evalModuleTree { } [
    { options.h = genMerge.mkOption { type = np.coercedTo np.int (_: throw "coerced") (either sub np.str); }; }
    { h.a = 1; }
  ]).config.h.a'
row_foreign_either_below_a_non_threading_container_is_refused_by_nameunplanted="${row_foreign_either_below_a_non_threading_container_is_refused_by_name//EITHER/t.either}"
row_foreign_either_below_a_non_threading_container_is_refused_by_nameplanted="${row_foreign_either_below_a_non_threading_container_is_refused_by_name//EITHER/np.either}"
check "T5 foreign-either-below-a-non-threading-container-is-refused-by-name unplanted (gen's own either under coercedTo serves)" \
  "$row_foreign_either_below_a_non_threading_container_is_refused_by_nameunplanted" 0 "" \
  "$tmpdir/foreign-either-below-a-non-threading-container-is-refused-by-name-green.err" '1'
check "T5 foreign-either-below-a-non-threading-container-is-refused-by-name planted   (nixpkgs' either under coercedTo is refused by name)" \
  "$row_foreign_either_below_a_non_threading_container_is_refused_by_nameplanted" 1 \
  "the option type \`coercedTo' declares a gen nesting type as an element (its \`nestedTypes.finalType'), and it cannot thread the evaluation to that nested tree here" \
  "$tmpdir/foreign-either-below-a-non-threading-container-is-refused-by-name-red.err"
row_foreign_either_below_a_non_threading_container_is_refused_by_name_uniq='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  np = flake.inputs.nixpkgs.lib.types;
  t = genMerge.types;
  sub = t.submodule { options.a = genMerge.mkOption { type = t.int; default = 0; }; };
  either = EITHER;
in toString (genMerge.evalModuleTree { } [
    { options.h = genMerge.mkOption { type = np.uniq (either sub np.str); }; }
    { h.a = 1; }
  ]).config.h.a'
row_foreign_either_below_a_non_threading_container_is_refused_by_name_uniqunplanted="${row_foreign_either_below_a_non_threading_container_is_refused_by_name_uniq//EITHER/t.either}"
row_foreign_either_below_a_non_threading_container_is_refused_by_name_uniqplanted="${row_foreign_either_below_a_non_threading_container_is_refused_by_name_uniq//EITHER/np.either}"
check "T5 foreign-either-below-a-non-threading-container-is-refused-by-name uniq unplanted (gen's own either under uniq serves)" \
  "$row_foreign_either_below_a_non_threading_container_is_refused_by_name_uniqunplanted" 0 "" \
  "$tmpdir/foreign-either-below-a-non-threading-container-is-refused-by-name-uniq-green.err" '1'
check "T5 foreign-either-below-a-non-threading-container-is-refused-by-name uniq planted   (nixpkgs' either under uniq is refused by name)" \
  "$row_foreign_either_below_a_non_threading_container_is_refused_by_name_uniqplanted" 1 \
  "the option type \`unique' declares a gen nesting type as an element (its \`nestedTypes.elemType'), and it cannot thread the evaluation to that nested tree here" \
  "$tmpdir/foreign-either-below-a-non-threading-container-is-refused-by-name-uniq-red.err"
