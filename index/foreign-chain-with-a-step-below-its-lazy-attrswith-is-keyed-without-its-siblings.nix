{
  title = "a foreign chain with a step below its lazy attrsWith is keyed without its siblings";
  adr = "0039, 0025 item 1, rlskz";
  what = "`foreign-chain-nested-keyed`: gen-merge's own `evalModuleTree` over nixpkgs `uniq (lazyAttrsOf (attrsOf (attrsOf sub)))`, the inner `attrsOf` gen's, reads `o.foo.j.k.a` as `1` while `o.bar`'s key set reads it, as does `coercedTo str f` over three steps and an inner `mkIf` below the node: each key of the lazy step is a container node keyed in its stated record's regime, read only where it is read, where it aborted uncatchably. The whole value under siblings that add keys, `mkIf` on another key's tree and a discharged key is nixpkgs' value, and a stock-named `lazyAttrsOf` whose merge swaps two keys' trees is refused, catchably, where it served a wrong value";
}
