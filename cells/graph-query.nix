# `graph-query` — C1 + C2, both doors. gen-scope registers the two kinds and four nodes; gen-scope's
# resolution calculus walks the named query `tacks*` then `piping*` over the evaluated scope;
# gen-select's second door is read with an explicit per-id `kindFor` over the heterogeneous node
# union.
#
# C1 + C2 — the assembled graph, queried, both doors. Red if a kind, a node, an
# edge, gen-scope's registration, gen-scope's `resolve`, or gen-select's second door stops
# working.
{
  asserts,
  bobbinNodes,
  gathered,
  selGrosgrain,
  selPewter,
  tacked,
  thimbles,
}:
{
  construct = [
    "kinds-and-nodes"
    "edges-queried"
  ];
  check = asserts (
    thimbles == [
      "damask"
      "pewter"
    ]
    &&
      bobbinNodes == [
        "faille"
        "grosgrain"
      ]
    &&
      tacked == [
        "damask"
        "faille"
        "grosgrain"
        "pewter"
      ]
    &&
      gathered == [
        "damask"
        "pewter"
      ]
    && selPewter == true
    && selGrosgrain == false
  );
}
