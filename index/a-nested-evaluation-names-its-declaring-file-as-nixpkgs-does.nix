{
  title = "a nested evaluation names its declaring file as nixpkgs does";
  adr = "0039, fhggb, 5q139";
  what = "`nested-options-name-their-declaring-file`: a loom's nixpkgs `submodule` options, one declared in `heddle.nix` and one declared untyped in `beam.nix` before its typed declaration in `heddle.nix`, whose module reads its own `options` argument; the `declarations` it reads through `config`, and the second option's sub-option `declarations` read through the served type, each equal nixpkgs' own `lib.evalModules` over the same loom, which names `heddle.nix`, the declaration carrying the type, where gen-merge named `<unknown-file>`";
}
