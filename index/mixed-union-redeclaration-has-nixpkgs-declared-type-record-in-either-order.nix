{
  title = "a mixed union redeclaration has nixpkgs' declared-type record in either order";
  adr = "0025 item 1, 0039, zcufn";
  what = "`mixed-union-redeclared-record`: one option `loom` declared by nixpkgs' `either int bool` (and `oneOf [ int bool (listOf int) ]`) and by gen-merge's twin, in both orders, has under `genMerge.evalModuleTree` and `lib.evalModules` the declared-type record and value of its nixpkgs × nixpkgs twin at every member, where nixpkgs' engine refused the pair and gen's built a gen record whenever nixpkgs' declaration came first; a gen × gen pair keeps its gen record";
}
