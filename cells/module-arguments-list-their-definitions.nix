# `module-arguments-list-their-definitions` — den-hoag-zgpaa. A loom states `_module.args.shuttle` in `beam.nix` and
# forces `_module.args.extendModules` in `treadle.nix`; `heddle.nix` declares a gen `submodule` option `bolt` and an
# `attrsOf submodule` option `reel`, whose module (`warp.nix`) states `_module.args.weft` and reads its own
# `options._module.args.files`; `pick.nix` defines `bolt._module.args.pick`. The `files` read at the top, in `bolt`,
# in `reel.r` and through the served type, and whether the top record's `lib/modules.nix` definition holds a
# function, must equal the same construction over nixpkgs' types and `evalModules`, which lists its internal
# module's definition (the engine's own `extendModules`, whatever a module forces) and, in a nested evaluation, its
# position's and its placeholder's `name`, both `<unknown-file>`. gen-merge listed the position's `name` under
# `lib/modules.nix`, and neither the internal definition nor the placeholder's.
{
  asserts,
  genMerge,
  lib,
}:
let
  loom =
    L:
    let
      warp =
        { options, ... }:
        {
          _file = "warp.nix";
          config._module.args.weft = 2;
          options.seen = L.mkOption { default = options._module.args.files; };
        };
    in
    [
      {
        _file = "beam.nix";
        _module.args.shuttle = 1;
      }
      {
        _file = "treadle.nix";
        _module.args.extendModules = L.mkForce null;
      }
      (
        { options, ... }:
        {
          _file = "heddle.nix";
          options.bolt = L.mkOption {
            type = L.types.submodule warp;
            default = { };
          };
          options.reel = L.mkOption {
            type = L.types.attrsOf (L.types.submodule warp);
            default = { };
          };
          options.top = L.mkOption { default = options._module.args.files; };
          options.internal = L.mkOption {
            default = map (d: {
              inherit (d) file;
              engine = builtins.isFunction (d.value.extendModules or null);
            }) options._module.args.definitionsWithLocations;
          };
        }
      )
      {
        _file = "pick.nix";
        config.bolt._module.args.pick = 3;
        config.reel.r = { };
      }
    ];
  read = ev: {
    top = ev.config.top;
    internal = ev.config.internal;
    bolt = ev.config.bolt.seen;
    reel = ev.config.reel.r.seen;
    served = (ev.options.bolt.type.getSubOptions [ ])._module.args.files;
  };
  gen = read (genMerge.evalModuleTree { } (loom genMerge));
  ref = read (lib.evalModules { modules = loom lib; });
in
{
  construct = [ "the-module-arguments-record-lists-its-definitions-as-nixpkgs-does" ];
  check = asserts (
    ref == {
      top = [
        "lib/modules.nix"
        "treadle.nix"
        "beam.nix"
      ];
      internal = [
        {
          file = "lib/modules.nix";
          engine = true;
        }
        {
          file = "treadle.nix";
          engine = false;
        }
        {
          file = "beam.nix";
          engine = false;
        }
      ];
      bolt = [
        "warp.nix"
        "lib/modules.nix"
        "pick.nix"
        "<unknown-file>"
        "<unknown-file>"
      ];
      reel = [
        "warp.nix"
        "lib/modules.nix"
        "<unknown-file>"
        "<unknown-file>"
      ];
      served = [
        "warp.nix"
        "lib/modules.nix"
        "<unknown-file>"
      ];
    }
    && gen == ref
  );
}
