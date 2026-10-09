# ── NIXPKGS' RENAMED-OPTION MODULES COMPOSE ON GEN-MERGE (den-hoag-9oc7y) ──────────────────────
# Stock `lib.mkRenamedOptionModule` and `lib.mkAliasOptionModule`, each onto its own option, with one
# option defined through each alias. `doRename` declares the alias leaf with its target's `type`, so
# the leaf reads `options` while the declarations are folded; gen-merge's declaration guard resolves
# it in a staged pass against the declarations of the pass before, and serves nixpkgs' value.
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
      options.loops = lib.mkOption { type = lib.types.int; };
    }
    (lib.mkRenamedOptionModule [ "plait" ] [ "braid" ])
    (lib.mkAliasOptionModule [ "turns" ] [ "loops" ])
    {
      _file = "tassel.nix";
      plait = "soutache";
      turns = 3;
    }
  ];
in
{
  renamedOptions = {
    inherit (ev.config) braid loops warnings;
  };
}
