# shellcheck shell=bash
# ── row 12 -- the aspect includes contribution offered under the reserved label `I` (mirrors
# C16's own construction: graphFacts -> parentGraph -> a caller-labelled edgeGraphs entry) ──
row12='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genScope = gen.lib.substrate.scope;
  genAssemble = gen.lib.framework.assemble;
  genMerge = gen.lib.modules.merge;
  cnf = { };
  schema = genAspects.mkAspectSchema cnf;
  tree = genMerge.evalModuleTree {
    modules = [
      { options.schema = schema.schemaOption; }
      (schema.mkAspectModule { })
      { config.aspects.hemline.placket = { }; config.aspects.hemline.facing = { }; }
    ];
  };
  facts = genAspects.graphFacts cnf tree.config.aspects;
  parentGraph = genScope.overlays (map (id:
    let p = facts.parentOf.${id}; in
    if p == null then genScope.vertex id else genScope.edge id p) facts.nodes);
  aspectGraph = { name = "aspect-graph"; vertices = facts.nodes; inherit parentGraph;
    edgeGraphs = [ { label = LABEL; graph = genScope.edge "hemline/facing" "hemline/placket"; } ]; };
in builtins.toJSON (builtins.attrNames (genAssemble.assemble { contributions = [ aspectGraph ]; }).nodes)'
check "T5 row12 unplanted (label declares)" "${row12/LABEL/\"declares\"}" 0 "" \
  "$tmpdir/row12-green.err" '["hemline","hemline/facing","hemline/placket"]'
check "T5 row12 planted   (label I, the reserved import-relation name)" "${row12/LABEL/\"I\"}" 1 \
  "gen-assemble: a contribution offers the reserved label(s) [\"I\"]" \
  "$tmpdir/row12-red.err"
