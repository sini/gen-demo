# `nested-options-name-their-declaring-file` — den-hoag-fhggb, den-hoag-5q139. A loom declared in `heddle.nix` states
# a `bolt` option of a nixpkgs `submodule` whose module states no `_file` and reads its own `options` argument
# (`seen = options.warp.declarations`), and a `shuttle` option declared first untyped in `beam.nix`, then with that
# type in `heddle.nix`. `bolt.seen`, `shuttle.seen` and the `shuttle` sub-option's `declarations`, read through the
# served type, must equal the same construction over nixpkgs' `evalModules`, which names `heddle.nix` in all three:
# the file of the declaration carrying the type. gen-merge named `<unknown-file>` in all three, and a first-site
# reading named `beam.nix` for both `shuttle` reads.
{
  asserts,
  genMerge,
  lib,
}:
let
  # nixpkgs' own `mkOption` and types on both engines: the mount is where a nixpkgs module-set type is evaluated
  # (gen's own nesting types are evaluated by its nested walk, which this cell does not read)
  loom =
    let
      L = lib;
      warp =
        { options, ... }:
        {
          options.warp = L.mkOption {
            type = L.types.int;
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
          type = L.types.submodule warp;
          default = { };
        };
        options.shuttle = L.mkOption {
          type = L.types.submodule warp;
          default = { };
        };
      }
    ];
  read = ev: {
    bolt = ev.config.bolt.seen;
    shuttle = ev.config.shuttle.seen;
    served = (ev.options.shuttle.type.getSubOptions [ ]).warp.declarations;
  };
  gen = read (genMerge.evalModuleTree { } loom);
  ref = read (lib.evalModules { modules = loom; });
in
{
  construct = [ "a-nested-evaluation-names-its-declaring-file-as-nixpkgs-does" ];
  check = asserts (
    ref == {
      bolt = [ "heddle.nix" ];
      shuttle = [ "heddle.nix" ];
      served = [ "heddle.nix" ];
    }
    && gen == ref
  );
}
