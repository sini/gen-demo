# shellcheck shell=bash
# ── row 61 -- a node VALUE where a gen-graph door takes a node id is refused by name, catchably
#    (gen-graph bkdkg U1, ADR-0025 item 1) ──
# gen-graph's identifier doors used to abort past `tryEval` on a node value (`expected a string but
# found a set`), or answer a plausible value where the body only compared it with `==`. Each door now
# refuses under its own name. `dependentsOf` keys the id, so it takes a string; `reachableFrom` only
# hands it to the accessor and `genericClosure`, so it keeps every scalar and refuses the shapes that
# are never an id. The unplanted arm is the live control: the member id answers.
row61='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  tacks = { pewter = [ "grosgrain" ]; grosgrain = [ "damask" ]; damask = [ ]; };
  g = { edges = id: tacks.${id} or [ ]; nodes = builtins.attrNames tacks; };
  pewter = { name = "pewter"; };
in BODY'
check "T5 row61 unplanted (a member id answers at both doors; the answer is the assertion)" \
  "${row61/BODY/builtins.toJSON [ (genGraph.reachableFrom g \"pewter\") (genGraph.dependentsOf g \"damask\") ]}" 0 "" \
  "$tmpdir/row61-green.err" '[["grosgrain","damask"],["grosgrain","pewter"]]'
check "T5 row61 planted   (a node value where dependentsOf takes an id, refused by name)" \
  "${row61/BODY/builtins.toJSON (genGraph.dependentsOf g pewter)}" 1 \
  "gen-graph.dependentsOf: got set, expected a node identifier (a string)" \
  "$tmpdir/row61-red.err"
check "T5 row61 planted   (a node value where reachableFrom takes an id, refused by name)" \
  "${row61/BODY/builtins.toJSON (genGraph.reachableFrom g pewter)}" 1 \
  "gen-graph.reachableFrom: got set, expected a node identifier (a string or another scalar)" \
  "$tmpdir/row61-red2.err"
check "T5 row61 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row61/BODY/if (builtins.tryEval (builtins.deepSeq (genGraph.reachableFrom g pewter) true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row61-catch.err" 'CAUGHT'
