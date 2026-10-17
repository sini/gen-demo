{
  title = "the module arguments record lists its definitions as nixpkgs does";
  adr = "0039, zgpaa";
  what = "`module-arguments-list-their-definitions`: a loom stating `_module.args.shuttle`, forcing `_module.args.extendModules`, and declaring a gen `submodule` and an `attrsOf submodule` whose module reads its own `options._module.args.files`; the files at the top, in each child and through the served type, and whether the internal definition holds the engine's own function, each equal nixpkgs' `lib.evalModules` over nixpkgs' types, which lists its internal module's definition and, in a nested evaluation, its position's and its placeholder's `name` under `<unknown-file>`, where gen-merge listed the position's `name` under `lib/modules.nix` and neither of the others";
}
