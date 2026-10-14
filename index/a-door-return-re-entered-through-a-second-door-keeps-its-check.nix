{
  title = "a door's return re-entered through a second door keeps its check";
  adr = "0025 item 1, 0039, dyagb";
  what = "`door-return-re-doored-keeps-its-check`: `defineType (mkOptionType X)` with X nixpkgs `addCheck` of `nullOr bolt`, `bolt` a gen `submodule`, and of `listOf int`, and `mkOptionType (defineType X)` over the same `nullOr`, each declared twice and mounted in nixpkgs' `lib.evalModules`, refuse `{ warp = 5; }` and `[ 1 2 3 ]`, which the checks reject, and serve `{ warp = 2; }` and `[ 1 2 ]`; gen-merge served the rejected values, because the second door's completion derived `typeMerge` from gen's relation, which the first door had not closed, or read the caller's base off the first door's closed join, where the check already stood";
}
