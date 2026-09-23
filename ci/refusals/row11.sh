# shellcheck shell=bash
# ── row 11 -- C7's DOOR (mirrors C7's construction, `declaredDependencies` swapped for a
# hand-assembled attrset carrying the same `index`/`dependencies` fields `mkDeclaredEdges`
# would build, but no `_type` tag). `isDeclaredEdges` is purely nominal, so this is the only
# construct-granular refusal a hand-written stand-in cannot forge (Oracle 1b). The unplanted
# arm is the live control: the value `mkDeclaredEdges` itself mints is accepted. ──
row11='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genGraph = gen.lib.substrate.graph;
  genView = gen.lib.substrate.view;
  nodes = { pewter = { }; damask = { }; grosgrain = { }; faille = { }; };
  baseEdges = [
    { from = "pewter"; to = "grosgrain"; label = "tacks"; }
    { from = "grosgrain"; to = "damask"; label = "tacks"; }
    { from = "pewter"; to = "damask"; label = "gathers"; }
  ];
  ref = genGraph.mkNodeRef { isRegistered = id: nodes ? ${id}; };
  minted = genGraph.mkDeclaredEdges (map (e: e // { from = ref e.from; to = ref e.to; }) baseEdges);
  lookalikeIndex = { pewter = [ "grosgrain" "damask" ]; grosgrain = [ "damask" ]; };
  handAssembled = { index = lookalikeIndex; dependencies = id: lookalikeIndex.${id} or [ ]; };
  gated = genView.boundedWellDefinedSchedule {
    nodes = builtins.attrNames nodes;
    declaredDependencies = if DOOR then handAssembled else minted;
    equations = { };
    admitsCycle = _: false;
  };
in builtins.toJSON (gated.edges "pewter")'
check "T5 row11 unplanted (the value mkDeclaredEdges minted is accepted)" "${row11/DOOR/false}" 0 "" \
  "$tmpdir/row11-green.err" '["grosgrain","damask"]'
check "T5 row11 planted   (a hand-assembled lookalike, no _type tag, is refused by name)" \
  "${row11/DOOR/true}" 1 \
  "gen-view.boundedWellDefinedSchedule: field 'declaredDependencies' must be the relation \`gen-graph.mkDeclaredEdges\` returns; received an attrset that \`mkDeclaredEdges\` did not build" \
  "$tmpdir/row11-red.err"
