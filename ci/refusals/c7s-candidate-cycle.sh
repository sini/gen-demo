# shellcheck shell=bash
# ── row 81 -- C7's CANDIDATE cycle (mirrors C7's construction under den-hoag-6s1t (iii): the
# registration set plus C5's candidate node, the declared edges plus C5's candidate edges, ON OR
# OFF). The policy is OFF here, so no reached edge closes anything; the plant `faille -> grosgrain`
# closes `grosgrain -> faille` through the piping CANDIDATE alone, and the refusal must name that
# SCC. `gate-candidate-cycle-off` drives the same plant through the real construct files. ──
row_c7s_candidate_cycle='let
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
  ref = genGraph.mkNodeRef (id: nodes ? ${id});
  contracted = es: genGraph.mkDeclaredEdges (map (e: e // { from = ref e.from; to = ref e.to; }) es);
  gated = genView.boundedWellDefinedSchedule {
    nodes = builtins.attrNames nodes;
    declaredDependencies = contracted plantedEdges;
    equations = { };
    admitsCycle = _: false;
  };
in builtins.toJSON gated'
check "T5 c7s-candidate-cycle unplanted (the candidates alone close no cycle)" "${row_c7s_candidate_cycle/PLANT/false}" 0 "" \
  "$tmpdir/c7s-candidate-cycle-green.err" '{"equations":{}}'
check "T5 c7s-candidate-cycle planted   (faille -> grosgrain closes a cycle only through the OFF piping candidate)" \
  "${row_c7s_candidate_cycle/PLANT/true}" 1 \
  "gen-view.boundedWellDefinedSchedule: the declared relation has a cyclic component \`admitsCycle\` does not admit: [[\"faille\",\"grosgrain\"]]" \
  "$tmpdir/c7s-candidate-cycle-red.err"
