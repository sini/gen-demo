# shellcheck shell=bash
# ── row 18 -- exportType's republished functor, at the natural door: a redeclared option whose
# second declaration disagrees only on WHICH type governed the merge (mirrors interface.nix's
# importType/exportType retention and gen-schema's mkRefinedType, the motivating consumer) ──
row_exporttypes_republished_functor='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  refinedInt = genSchema.refined genMerge.types.int [ genSchema.refinements.tcpPort ];
  base = { options.grommet = genMerge.mkOption { type = refinedInt; }; };
  second = { options.grommet = genMerge.mkOption { type = SECOND; }; };
  tree = genMerge.evalModuleTree { } [ base second ];
in tree.options.grommet.type.functor.name'
check "T5 exporttypes-republished-functor unplanted (grommet redeclared refined, functor identity holds)" "${row_exporttypes_republished_functor/SECOND/refinedInt}" 0 "" \
  "$tmpdir/exporttypes-republished-functor-green.err" 'refined<int>'
check "T5 exporttypes-republished-functor planted   (grommet redeclared bare int, functor identity dropped)" "${row_exporttypes_republished_functor/SECOND/genMerge.types.int}" 1 \
  "own \`functor' (named \`refined<int>') does not reconcile with the second's (named \`int')" \
  "$tmpdir/exporttypes-republished-functor-red.err"
