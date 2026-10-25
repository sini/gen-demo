{
  title = "a redeclared nixpkgs submodule reads a function definition where nixpkgs does";
  adr = "0034, 0039, coek8";
  what = "`redeclared-foreign-submodule-reads-its-definition-in-place`: a loom declaring a nixpkgs `submodule` option `spool`, the engine's own `attrsOf` over it (`spools`) and `skein` in `reel.nix` and again in `bobbin.nix`, each over its own module, defined by a function module in `wind.nix` (`skein`'s importing `knot.nix`) and an attrset in `tie.nix`; each list reads `[ \"wind\" \"bobbin\" \"reel\" \"tie\" ]` (`skein`: `knot` first), equal to nixpkgs' `lib.evalModules`, which locates each declaration's module set once. gen-merge located a redeclared option's sets a second time at its root and read `[ \"bobbin\" \"reel\" \"wind\" \"tie\" ]`";
}
