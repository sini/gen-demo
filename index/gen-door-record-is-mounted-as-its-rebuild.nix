{
  title = "a gen door record is mounted as its rebuild";
  adr = "0025 item 1, 6yfat";
  what = "`gen-door-mounted-as-its-rebuild`: `treadle`, a type built through gen-merge's own `mkOptionType` whose merge answers `selvedge` and whose rebuild is nixpkgs' `submodule` over `warp`, reads what nixpkgs' `lib.evalModules` reads alone, under gen's `attrsOf` and inside a submodule, where gen-merge served the constant; a `treadle` that drops its `verify` reads what nixpkgs reads alone and under gen's `attrsOf`; a `treadle` whose fold is its rebuild's reads what it read before; a `treadle` demanding `weft` refuses a definition without it under gen's `attrsOf`, where nixpkgs' fix-up erases the check; a `treadle` with a null rebuild is refused catchably";
}
