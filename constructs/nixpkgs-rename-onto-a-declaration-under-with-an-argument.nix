# ── A NIXPKGS RENAME ONTO A DECLARATION READ UNDER `with` AN ARGUMENT (den-hoag-8tmd5 OQ2) ─────────
# `warp`'s module declares it under `with loom;`, the module argument `loom` that another module
# defines through `_module.args` (NixOS `systemd.nix` under `with utils;`), and stock
# `lib.mkRenamedOptionModule` renames `weft` onto it. No other rename is pending, so the alias's only
# passes are its hops through the argument: gen-merge's declaration guard tries the pending nodes once
# at a constant pass and builds each earlier pass only when a later one reads it.
{
  genMerge,
  lib,
}:
let
  ev = genMerge.evalModuleTree { } [
    {
      options.warnings = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    }
    (
      { loom, ... }:
      with loom;
      {
        options.warp = lib.mkOption { type = shed; };
      }
    )
    { _module.args.loom.shed = lib.types.int; }
    (lib.mkRenamedOptionModule [ "weft" ] [ "warp" ])
    {
      _file = "heddle.nix";
      weft = 7;
    }
  ];
in
{
  withArgumentRename = ev.config.warp;
}
