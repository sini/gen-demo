{
  title = "a redeclared nesting option unions its modules in nixpkgs' order";
  adr = "0025 item 1, 0039, z75vj";
  what = "`foreign-nesting-redeclared-module-order`: one option `x` declared by a nixpkgs nesting type and two gen-merge ones, in all six orders, once as `submodule`s and once as module trees, each nested module defining a list `l`, reads under `genMerge.evalModuleTree` the list `lib.evalModules` reads (the last-declared module first), where every order read differently while a foreign type was in the fold";
}
