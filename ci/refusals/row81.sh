# shellcheck shell=bash
# ── row 81 -- C7's CANDIDATE cycle (mirrors C7's construction under den-hoag-6s1t (iii): the
# registration set plus C5's candidate node, the declared edges plus C5's candidate edges, ON OR
# OFF). The policy is OFF here, so no reached edge closes anything; the plant `faille -> grosgrain`
# closes `grosgrain -> faille` through the piping CANDIDATE alone, and the refusal must name that
# SCC. `gate-candidate-cycle-off` drives the same plant through the real construct files. ──
row81='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genGraph = gen.lib.substrate.graph;
  genView = gen.lib.substrate.view;
  seam = "seam:pewter:grosgrain";
  nodes = { pewter = { }; damask = { }; grosgrain = { }; faille = { }; ${seam} = { }; };
  baseEdges = [
    { from = "pewter"; to = "grosgrain"; label = "tacks"; }
    { from = "grosgrain"; to = "damask"; label = "tacks"; }
    { from = "pewter"; to = "damask"; label = "gathers"; }
  ];
  candidateEdges = [
    { from = "grosgrain"; to = "faille"; label = "piping"; }
    { from = seam; to = "pewter"; label = "thimble"; }
    { from = seam; to = "grosgrain"; label = "bobbin"; }
  ];
  plantedEdges = baseEdges ++ candidateEdges ++ (if PLANT then [ { from = "faille"; to = "grosgrain"; label = "tacks"; } ] else [ ]);
  ref = genGraph.mkNodeRef { isRegistered = id: nodes ? ${id}; };
  contracted = es: genGraph.mkDeclaredEdges (map (e: e // { from = ref e.from; to = ref e.to; }) es);
  gated = genView.boundedWellDefinedSchedule {
    nodes = builtins.attrNames nodes;
    declaredDependencies = contracted plantedEdges;
    equations = { };
    admitsCycle = _: false;
  };
in builtins.toJSON gated'
check "T5 row81 unplanted (the candidates alone close no cycle)" "${row81/PLANT/false}" 0 "" \
  "$tmpdir/row81-green.err" '{"equations":{}}'
check "T5 row81 planted   (faille -> grosgrain closes a cycle only through the OFF piping candidate)" \
  "${row81/PLANT/true}" 1 \
  "gen-view.boundedWellDefinedSchedule: the declared relation has a cyclic component \`admitsCycle\` does not admit: [[\"faille\",\"grosgrain\"]]" \
  "$tmpdir/row81-red.err"
