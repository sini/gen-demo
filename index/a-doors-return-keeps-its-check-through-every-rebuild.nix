{
  title = "a door's return keeps its check through every rebuild";
  adr = "0025 item 1, 0039, d61ws";
  what = "`door-return-closed-under-its-rebuilds`: `mkOptionType` over nixpkgs `addCheck` of `nullOr bolt`, `bolt` a gen `submodule`, declared once, and of `listOf int`, declared after its plain twin and twice, mounted in nixpkgs' `lib.evalModules`, refuses `{ warp = 5; }` and `[ 1 2 3 ]`, which the checks reject, and serves `{ warp = 2; }`, `null` and `[ 1 2 ]`; gen-merge served the rejected values, because nixpkgs re-derives the declared type through the record's `substSubModules` and the later declaration's `typeMerge`, which were the constructor's and dropped the check";
}
