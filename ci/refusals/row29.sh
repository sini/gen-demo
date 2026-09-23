# shellcheck shell=bash
# ── row 29 -- a COLLECTION name colliding with gen-schema's own vocabulary (gen-schema 6vgwm) ──
# Row 28's mirror image, and the pair is deliberate: row 28 guards a kind DECLARATION against the
# vocabulary, row 29 guards the VOCABULARY against the constructor argument. Neither door can cover
# for the other -- `surplusDeclarationKeys` has `collectionKeys` as a term of its own ALLOW-list, so
# no collection key can ever be surplus and row 28's guard is blind to every input here.
# ★ THE TWO ARMS DIFFER BY A COLLECTION NAME ON `mkSchemaOption`, one token apart. The kind
# declaration is byte-identical and well-formed on BOTH -- unlike row 28, nothing here is a typo and
# nothing is malformed. What changes is a name in the SCHEMA's configuration.
# ★ WHAT THE PLANTED ARM DID BEFORE THE DOOR, measured in this corpus at gen-schema a89efce: it
# exited 0 and produced `thimble:17fa9b9a...` -- a DIFFERENT node from the unplanted arm's
# `thimble:80177db4...`, silently. `strippedDefs` removes every collection key from every def before
# the module merge, so a collection named `options` deletes the kind's option MODULE while
# `kind.options` still advertises it; the mint's preimage reads the stripped introspection and the
# identity moves. Under ADR-0016 ruling 5 that is a different node, propagating into every binding
# referencing it. No throw, no warning.
# ★ THE UNPLANTED ARM ASSERTS THE id_hash ITSELF, not merely an exit code: it is the corpus's own
# unmoved stamp, so a library that refused everything cannot pass it and a library that moved the
# identity a different way cannot either. The planted arm's exit code and message are what a library
# refusing nothing cannot pass.
row29='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  strOpt = genMerge.mkOption { type = genMerge.types.str; default = "linen"; };
  schema = (genMerge.evalModuleTree {
    modules = [
      { options.schema = genSchema.mkSchemaOption { collections.COLLECTIONNAME = { default = [ ]; }; }; }
      { config.schema.thimble = { options.spool = strOpt; }; }
    ];
  }).config.schema;
in (genMerge.evalModuleTree {
  modules = [
    {
      options.thimbles = genSchema.mkInstanceRegistry schema.thimble { };
      config.thimbles.t1 = { name = "t1"; };
    }
  ];
}).config.thimbles.t1.id_hash'
check "T5 row29 unplanted (an ORDINARY collection name, and the instance's stamp is the assertion)" \
  "${row29/COLLECTIONNAME/spools}" 0 "" \
  "$tmpdir/row29-green.err" 'thimble:80177db4d723f893f012782915c3c7716d5e52ed4fd59113a9caee27552b1ce8'
check "T5 row29 planted   (the same declaration, the collection renamed to a key gen-schema writes)" \
  "${row29/COLLECTIONNAME/options}" 1 \
  "gen-schema: collection 'options' is reserved — cannot be used as a collection key" \
  "$tmpdir/row29-red.err"
