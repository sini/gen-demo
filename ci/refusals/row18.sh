# shellcheck shell=bash
# ── row 18 -- exportType's republished functor, at the natural door: a redeclared option whose
# second declaration disagrees only on WHICH type governed the merge (mirrors interface.nix's
# importType/exportType retention and gen-schema's mkRefinedType, the motivating consumer) ──
row18='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  refinedInt = genSchema.refined genMerge.types.int [ genSchema.refinements.tcpPort ];
  base = { options.grommet = genMerge.mkOption { type = refinedInt; }; };
  second = { options.grommet = genMerge.mkOption { type = SECOND; }; };
  tree = genMerge.evalModuleTree { modules = [ base second ]; };
in tree.options.grommet.type.functor.name'
check "T5 row18 unplanted (grommet redeclared refined, functor identity holds)" "${row18/SECOND/refinedInt}" 0 "" \
  "$tmpdir/row18-green.err" 'refined<int>'
check "T5 row18 planted   (grommet redeclared bare int, functor identity dropped)" "${row18/SECOND/genMerge.types.int}" 1 \
  "own \`functor' (named \`refined<int>') does not reconcile with the second's (named \`int')" \
  "$tmpdir/row18-red.err"
