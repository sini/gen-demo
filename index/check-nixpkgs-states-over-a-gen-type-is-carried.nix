{
  title = "a check nixpkgs states over a gen type is carried";
  adr = "0025 item 1, 4ifgb";
  what = "`foreign-check-carried`: `spool` typed nixpkgs `addCheck` over gen-merge's `int` refuses `5` and reads `2`, and nixpkgs `nonEmptyListOf` over a gen `submodule` refuses `[ ]` and reads `[ { warp = \"sateen\"; } ]`, where gen-merge served `5` and `[ ]`; a check added over a gen `either` holding a nested tree is carried and evaluated in `refusals` row 126: a failing one (`isAttrs`) is refused by name, and a passing one (`isString`) serves `sateen`";
}
