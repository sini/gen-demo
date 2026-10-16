# `container-elements-name-their-declaring-file` — den-hoag-kjcpb. A loom declared in `heddle.nix` states a `bolts`
# option of a gen-merge `attrsOf` and a `pins` option of a gen-merge `listOf`, each over a nixpkgs `submodule` whose
# module states no `_file` and reads its own `options` argument (`seen = options.warp.declarations`), and a `shuttles`
# option declared first untyped in `beam.nix`, then as a gen-merge `attrsOf` of that submodule in `heddle.nix`. Each
# element's `seen` must equal the same loom over nixpkgs' `evalModules`, which names `heddle.nix` in all three: the
# file of the declaration carrying the type. gen-merge named `<unknown-file>` in all three, its mount reaching a
# nixpkgs module set at an option's root and not below a gen container.
{
  asserts,
  genMerge,
  lib,
}:
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
  # the container family is the engine's own: gen-merge's on gen's engine, nixpkgs' on nixpkgs'
  loom = T: [
    {
      _file = "beam.nix";
      options.shuttles = L.mkOption { description = "untyped"; };
    }
    {
      _file = "heddle.nix";
      options.bolts = L.mkOption {
        type = T.attrsOf (L.types.submodule warp);
        default = { };
      };
      options.pins = L.mkOption {
        type = T.listOf (L.types.submodule warp);
        default = [ ];
      };
      options.shuttles = L.mkOption {
        type = T.attrsOf (L.types.submodule warp);
        default = { };
      };
    }
    {
      _file = "loom.nix";
      bolts.b = { };
      pins = [ { } ];
      shuttles.s = { };
    }
  ];
  read = ev: {
    bolt = ev.config.bolts.b.seen;
    pin = (builtins.head ev.config.pins).seen;
    shuttle = ev.config.shuttles.s.seen;
  };
  gen = read (genMerge.evalModuleTree { } (loom genMerge.types));
  ref = read (lib.evalModules { modules = loom lib.types; });
in
{
  construct = [ "a-nested-evaluation-names-its-declaring-file-as-nixpkgs-does" ];
  check = asserts (
    ref == {
      bolt = [ "heddle.nix" ];
      pin = [ "heddle.nix" ];
      shuttle = [ "heddle.nix" ];
    }
    && gen == ref
  );
}
