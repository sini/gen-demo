# shellcheck shell=bash
# ── row 100 -- gen-graph's construction family refuses malformed caller data BY NAME, catchably
#    (den-hoag-ndte; ADR-0025 item 1) ──
# A graph constructor reads caller data, and a read that met the wrong shape aborted past `tryEval`
# with interpreter text (`expected a string but found an integer`, `attribute 'id' missing`). The
# refusal now names the door, the field and the element's position. The unplanted arms build the
# same two graphs well-formed and assert a STDOUT VALUE, so a constructor that refused everything
# cannot pass them. Every addressing is bound in the prelude: a `}` inside a `${row100/BODY/...}`
# replacement would end the expansion early.
row_gen_graphs_construction_family_refuses_malformed_caller_data_by_name='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  graph = gen.lib.substrate.graph;
  mk = from: graph.mkGraph { edges = [ { inherit from; to = "b"; } ]; };
  scanned = items: graph.fromScan { } {
    inherit items;
    scan = v: v;
    project = r: r;
  };
  goodMk = mk "a";
  goodScan = scanned [ { id = "a"; value = [ "b" ]; } ];
  mkGreen = builtins.toJSON { nodes = goodMk.nodes; a = goodMk.edges "a"; };
  scanGreen = builtins.toJSON { nodes = goodScan.nodes; a = goodScan.edges "a"; };
  badEdge = (mk 42).nodes;
  badItem = (scanned [ { value = [ "b" ]; } ]).nodes;
  edgeRed = builtins.toJSON badEdge;
  itemRed = builtins.toJSON badItem;
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
  caught = if refused badEdge && refused badItem then "CAUGHT" else "ADMITTED";
in BODY'
check "T5 gen-graphs-construction-family-refuses-malformed-caller-data-by-name unplanted (a well-formed mkGraph answers)" \
  "${row_gen_graphs_construction_family_refuses_malformed_caller_data_by_name/BODY/mkGreen}" 0 "" "$tmpdir/gen-graphs-construction-family-refuses-malformed-caller-data-by-name-green.err" '{"a":["b"],"nodes":["a","b"]}'
check "T5 gen-graphs-construction-family-refuses-malformed-caller-data-by-name unplanted (a well-formed fromScan answers)" \
  "${row_gen_graphs_construction_family_refuses_malformed_caller_data_by_name/BODY/scanGreen}" 0 "" "$tmpdir/gen-graphs-construction-family-refuses-malformed-caller-data-by-name-green-scan.err" '{"a":["b"],"nodes":["a","b"]}'
check "T5 gen-graphs-construction-family-refuses-malformed-caller-data-by-name planted   (an edge with a non-string from is refused by name)" \
  "${row_gen_graphs_construction_family_refuses_malformed_caller_data_by_name/BODY/edgeRed}" 1 \
  "gen-graph.mkGraph: edges element 0: 'from' is a int, not a node identifier (a string)" "$tmpdir/gen-graphs-construction-family-refuses-malformed-caller-data-by-name-red.err"
check "T5 gen-graphs-construction-family-refuses-malformed-caller-data-by-name planted   (a scanned item with no id is refused by name)" \
  "${row_gen_graphs_construction_family_refuses_malformed_caller_data_by_name/BODY/itemRed}" 1 \
  "gen-graph.fromScan: items element 0 has no 'id'" "$tmpdir/gen-graphs-construction-family-refuses-malformed-caller-data-by-name-red-scan.err"
check "T5 gen-graphs-construction-family-refuses-malformed-caller-data-by-name catchable  (both refusals are caught by tryEval, not an abort)" \
  "${row_gen_graphs_construction_family_refuses_malformed_caller_data_by_name/BODY/caught}" 0 "" "$tmpdir/gen-graphs-construction-family-refuses-malformed-caller-data-by-name-catch.err" 'CAUGHT'
