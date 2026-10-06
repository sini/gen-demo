# shellcheck shell=bash
# ── row 12 -- the aspect includes contribution offered under the reserved label `I` (mirrors
# C16's own construction: graphFacts -> parentGraph -> a caller-labelled edgeGraphs entry) ──
row_aspect_includes_contribution_offered_under_the_reserved_label_i='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genScope = gen.lib.substrate.scope;
  genAssemble = gen.lib.framework.assemble;
  genMerge = gen.lib.modules.merge;
  cnf = { };
  schema = genAspects.mkAspectSchema cnf;
  tree = genMerge.evalModuleTree { } [
      { options.schema = schema.schemaOption; }
      (schema.mkAspectModule { })
      { config.aspects.hemline.placket = { }; config.aspects.hemline.facing = { }; }
    ];
  facts = genAspects.graphFacts cnf tree.config.aspects;
  parentGraph = genScope.overlays (map (id:
    let p = facts.parentOf.${id}; in
    if p == null then genScope.vertex id else genScope.edge {
      from = id;
      to = p;
    }) facts.nodes);
  aspectGraph = { name = "aspect-graph"; vertices = facts.nodes; inherit parentGraph;
    edgeGraphs = [ { label = LABEL; graph = genScope.edge {
      from = "hemline/facing";
      to = "hemline/placket";
    }; } ]; };
in builtins.toJSON (builtins.attrNames (genAssemble.assemble { } [ aspectGraph ]).nodes)'
check "T5 aspect-includes-contribution-offered-under-the-reserved-label-i unplanted (label declares)" "${row_aspect_includes_contribution_offered_under_the_reserved_label_i/LABEL/\"declares\"}" 0 "" \
  "$tmpdir/aspect-includes-contribution-offered-under-the-reserved-label-i-green.err" '["hemline","hemline/facing","hemline/placket"]'
check "T5 aspect-includes-contribution-offered-under-the-reserved-label-i planted   (label I, the reserved import-relation name)" "${row_aspect_includes_contribution_offered_under_the_reserved_label_i/LABEL/\"I\"}" 1 \
  "gen-assemble: a contribution offers the reserved label(s) [\"I\"]" \
  "$tmpdir/aspect-includes-contribution-offered-under-the-reserved-label-i-red.err"
