{
  title = "a mixed container redeclaration has nixpkgs' declared-type record in either order";
  adr = "0025 item 1, zvidt";
  what = "`mixed-container-redeclared-record`: one option `loom` declared by nixpkgs' `listOf int` (and `nullOr (listOf int)`) and by gen-merge's twin, in both orders, has under `genMerge.evalModuleTree` and `lib.evalModules` the declared-type record and value of its nixpkgs × nixpkgs twin at every container level, where the record was gen's whenever nixpkgs' declaration came first; a gen × gen pair keeps its gen record";
}
