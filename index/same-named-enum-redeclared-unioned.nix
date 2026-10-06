{
  title = "a same-named `enum` redeclared, unioned";
  adr = "0034";
  what = "`enum-redeclaration-unions`: two modules declare `weave` as `enum \"weave\"` over `[ \"twill\" ]` and `[ \"sateen\" ]`; gen-merge reads both through gen-types' `payloadOf` and merges them to their ordered union (nixpkgs `enum` `binOp`), so `weave = \"sateen\"` reads `sateen` and `satin` is refused catchably; `[ \"twill\" ]` twice reads `twill`";
}
