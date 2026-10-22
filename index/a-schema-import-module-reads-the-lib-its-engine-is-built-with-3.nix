{
  title = "a schema-import module reads the lib its engine is built with";
  adr = "0039 (parity-defect rule), 61r97 S4";
  what = "`schema-import-reads-the-instantiating-lib`: gen-merge built with nixpkgs' `lib` (its instantiation parameter, as nixpkgs' `lib/modules.nix` is `{ lib }:`) hands that `lib` to a `{ lib, ... }:` module declaring its options through it at the root, under `submodule`, under `attrsOf (submodule …)`, through `extendModules` and when nixpkgs' own `evalModules` mounts the gen `submodule`, reading what `lib.evalModules` reads at each; a caller's `specialArgs.lib` wins at the root only and `_module.args.lib` is shadowed, as there. The published engine, built with no `lib`, still refuses the read by name";
}
