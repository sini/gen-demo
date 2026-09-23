# `graph-query` — C1 + C2, both doors. gen-scope registers the two kinds and four nodes; gen-graph's
# named query walks `tacks*` then `piping*`; gen-select's second door is read with an explicit
# per-id `kindFor` over the heterogeneous node union.
#
# C1 + C2 — the assembled graph, queried, both doors. Red if a kind, a node, an
# edge, gen-scope's registration, gen-graph's query, or gen-select's second door stops
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
    "C1"
    "C2"
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
