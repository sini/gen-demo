# shellcheck shell=bash
# ── row 73 -- a caller function's RESULT is refused BY NAME where gen-graph reads it, beyond `edges`
#    (gen-graph den-hoag-hekcx; ADR-0025 item 1: a caller-supplied function owes a door per failure mode) ──
# `select` applies the caller's `pred` and reads a bool, `topoOrder` applies `lessThan` one key at a
# time and reads a bool, and `materializeParents` applies `parent` and carries a node id or null. A
# `pred` result that is not a bool used to abort past `tryEval` ("expected a Boolean but found an
# integer"), a `lessThan` that is not a function aborted on its first comparison, a `lessThan` whose
# first application is not a function aborted on its second, and `materializeParents` carried a
# set-valued `parent` result into its answer at exit 0 -- the silent arm. The unplanted arm asserts
# the answers; the catchable arm is row 33's form.
row_caller_functions_result='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  lawful = id: { selvage = [ "warp" ]; warp = [ "weft" ]; }.${id} or [ ];
  lawfulParent = id: { warp = "selvage"; weft = "warp"; }.${id} or null;
  setParent = _: { };
  lawfulPred = d: d.name != "warp";
  intPred = _: 1;
  lawfulLess = a: b: a < b;
  underLess = _: true;
  graph = {
    nodes = [ "selvage" "warp" "weft" ];
    edges = lawful;
    nodeData = id: { name = id; };
    parent = PARENT;
  };
  picked = genGraph.select graph PRED;
  parents = genGraph.materializeParents graph;
  ordered = genGraph.topoOrder { lessThan = LESS; } { inherit (graph) nodes edges; };
in BODY'
row_caller_functions_resultok="${row_caller_functions_result/PARENT/lawfulParent}"
row_caller_functions_resultok="${row_caller_functions_resultok/PRED/lawfulPred}"
row_caller_functions_resultok="${row_caller_functions_resultok/LESS/lawfulLess}"
row_caller_functions_resultpred="${row_caller_functions_resultok/graph lawfulPred/graph intPred}"
row_caller_functions_resultparent="${row_caller_functions_resultok/parent = lawfulParent/parent = setParent}"
row_caller_functions_resultless="${row_caller_functions_resultok/lessThan = lawfulLess/lessThan = 1}"
row_caller_functions_resultunder="${row_caller_functions_resultok/lessThan = lawfulLess/lessThan = underLess}"
check "T5 caller-functions-result unplanted (lawful caller functions; the answers are the assertion)" \
  "${row_caller_functions_resultok/BODY/builtins.toJSON [ picked parents ordered.order ]}" 0 "" \
  "$tmpdir/caller-functions-result-green.err" '[["selvage","weft"],{"warp":"selvage","weft":"warp"},["weft","warp","selvage"]]'
check "T5 caller-functions-result planted   (a non-bool pred result, refused by name at select)" \
  "${row_caller_functions_resultpred/BODY/builtins.toJSON picked}" 1 \
  'gen-graph.select: pred on the node "selvage" returned a int, not a bool' \
  "$tmpdir/caller-functions-result-red-pred.err"
check "T5 caller-functions-result planted   (a set-valued parent, refused by name at materializeParents rather than answered)" \
  "${row_caller_functions_resultparent/BODY/builtins.toJSON parents}" 1 \
  'gen-graph.materializeParents: parent "selvage" returned a set, not a node id or null' \
  "$tmpdir/caller-functions-result-red-parent.err"
check "T5 caller-functions-result planted   (a lessThan that is not a function, refused by name at topoOrder)" \
  "${row_caller_functions_resultless/BODY/builtins.toJSON ordered}" 1 \
  'gen-graph.topoOrder: lessThan is a int, not a function returning a bool' \
  "$tmpdir/caller-functions-result-red-notfn.err"
check "T5 caller-functions-result planted   (a lessThan whose first application is not a function, refused by name at topoOrder)" \
  "${row_caller_functions_resultunder/BODY/builtins.toJSON ordered}" 1 \
  'gen-graph.topoOrder: lessThan on the key "warp" returned a bool, not a function from a key to a bool' \
  "$tmpdir/caller-functions-result-red-under.err"
check "T5 caller-functions-result catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_caller_functions_resultpred/BODY/if (builtins.tryEval (builtins.deepSeq picked true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/caller-functions-result-catch.err" 'CAUGHT'
