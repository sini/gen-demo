# ── A NIXPKGS RENAME ONTO AN OPTION TYPED BY A MODULE ARGUMENT (den-hoag-8tmd5 M1) ───────────────
# `skein`'s type reads the module argument `spool`, which another module defines through
# `_module.args`, and stock `lib.mkRenamedOptionModule` renames `hank` onto it, so `doRename`'s alias
# leaf copies a type that reads an argument (NixOS `systemd.nix` under `with utils;`). gen-merge's
# declaration guard resolves the alias in a staged pass whose earlier pass's declarations carry the
# arguments their own modules define. The chain `selvage` → `fringe` → `braid` resolves one link per
# pass and keeps the passes running to the one where `spool` is readable.
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
      options.braid = lib.mkOption { type = lib.types.str; };
    }
    (
      { spool, ... }:
      {
        options.skein = lib.mkOption { type = spool.kind; };
      }
    )
    { _module.args.spool.kind = lib.types.int; }
    (lib.mkRenamedOptionModule [ "hank" ] [ "skein" ])
    {
      _file = "selvage.nix";
      imports = [ (lib.mkRenamedOptionModule [ "selvage" ] [ "fringe" ]) ];
    }
    (lib.mkRenamedOptionModule [ "fringe" ] [ "braid" ])
    {
      _file = "tassel.nix";
      selvage = "soutache";
      hank = 5;
    }
  ];
in
{
  argumentTypedRename = {
    inherit (ev.config) braid skein;
  };
}
