{
  title = "gen's own nesting types name their declaring file as nixpkgs does";
  adr = "0039, fhggb";
  what = "`gen-nesting-types-name-their-declaring-file`: a loom's gen `submodule` options, a gen `attrsOf` and a nixpkgs `attrsOf` over the same gen `submodule`, and one declared untyped in `beam.nix` before its typed declaration in `heddle.nix`, whose module reads its own `options` argument; the `declarations` each reads through gen-merge's `evalModuleTree` equal nixpkgs' own `lib.evalModules` over the nixpkgs twin, which names `heddle.nix`, the declaration carrying the type, where gen-merge named `<unknown-file>`";
}
