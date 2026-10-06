{
  title = "a mixed leaf redeclaration has nixpkgs' declared-type record in either order";
  adr = "0025 item 1, x4j3w";
  what = "`mixed-leaf-redeclared-record`: one option `loom` declared by nixpkgs' `int`, `bool`, `float`, `raw` or `anything` (bare and under `listOf`) and by gen-merge's twin, in both orders, has under `genMerge.evalModuleTree` and `lib.evalModules` the declared-type record and value of its nixpkgs × nixpkgs twin, where the record was gen's whenever nixpkgs' declaration came first; a gen × gen pair keeps its gen record";
}
