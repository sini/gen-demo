{
  title = "a door returned as itself states its check";
  adr = "0025 item 1, 0039, v4cw1";
  what = "`door-as-itself-states-its-check`: a `//` copy whose check is marked coherent over a merge that does not state it, a gen `nullOr bolt` through `mkOptionType` inside nixpkgs `either`, a nixpkgs `listOf int` through `types.defineType` as the option's own type, and `verify` copies of a gen and a nixpkgs `nullOr bolt` through `mkOptionType` inside `either`, mounted in nixpkgs' `lib.evalModules`, refuses `{ warp = 5; }` and `[ 1 2 3 ]`, which the checks reject, and serves `{ warp = 2; }`, `\"s\"` and `[ 1 2 ]`; gen-merge served the rejected values, because the door returned the record as itself and nixpkgs reads only `merge.v2`'s `headError`, which did not state the check";
}
