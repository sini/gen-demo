{
  title = "a container of trees under a step-free wrapper serves";
  adr = "0039, 0025 item 1, t1j4z";
  what = "`step-free-wrapper-container`: gen-merge's own `evalModuleTree` over nixpkgs `uniq (lazyAttrsOf (attrsOf sub))` reads `o.foo.a.x` as `1` while `o.bar` is a `throw`, never read, and over `coercedTo str (_: [ { x = 2; } ]) (listOf sub)` defined `[ { x = 1; } ]` and `\"s\"` reads nixpkgs' `[ { x = 2; } { x = 1; } ]`, the inner containers gen-merge's own: at the walk's root a container that adds no step is walked as the root is, where it was refused as S1 class (a)";
}
