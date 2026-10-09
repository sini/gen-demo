{
  title = "a sibling stating no module set is not asked";
  adr = "0025 item 1, 0039, 87nvk";
  what = "`sibling-stating-no-module-set-threads`: nixpkgs `coercedTo` from an `int` whose `substSubModules` override dereferences its stock rebuild's `null` as a type, to a gen submodule, reads `twill` through the tree and `coerced` from an `int`, nixpkgs' values, where gen-merge's walk called that override on its marker, a call nixpkgs never makes, and aborted uncatchably; the same type over nixpkgs' submodule in nixpkgs' engine is the control";
}
