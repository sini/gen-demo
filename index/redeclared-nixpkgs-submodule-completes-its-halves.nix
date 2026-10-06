{
  title = "a redeclared nixpkgs submodule completes its halves";
  adr = "0014, 0025 item 1";
  what = "`foreign-submodule-redeclared-freeform`: a stock nixpkgs `submodule` option `loom` redeclared, `config.warp = 2` in one half and `freeformType = attrsOf int` in the other, resolves to `{ warp = 2; }` under gen-merge as under nixpkgs, where gen-merge forced each half's own module set and refused \"option does not exist\"; a key no half declares and no freeformType absorbs refuses on both engines";
}
