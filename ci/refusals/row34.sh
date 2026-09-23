# shellcheck shell=bash
# ── row 34 -- a refinement over a FOREIGN parametric base is discriminated at its parameter
#    (gen-schema u92up) ──
# gen-schema's `refined` decided its base's half by the base's own `typeMergeRel`, and a raw nixpkgs
# type has none, so it fell back to the functor NAME -- which carries `listOf` and not its element.
# Declaring one option as a refined `listOf str` and a refined `listOf int` MERGED and kept the first
# base: the second declaration's element type was gone with nothing said. The same pair declared
# bare is refused by name. The base's half is now gen-merge's published `mergeTypes`, so a refined
# pair answers what its bare bases answer.
# ★ THE TWO ARMS DIFFER BY ONE ELEMENT TYPE on the second declaration; the container, the refinement
# and the module shape are byte-identical. The unplanted arm asserts the defined VALUE, so a library
# refusing every redeclaration cannot pass it; the planted arm's exit is what a library refusing
# nothing cannot pass. The stderr substring is row 30's template, so it proves a refusal FIRED, not
# which one -- discrimination lives in the ELEM swap and gen-schema's S1 cell. For the same reason
# this row stays out of the cross-row control below: its planted stderr is row 30's, byte for byte.
row34='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  lib = (builtins.getFlake (toString ./.)).inputs.nixpkgs.lib;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  reed = e: genMerge.mkOption { type = genSchema.refined (lib.types.listOf e) [ genSchema.refinements.nonEmpty ]; };
in builtins.concatStringsSep "," (genMerge.evalModuleTree {
  modules = [
    { options.reed = reed lib.types.str; }
    { options.reed = reed ELEM; }
    { config.reed = [ "warp" "weft" ]; }
  ];
}).config.reed'
check "T5 row34 unplanted (one foreign container and element declared twice; the value is the assertion)" \
  "${row34/ELEM/lib.types.str}" 0 "" \
  "$tmpdir/row34-green.err" 'warp,weft'
check "T5 row34 planted   (the same foreign container over a DIFFERENT element on the second declaration)" \
  "${row34/ELEM/lib.types.int}" 1 \
  "which the first type's own \`functor' does not reconcile" \
  "$tmpdir/row34-red.err"
