{
  title = "a type cycled through containers alone refuses its spine";
  adr = "0025 item 1, iaram";
  what = "`cyclic-type-spine`: a gen-merge `bobbin = nullOr (listOf bobbin)` is served `[ null [ null ] ]` by gen's `evalModuleTree`; mounted through nixpkgs' `lib.evalModules`, its `getSubModules` read refuses by name, caught by `tryEval`, where nixpkgs' twin aborts uncatchably; the control, the same cycle closed through `oneOf [ int (listOf spool) ]`, is served by nixpkgs";
}
