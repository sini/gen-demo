{
  title = "a batch warm pass dirties the union of its edits' cones";
  adr = "0008";
  what = "a warm pass over several edits (`genMemo.warmResolve`) decides its dirty set through one reverse-reachability application held across every seed: on gen-merge's bipartite relation, the decision over two seeds is the union of the two single-seed decisions node by node, a location outside both cones stays clean, and every warm read equals a fresh cold fold of the edited scope";
}
