# shellcheck shell=bash
# ── rows 54/55 -- a kind's refinement contracts are read off its OPTION plane (gen-schema zijk1) ──
# A kind entry is a module, and neither module engine collects a top-level `mkOption` as a
# declaration; gen-schema used to run a second, syntactic reader of the raw declaration that did,
# so the two planes disagreed in both directions. Row 54: the flat `gauge = mkOption { … }` landed
# its contract and not its option, silently -- it is now an unread key, refused by name. Row 55: a
# refined option carried through `imports` landed its option and not its contract, so 70000 passed
# a `tcpPort` contract -- it is now refused as the refinement, naming the field. Each unplanted arm
# is the same kind declared where both engines read it, and asserts the answer.
row54='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  gauge = genMerge.mkOption { type = genSchema.refined genMerge.types.int genSchema.refinements.tcpPort; };
  tree = genMerge.evalModuleTree {
    modules = [
      { options.schema = genSchema.mkSchemaOption {}; }
      { config.schema.thimble = DECL; }
    ];
  };
in builtins.toJSON (builtins.attrNames tree.config.schema.thimble.options)'
row54unplant='{ imports = [ ]; options.gauge = gauge; }'
row54plant='{ imports = [ ]; inherit gauge; }'
check "T5 row54 unplanted (the option declared under options: both planes read it)" \
  "${row54/DECL/$row54unplant}" 0 "" \
  "$tmpdir/row54-green.err" '["gauge"]'
check "T5 row54 planted   (a top-level mkOption: an unread key, refused by name)" \
  "${row54/DECL/$row54plant}" 1 \
  "gen-schema: kind 'thimble': unrecognised declaration key 'gauge'" \
  "$tmpdir/row54-red.err"
row55='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  gauge = genMerge.mkOption { type = genSchema.refined genMerge.types.int genSchema.refinements.tcpPort; };
  kind = (genMerge.evalModuleTree {
    modules = [
      { options.schema = genSchema.mkSchemaOption {}; }
      { config.schema.thimble.imports = [ { options.gauge = gauge; } ]; }
    ];
  }).config.schema.thimble;
  tree = genMerge.evalModuleTree {
    modules = [
      { options.thimbles = genSchema.mkInstanceRegistry kind { }; }
      { config.thimbles.a.gauge = PORT; }
    ];
  };
in builtins.toJSON tree.config.thimbles.a.gauge'
check "T5 row55 unplanted (an imported refined option, a value inside its contract)" \
  "${row55/PORT/8080}" 0 "" \
  "$tmpdir/row55-green.err" '8080'
check "T5 row55 planted   (the same option, 70000: its contract is enforced, by name)" \
  "${row55/PORT/70000}" 1 \
  "gen-schema: refinement failed at thimble:a.gauge" \
  "$tmpdir/row55-red.err"
