{
  title = "a door copy redeclared in a stock host keeps its check";
  adr = "0039, 0025 item 1 (den-hoag-dw8d3)";
  what = "`door-copy-redeclared-in-a-stock-host`: a nixpkgs `addCheck` over `listOf int`, handed through `types.defineType`, typing a stock nixpkgs submodule's option declared in two modules with the copy later, refuses under nixpkgs' `evalModules` the value its check rejects and serves nixpkgs' own value for one it admits, where nixpkgs' redeclaration asked the copy's `typeMerge` and its rebuild dropped the check, serving the rejected value silently";
}
