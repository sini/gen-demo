# `gen-nesting-types-name-their-declaring-file` — den-hoag-fhggb OQ-A, the sibling of
# `nested-options-name-their-declaring-file` over gen's OWN nesting types. A loom declared in `heddle.nix` states a
# `bolt` option of gen's `submodule` whose module states no `_file` and reads its own `options` argument
# (`seen = options.warp.declarations`), a `bolts` option of gen's `attrsOf` over it, a `pegs` option of nixpkgs'
# `attrsOf` over it, and a `shuttle` option declared first untyped in `beam.nix`, then with that type in
# `heddle.nix`. Each `seen`, read through gen-merge's engine, must equal the twin construction over nixpkgs' types
# and `evalModules`, which names `heddle.nix` in all four: the file of the declaration carrying the type.
# gen-merge named `<unknown-file>` in all four.
{
  asserts,
  genMerge,
  lib,
}:
let
  loom =
    L:
    let
      T = L.types;
      warp =
        { options, ... }:
        {
          options.warp = L.mkOption {
            type = T.int;
            default = 3;
          };
          options.seen = L.mkOption { default = options.warp.declarations; };
        };
    in
    [
      {
        _file = "beam.nix";
        options.shuttle = L.mkOption { description = "untyped"; };
      }
      {
        _file = "heddle.nix";
        options.bolt = L.mkOption {
          type = T.submodule warp;
          default = { };
        };
        options.bolts = L.mkOption {
          type = T.attrsOf (T.submodule warp);
          default = { };
        };
        options.pegs = L.mkOption {
          type = lib.types.attrsOf (T.submodule warp);
          default = { };
        };
        options.shuttle = L.mkOption {
          type = T.submodule warp;
          default = { };
        };
      }
      {
        _file = "treadle.nix";
        config.bolts.k = { };
        config.pegs.k = { };
      }
    ];
  read = ev: {
    bolt = ev.config.bolt.seen;
    bolts = ev.config.bolts.k.seen;
    pegs = ev.config.pegs.k.seen;
    shuttle = ev.config.shuttle.seen;
  };
  gen = read (genMerge.evalModuleTree { } (loom genMerge));
  ref = read (lib.evalModules { modules = loom lib; });
in
{
  construct = [ "gen-nesting-types-name-their-declaring-file-as-nixpkgs-does" ];
  check = asserts (
    ref == {
      bolt = [ "heddle.nix" ];
      bolts = [ "heddle.nix" ];
      pegs = [ "heddle.nix" ];
      shuttle = [ "heddle.nix" ];
    }
    && gen == ref
  );
}
