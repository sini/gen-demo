# shellcheck shell=bash
# ── row 10 -- C7's planted cycle (mirrors C7's own construction: C2's declared edges,
# contracted, gated by `boundedWellDefinedSchedule`). Plants `damask -> pewter`, closing
# `pewter -> grosgrain -> damask -> pewter`; the refusal must name that SCC. ──
row10='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genGraph = gen.lib.substrate.graph;
  genView = gen.lib.substrate.view;
  nodes = { pewter = { }; damask = { }; grosgrain = { }; faille = { }; };
  baseEdges = [
    { from = "pewter"; to = "grosgrain"; label = "tacks"; }
    { from = "grosgrain"; to = "damask"; label = "tacks"; }
    { from = "pewter"; to = "damask"; label = "gathers"; }
  ];
  plantedEdges = baseEdges ++ (if PLANT then [ { from = "damask"; to = "pewter"; label = "tacks"; } ] else [ ]);
  ref = genGraph.mkNodeRef { isRegistered = id: nodes ? ${id}; };
  contracted = es: genGraph.mkDeclaredEdges (map (e: e // { from = ref e.from; to = ref e.to; }) es);
  gated = genView.boundedWellDefinedSchedule {
    nodes = builtins.attrNames nodes;
    declaredDependencies = contracted plantedEdges;
    equations = { };
    admitsCycle = _: false;
  };
in builtins.toJSON gated'
check "T5 row10 unplanted (declared edges stay acyclic)" "${row10/PLANT/false}" 0 "" \
  "$tmpdir/row10-green.err" '{"equations":{}}'
check "T5 row10 planted   (damask -> pewter closes pewter -> grosgrain -> damask -> pewter)" \
  "${row10/PLANT/true}" 1 \
  "gen-view.boundedWellDefinedSchedule: the declared relation has a cyclic component \`admitsCycle\` does not admit: [[\"damask\",\"grosgrain\",\"pewter\"]]" \
  "$tmpdir/row10-red.err"
