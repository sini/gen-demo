# `options-argument-evaluated-record` — den-hoag-ixcxl. A module that reads its own `options` argument
# gets nixpkgs' evaluated option record: `options.warp.isDefined` gates a definition (`mkIf`, nixpkgs'
# commonest idiom) and `options.warp.definitions` reads the definitions the merge took, each equal to
# what nixpkgs' own `lib.evalModules` answers for the same modules, where gen-merge's argument lacked
# both keys and the read aborted uncatchably. The published record answers the same. An option nobody
# defines reads `isDefined = false` on both engines, which is the control.

{
  asserts,
  genMerge,
  lib,
}:

let
  modules = M: [
    {
      _file = "/loom/decl.nix";
      options.warp = M.mkOption { type = M.types.listOf M.types.str; };
      options.idle = M.mkOption { type = M.types.listOf M.types.str; };
      options.weft = M.mkOption {
        type = M.types.listOf M.types.str;
        default = [ ];
      };
      options.seen = M.mkOption {
        type = M.types.raw;
        default = null;
      };
    }
    {
      _file = "/loom/warp.nix";
      config.warp = [ "w" ];
    }
    {
      _file = "/loom/reader.nix";
      imports = [
        (
          { options, ... }:
          {
            config.weft = M.mkMerge [
              (M.mkIf options.warp.isDefined [ "warp" ])
              (M.mkIf options.idle.isDefined [ "idle" ])
            ];
            config.seen = options.warp.definitions;
          }
        )
      ];
    }
  ];
  read = ev: {
    inherit (ev.config) weft seen;
    published = ev.options.warp.definitions;
  };
  native = read (genMerge.evalModuleTree { } (modules genMerge));
  nixpkgs = read (lib.evalModules { modules = modules lib; });
  expected = {
    weft = [ "warp" ];
    seen = [ [ "w" ] ];
    published = [ [ "w" ] ];
  };
in

{
  construct = [ "a-module-reads-its-options-evaluated-record" ];
  check = asserts (native == expected && nixpkgs == expected);
}
