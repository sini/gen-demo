# shellcheck shell=bash
# ── row 32 -- a refined option on a kind built through gen-aspects' `mkType` arm (mirrors C36's
#    `bobbin.picks`, gen-schema mx07b) ──
# The arm used to publish `refinements = { }` as a literal, so the registry enforced nothing a kind's
# refined option declared and `picks = 0` was accepted. The arms differ by the one instance value; the
# unplanted arm prints it, so a registry refusing every instance cannot pass.
row32='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  aspectSchema = genAspects.mkAspectSchema (import ./aspect-cnf.nix);
  schema = genSchema.evalSchema {
    inherit (aspectSchema) schemaOption;
    modules = [ { config.schema.bobbin.options.picks = genMerge.mkOption { type = genSchema.refined genMerge.types.int [ genSchema.refinements.positive ]; default = 1; }; } ];
  };
in toString (genMerge.evalModuleTree {
  modules = [
    { imports = [ (aspectSchema.mkAspectModule { }) ]; }
    { options.schema = genMerge.mkOption { type = genMerge.types.raw; default = schema; }; }
    { options.bobbins = genSchema.mkInstanceRegistry schema.bobbin { }; }
    { config.bobbins.grosgrain.picks = PICKS; }
  ];
}).config.bobbins.grosgrain.picks'
check "T5 row32 unplanted (an admissible value on the refined option)" "${row32/PICKS/3}" 0 "" \
  "$tmpdir/row32-green.err" '3'
check "T5 row32 planted   (a value the refinement forbids)" "${row32/PICKS/0}" 1 \
  "gen-schema: refinement failed at bobbin:grosgrain.picks" \
  "$tmpdir/row32-red.err"
