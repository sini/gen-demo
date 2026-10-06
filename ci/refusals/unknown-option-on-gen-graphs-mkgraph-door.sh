# shellcheck shell=bash
# ── row 110 -- an unknown option on gen-graph's `mkGraph` door is refused BY NAME, catchably
#    (den-hoag-7gp66 P1, the uniform door grammar; ADR-0025 item 1) ──
# Before P1, `mkGraph`'s native closed formal (`{ edges ? [ ], parents ? [ ], nodeData ? { } }:`)
# aborted UNCATCHABLY on an argument outside that set, in Nix's words and not the door's. The door
# now takes a bare formal and applies gen-prelude's `checkOptions`, so the same violation names the
# door, the field and the accepted set, and `builtins.tryEval` sees it. The unplanted arm builds the
# graph from its accepted options and asserts a STDOUT VALUE; the arms differ by the one field.
row_unknown_option_on_gen_graphs_mkgraph_door='let
  genGraph = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.graph;
  build =
    extra:
    genGraph.mkGraph (
      {
        edges = [ { from = "selvage"; to = "weft"; } ];
      }
      // extra
    );
  green = builtins.toJSON (build { }).nodes;
  red = builtins.toJSON (build { bogus = 1; }).nodes;
  caught = if (builtins.tryEval (builtins.deepSeq (build { bogus = 1; }).nodes true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 unknown-option-on-gen-graphs-mkgraph-door unplanted (a graph door given only its accepted options constructs)" \
  "${row_unknown_option_on_gen_graphs_mkgraph_door/BODY/green}" 0 "" "$tmpdir/unknown-option-on-gen-graphs-mkgraph-door-green.err" '["selvage","weft"]'
check "T5 unknown-option-on-gen-graphs-mkgraph-door planted   (an unknown option on gen-graph's mkGraph door is refused BY NAME, den-hoag-7gp66 P1)" \
  "${row_unknown_option_on_gen_graphs_mkgraph_door/BODY/red}" 1 \
  "gen-graph.mkGraph: 'bogus' is not an option of this door; the options are closed (accepted: 'edges', 'parents', 'nodeData') (in prelude.checkOptions)" \
  "$tmpdir/unknown-option-on-gen-graphs-mkgraph-door-red.err"
check "T5 unknown-option-on-gen-graphs-mkgraph-door catchable  (the refusal is caught by tryEval, not an uncatchable formal-mismatch abort)" \
  "${row_unknown_option_on_gen_graphs_mkgraph_door/BODY/caught}" 0 "" "$tmpdir/unknown-option-on-gen-graphs-mkgraph-door-catch.err" 'CAUGHT'
