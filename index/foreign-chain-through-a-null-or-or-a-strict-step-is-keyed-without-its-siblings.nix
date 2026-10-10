{
  title = "a foreign chain through a nullOr or a strict step is keyed without its siblings";
  adr = "0039, 0025 item 1, i01nx";
  what = "`foreign-chain-strict-keyed`: gen-merge's own `evalModuleTree` over nixpkgs `attrsWith { lazy = false; }` over `lazyAttrsOf (attrsOf sub)`, the same under `uniq`, and `uniq (lazyAttrsOf (attrsWith { lazy = false; } …))` reads `o.foo.j.k.a` as `1` with a key below the lazy step `mkIf` on the read tree, as does `uniq (nullOr (lazyAttrsOf (attrsOf …)))` while `o.bar`'s key set reads it, where each aborted uncatchably; beside a sibling of another type, and a `nullOr` sibling defined both `null` and a tree, it reads `1` where it was refused: `nullOr` is a step-free wrapper and every `attrsWith` a step, so a key is read only where it is read. A stock-named strict step whose merge swaps two keys' trees reads nixpkgs' `2`, where it was refused, and one whose merge adds a key to each tree is refused, catchably, where it served";
}
