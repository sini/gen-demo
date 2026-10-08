{
  title = "a foreign chain with a stock list step is keyed from its definitions";
  adr = "0039, 0025 item 1, obi4j";
  what = "`foreign-chain-list-keyed`: gen-merge's own `evalModuleTree` over nixpkgs `coercedTo str f (listOf (lazyAttrsOf (attrsOf sub)))` reads `(head o).j.k.a` as `1` with a key below the list's element `mkIf` on the read tree, as does the same with a second element's key `mkIf` on it and `coercedTo str f (listOf (nullOr (lazyAttrsOf …)))`, where each aborted uncatchably: on a chain whose every record is its own functor's build, the `listOf` step is a level whose positions are keyed from its definitions, so an element is read only where it is read. A `listOf` whose merge was overridden to reverse its elements is not witnessed stock, keeps the eager walk, and serves nixpkgs' value";
}
