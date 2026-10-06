{
  title = "a mixed nesting redeclaration serves in either order";
  adr = "0025 item 1, 4v489";
  what = "`mixed-nesting-redeclared-either-order`: one option `loom` declared by nixpkgs' `submodule` and by gen-merge's `submodule`, in both orders, resolves under `genMerge.evalModuleTree` and `lib.evalModules` to the value of its nixpkgs × nixpkgs twin, where gen-merge refused it in both orders on its own engine and with nixpkgs' declaration first on nixpkgs'; a shorthand conflict (`submoduleWith { shorthandOnlyDefinesConfig = false; }` beside gen's `submodule`) refuses in both orders on both engines";
}
