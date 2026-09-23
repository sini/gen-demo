# shellcheck shell=bash
# ── row 62 -- a node VALUE where a gen-scope door takes a node id is refused by name, catchably
#    (gen-scope bkdkg U2, ADR-0025 item 1) ──
# gen-scope's accessor used to abort past `tryEval` on a node value (`expected a string but found a
# set`) at the attribute lookup, and `isAncestor` answered `false` about it, since it only compares
# the name. The accessor's `node`/`get` now refuse under their own names, and every structural query
# reaches that refusal by composition; `isAncestor` refuses the name it compares itself. The
# unplanted arm is the live control: member ids answer.
row62='let
  S = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  roots = S.buildRoots { parentGraph = S.edge "grosgrain" "pewter"; };
  self = S.eval {
    scope = roots;
    attributes.children = self: id:
      if id == "pewter" then builtins.intersectAttrs { grosgrain = 0; } roots.nodes else { };
  };
  pewter = { name = "pewter"; };
in BODY'
check "T5 row62 unplanted (member ids answer at both doors; the answer is the assertion)" \
  "${row62/BODY/builtins.toJSON [ (S.parent self \"grosgrain\") (S.isAncestor self \"pewter\" \"grosgrain\") ]}" 0 "" \
  "$tmpdir/row62-green.err" '["pewter",true]'
check "T5 row62 planted   (a node value where parent takes an id, refused by the accessor's name)" \
  "${row62/BODY/builtins.toJSON (S.parent self pewter)}" 1 \
  "gen-scope.self.node: got set, expected a node identifier (a string)" \
  "$tmpdir/row62-red.err"
check "T5 row62 planted   (a node value isAncestor would only compare, refused by name)" \
  "${row62/BODY/builtins.toJSON (S.isAncestor self pewter \"grosgrain\")}" 1 \
  "gen-scope.isAncestor: got set, expected a node identifier (a string)" \
  "$tmpdir/row62-red2.err"
check "T5 row62 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row62/BODY/if (builtins.tryEval (builtins.deepSeq (S.parent self pewter) true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row62-catch.err" 'CAUGHT'
