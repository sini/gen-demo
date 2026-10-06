{
  title = "a nixpkgs container and its gen twin under another functor name serve in either order";
  adr = "0025 item 1, caxcw, khltw";
  what = "`functor-name-redeclared-either-order`: one option `loom` declared by nixpkgs' `attrsOf int` and gen-merge's `attrsOf int`, in both orders, under `genMerge.evalModuleTree` and `lib.evalModules`, equals its nixpkgs × nixpkgs twin where it refused (gen publishes `attrsWith`); nixpkgs' `deferredModuleWith { staticModules = [ … ]; }` beside gen's `deferredModule` keeps its static module in both orders, where gen's engine dropped it with nixpkgs first; the control, nixpkgs' `lazyAttrsOf int` beside gen's `attrsOf int`, refuses in both orders on both engines";
}
