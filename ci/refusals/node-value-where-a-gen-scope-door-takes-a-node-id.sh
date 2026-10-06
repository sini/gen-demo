# shellcheck shell=bash
# ── row 62 -- a node VALUE where a gen-scope door takes a node id is refused by name, catchably
#    (gen-scope bkdkg U2, ADR-0025 item 1) ──
# gen-scope's accessor used to abort past `tryEval` on a node value (`expected a string but found a
# set`) at the attribute lookup, and `isAncestor` answered `false` about it, since it only compares
# the name. The accessor's `node`/`get` now refuse under their own names, and every structural query
# reaches that refusal by composition; `isAncestor` refuses the name it compares itself. The
# unplanted arm is the live control: member ids answer.
row_node_value_where_a_gen_scope_door_takes_a_node_id='let
  S = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  roots = S.buildRoots { parentGraph = S.edge {
    from = "grosgrain";
    to = "pewter";
  }; };
  self = S.eval { } {
    children = self: id:
      if id == "pewter" then builtins.intersectAttrs { grosgrain = 0; } roots.nodes else { };
  } roots;
  pewter = { name = "pewter"; };
in BODY'
check "T5 node-value-where-a-gen-scope-door-takes-a-node-id unplanted (member ids answer at both doors; the answer is the assertion)" \
  "${row_node_value_where_a_gen_scope_door_takes_a_node_id/BODY/builtins.toJSON [ (S.parent self \"grosgrain\") (S.isAncestor self \"pewter\" \"grosgrain\") ]}" 0 "" \
  "$tmpdir/node-value-where-a-gen-scope-door-takes-a-node-id-green.err" '["pewter",true]'
check "T5 node-value-where-a-gen-scope-door-takes-a-node-id planted   (a node value where parent takes an id, refused by the accessor's name)" \
  "${row_node_value_where_a_gen_scope_door_takes_a_node_id/BODY/builtins.toJSON (S.parent self pewter)}" 1 \
  "gen-scope.self.node: got set, expected a node identifier (a string)" \
  "$tmpdir/node-value-where-a-gen-scope-door-takes-a-node-id-red.err"
check "T5 node-value-where-a-gen-scope-door-takes-a-node-id planted   (a node value isAncestor would only compare, refused by name)" \
  "${row_node_value_where_a_gen_scope_door_takes_a_node_id/BODY/builtins.toJSON (S.isAncestor self pewter \"grosgrain\")}" 1 \
  "gen-scope.isAncestor: got set, expected a node identifier (a string)" \
  "$tmpdir/node-value-where-a-gen-scope-door-takes-a-node-id-red2.err"
check "T5 node-value-where-a-gen-scope-door-takes-a-node-id catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_node_value_where_a_gen_scope_door_takes_a_node_id/BODY/if (builtins.tryEval (builtins.deepSeq (S.parent self pewter) true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/node-value-where-a-gen-scope-door-takes-a-node-id-catch.err" 'CAUGHT'
