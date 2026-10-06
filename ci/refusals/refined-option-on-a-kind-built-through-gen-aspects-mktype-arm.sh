# shellcheck shell=bash
# ── row 32 -- a refined option on a kind built through gen-aspects' `mkType` arm (mirrors C36's
#    `bobbin.picks`, gen-schema mx07b) ──
# The arm used to publish `refinements = { }` as a literal, so the registry enforced nothing a kind's
# refined option declared and `picks = 0` was accepted. The arms differ by the one instance value; the
# unplanted arm prints it, so a registry refusing every instance cannot pass.
row_refined_option_on_a_kind_built_through_gen_aspects_mktype_arm='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  aspectSchema = genAspects.mkAspectSchema (import ./aspect-cnf.nix);
  schema = genSchema.evalSchema { schemaOption = aspectSchema.schemaOption; } [ { config.schema.bobbin.options.picks = genMerge.mkOption { type = genSchema.refined genMerge.types.int [ genSchema.refinements.positive ]; default = 1; }; } ];
in toString (genMerge.evalModuleTree { } [
    { imports = [ (aspectSchema.mkAspectModule { }) ]; }
    { options.schema = genMerge.mkOption { type = genMerge.types.raw; default = schema; }; }
    { options.bobbins = genSchema.mkInstanceRegistry { } schema.bobbin; }
    { config.bobbins.grosgrain.picks = PICKS; }
  ]).config.bobbins.grosgrain.picks'
check "T5 refined-option-on-a-kind-built-through-gen-aspects-mktype-arm unplanted (an admissible value on the refined option)" "${row_refined_option_on_a_kind_built_through_gen_aspects_mktype_arm/PICKS/3}" 0 "" \
  "$tmpdir/refined-option-on-a-kind-built-through-gen-aspects-mktype-arm-green.err" '3'
check "T5 refined-option-on-a-kind-built-through-gen-aspects-mktype-arm planted   (a value the refinement forbids)" "${row_refined_option_on_a_kind_built_through_gen_aspects_mktype_arm/PICKS/0}" 1 \
  "gen-merge: a definition for option \`bobbins.grosgrain.picks' is not of the expected type: must be positive" \
  "$tmpdir/refined-option-on-a-kind-built-through-gen-aspects-mktype-arm-red.err"
