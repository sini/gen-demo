{
  title = "a union over a lazy wrapper serves nixpkgs' value";
  adr = "0025 item 1, 4zvc9";
  what = "`union-over-lazy-wrapper`: gen-merge's own `either (lazyAttrsOf (uniq spool)) str`, and the same over `coercedTo str f spool`, `spool` a gen submodule, reads `heddle.k.x` as nixpkgs' value over its own types, where gen-merge aborted uncatchably on `attribute 'value' missing`";
}
