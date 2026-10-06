# shellcheck shell=bash
# ── row 61 -- a node VALUE where a gen-graph door takes a node id is refused by name, catchably
#    (gen-graph bkdkg U1, ADR-0025 item 1) ──
# gen-graph's identifier doors used to abort past `tryEval` on a node value (`expected a string but
# found a set`), or answer a plausible value where the body only compared it with `==`. Each door now
# refuses under its own name. `dependentsOf` keys the id, so it takes a string; `reachableFrom` only
# hands it to the accessor and `genericClosure`, so it keeps every scalar and refuses the shapes that
# are never an id. The unplanted arm is the live control: the member id answers.
row_node_value_where_a_gen_graph_door_takes_a_node_id='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  tacks = { pewter = [ "grosgrain" ]; grosgrain = [ "damask" ]; damask = [ ]; };
  g = { edges = id: tacks.${id} or [ ]; nodes = builtins.attrNames tacks; };
  pewter = { name = "pewter"; };
in BODY'
check "T5 node-value-where-a-gen-graph-door-takes-a-node-id unplanted (a member id answers at both doors; the answer is the assertion)" \
  "${row_node_value_where_a_gen_graph_door_takes_a_node_id/BODY/builtins.toJSON [ (genGraph.reachableFrom g \"pewter\") (genGraph.dependentsOf g \"damask\") ]}" 0 "" \
  "$tmpdir/node-value-where-a-gen-graph-door-takes-a-node-id-green.err" '[["grosgrain","damask"],["grosgrain","pewter"]]'
check "T5 node-value-where-a-gen-graph-door-takes-a-node-id planted   (a node value where dependentsOf takes an id, refused by name)" \
  "${row_node_value_where_a_gen_graph_door_takes_a_node_id/BODY/builtins.toJSON (genGraph.dependentsOf g pewter)}" 1 \
  "gen-graph.dependentsOf: got set, expected a node identifier (a string)" \
  "$tmpdir/node-value-where-a-gen-graph-door-takes-a-node-id-red.err"
check "T5 node-value-where-a-gen-graph-door-takes-a-node-id planted   (a node value where reachableFrom takes an id, refused by name)" \
  "${row_node_value_where_a_gen_graph_door_takes_a_node_id/BODY/builtins.toJSON (genGraph.reachableFrom g pewter)}" 1 \
  "gen-graph.reachableFrom: got set, expected a node identifier (a string)" \
  "$tmpdir/node-value-where-a-gen-graph-door-takes-a-node-id-red2.err"
check "T5 node-value-where-a-gen-graph-door-takes-a-node-id catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_node_value_where_a_gen_graph_door_takes_a_node_id/BODY/if (builtins.tryEval (builtins.deepSeq (genGraph.reachableFrom g pewter) true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/node-value-where-a-gen-graph-door-takes-a-node-id-catch.err" 'CAUGHT'
