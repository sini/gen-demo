{
  title = "a foreign eval mounts a lazy container of submodules";
  adr = "0024 ruling 1, 0025 item 1";
  what = "`foreign-lazy-container-mount`: nixpkgs' own `lib.evalModules` mounts gen-merge's `lazyAttrsOf (attrsOf spool)` and `lazyAttrsOf (listOf spool)`, `spool` a gen submodule, and reads `sateen` through each spool, nixpkgs' value, where gen-merge aborted uncatchably on `attribute 'defs' missing`; the same `attrsOf` shape in gen-merge's own eval, read through its container node, is the control";
}
