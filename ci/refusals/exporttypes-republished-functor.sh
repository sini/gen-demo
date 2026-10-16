# shellcheck shell=bash
# ── row 18 -- exportType's republished functor, at the natural door: a redeclared option whose
# second declaration disagrees only on WHICH type governed the merge (mirrors interface.nix's
# importType/exportType retention and gen-schema's mkRefinedType, the motivating consumer). The planted
# second declaration is `str', which reconciles with no refinement of `int' (nixpkgs refuses the same pair
# as already declared). A bare `int' beside its own refinement is met, not refused: that pair is pinned by
# the cell refined-option-redeclared-beside-its-bare-base-is-met ──
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
check "T5 exporttypes-republished-functor planted   (grommet redeclared str, functor identity dropped)" "${row_exporttypes_republished_functor/SECOND/genMerge.types.str}" 1 \
  "own \`functor' (named \`refined<int>') does not reconcile with the second's (named \`str')" \
  "$tmpdir/exporttypes-republished-functor-red.err"
