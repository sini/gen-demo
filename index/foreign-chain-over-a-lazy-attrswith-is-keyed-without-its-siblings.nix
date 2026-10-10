{
  title = "a foreign chain over a lazy attrsWith is keyed without its siblings";
  adr = "0039, 0025 item 1, fozin";
  what = "`foreign-chain-keyed`: gen-merge's own `evalModuleTree` over nixpkgs `uniq (attrsWith { lazy = true; placeholder = \"p\"; elemType = attrsOf sub; })` reads `o.foo.k.x` as `1` while `o.bar`'s key set reads `o.foo.k.x`, and over `coercedTo str f (lazyAttrsOf (attrsOf sub))` reads `1` beside an alias sibling: the foreign split keys the chain by the step its functors state and reads an element only where it is read, where it aborted uncatchably. The bare placeholder `attrsWith`'s plain read gives nixpkgs' `{ foo.k.x = 1; bar.k.x = 2; }`, and a stock-named `attrsWith` whose merge swaps two keys' trees reads `o.foo.k.x` as nixpkgs' `2`, where it was refused";
}
