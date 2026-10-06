# shellcheck shell=bash
# ── rows 54/55 -- a kind's refinement contracts are read off its OPTION plane (gen-schema zijk1) ──
# A kind entry is a module, and neither module engine collects a top-level `mkOption` as a
# declaration; gen-schema used to run a second, syntactic reader of the raw declaration that did,
# so the two planes disagreed in both directions. Row 54: the flat `gauge = mkOption { … }` landed
# its contract and not its option, silently -- it is now an unread key, refused by name. Row 55: a
# refined option carried through `imports` landed its option and not its contract, so 70000 passed
# a `tcpPort` contract -- it is now refused as the refinement, naming the field. Each unplanted arm
# is the same kind declared where both engines read it, and asserts the answer.
row_kinds_refinement_contracts_are_read_off_its_option_plane='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  gauge = genMerge.mkOption { type = genSchema.refined genMerge.types.int genSchema.refinements.tcpPort; };
  tree = genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption {}; }
      { config.schema.thimble = DECL; }
    ];
in builtins.toJSON (builtins.attrNames tree.config.schema.thimble.options)'
row_kinds_refinement_contracts_are_read_off_its_option_planeunplant='{ imports = [ ]; options.gauge = gauge; }'
row_kinds_refinement_contracts_are_read_off_its_option_planeplant='{ imports = [ ]; inherit gauge; }'
check "T5 kinds-refinement-contracts-are-read-off-its-option-plane unplanted (the option declared under options: both planes read it)" \
  "${row_kinds_refinement_contracts_are_read_off_its_option_plane/DECL/$row_kinds_refinement_contracts_are_read_off_its_option_planeunplant}" 0 "" \
  "$tmpdir/kinds-refinement-contracts-are-read-off-its-option-plane-green.err" '["gauge"]'
check "T5 kinds-refinement-contracts-are-read-off-its-option-plane planted   (a top-level mkOption: an unread key, refused by name)" \
  "${row_kinds_refinement_contracts_are_read_off_its_option_plane/DECL/$row_kinds_refinement_contracts_are_read_off_its_option_planeplant}" 1 \
  "gen-schema: kind 'thimble': unrecognised declaration key 'gauge'" \
  "$tmpdir/kinds-refinement-contracts-are-read-off-its-option-plane-red.err"
row_imported_refined_option='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  gauge = genMerge.mkOption { type = genSchema.refined genMerge.types.int genSchema.refinements.tcpPort; };
  kind = (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption {}; }
      { config.schema.thimble.imports = [ { options.gauge = gauge; } ]; }
    ]).config.schema.thimble;
  tree = genMerge.evalModuleTree { } [
      { options.thimbles = genSchema.mkInstanceRegistry { } kind; }
      { config.thimbles.a.gauge = PORT; }
    ];
in builtins.toJSON tree.config.thimbles.a.gauge'
check "T5 imported-refined-option unplanted (an imported refined option, a value inside its contract)" \
  "${row_imported_refined_option/PORT/8080}" 0 "" \
  "$tmpdir/imported-refined-option-green.err" '8080'
check "T5 imported-refined-option planted   (the same option, 70000: its contract is enforced, by name)" \
  "${row_imported_refined_option/PORT/70000}" 1 \
  "gen-merge: a definition for option \`thimbles.a.gauge' is not of the expected type: must be a valid TCP port (1-65535)" \
  "$tmpdir/imported-refined-option-red.err"
