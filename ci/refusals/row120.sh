# shellcheck shell=bash
# ── row 120 -- the retired inheritance spelling is refused BY NAME, catchably (den-hoag-cxlc0; C21;
#    ADR-0025 item 1) ──
# C21's head tree: `thimble` reads `hank` out of the tree it is declared in,
# `imports = [ config.schema.hank ]`, through gen-aspects' own `schemaOption`. It composed silently;
# gen-schema now refuses a kind value in a kind entry's `imports` and names both kinds. The unplanted
# arm is the relocated spelling, `inherits = [ "hank" ]` through `evalSchema`, and asserts a STDOUT
# VALUE, `hank`'s `selvage` default read off `thimble`, so a library refusing every inheritance
# cannot pass it. Every addressing is bound in the prelude: a `}` inside a `${row120/BODY/...}`
# replacement would end the expansion early.
row120='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  aspectSchema = gen.lib.aspects.aspects.mkAspectSchema (import ./aspect-cnf.nix);
  hank.options.selvage = genMerge.mkOption { type = genMerge.types.str; default = "bound"; };
  spool.options.spool = genMerge.mkOption { type = genMerge.types.str; };
  head = (genMerge.evalModuleTree {
    modules = [
      { options.schema = aspectSchema.schemaOption; }
      ({ config, ... }: {
        config.schema.hank = hank;
        config.schema.thimble = spool // { imports = [ config.schema.hank ]; };
      })
    ];
  }).config.schema.thimble;
  relocated = (genSchema.evalSchema {
    inherit (aspectSchema) schemaOption;
    modules = [ { config.schema.hank = hank; config.schema.thimble = spool // { inherits = [ "hank" ]; }; } ];
  }).thimble;
  selvage = kind: kind.options.selvage.default;
  caught = if (builtins.tryEval (selvage head)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row120 unplanted (inherits, through evalSchema, composes hank into thimble)" \
  "${row120/BODY/selvage relocated}" 0 "" "$tmpdir/row120-green.err" 'bound'
check "T5 row120 planted   (a kind value in a kind entry's imports is refused by name)" \
  "${row120/BODY/selvage head}" 1 \
  "gen-schema: kind 'thimble': its \`imports\` carries the kind value 'hank', the retired spelling of kind inheritance; declare \`inherits = [ \"hank\" ]\` and build the schema with \`evalSchema\`" \
  "$tmpdir/row120-red.err"
check "T5 row120 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row120/BODY/caught}" 0 "" "$tmpdir/row120-catch.err" 'CAUGHT'
