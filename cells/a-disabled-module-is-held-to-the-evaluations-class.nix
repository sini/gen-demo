# `a-disabled-module-is-held-to-the-evaluations-class` — den-hoag-zchgl. A module named in
# `disabledModules` is still loaded, so it is still held to the evaluation's `class`, as nixpkgs'
# `checkModule` holds it. A caller's `specialArgs._class` is the `_class` argument a module reads, never
# the class it is held to: under `class = "nixos"` and a caller's `"darwin"`, a disabled nixos module is
# removed (both engines read `[ "kept" ]`) and a disabled darwin module is refused on both. The
# discriminator is the argument itself, read in the same cell: `_class` reads `"darwin"` on both engines,
# so the caller's class reached the evaluation. gen-merge held the module to the caller's class before.
{
  asserts,
  genMerge,
  lib,
}:
let
  decl = L: {
    options.warp = L.mkOption {
      type = L.types.listOf L.types.str;
      default = [ ];
    };
  };
  args = {
    class = "nixos";
    specialArgs._class = "darwin";
  };
  native = mods: (genMerge.evalModuleTree args ([ (decl genMerge) ] ++ mods)).config.warp;
  nixpkgs = mods: (lib.evalModules (args // { modules = [ (decl lib) ] ++ mods; })).config.warp;
  kept.warp = [ "kept" ];
  disabled = moduleClass: [
    {
      key = "weft";
      _class = moduleClass;
      warp = [ moduleClass ];
    }
    kept
    { disabledModules = [ { key = "weft"; } ]; }
  ];
  refuses = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
  reads = [ ({ _class, ... }: { warp = [ _class ]; }) ];
in
{
  construct = [ "a-disabled-module-is-held-to-the-evaluations-class" ];
  check = asserts (
    native (disabled "nixos") == [ "kept" ]
    && nixpkgs (disabled "nixos") == [ "kept" ]
    && refuses (native (disabled "darwin"))
    && refuses (nixpkgs (disabled "darwin"))
    && native reads == [ "darwin" ]
    && nixpkgs reads == [ "darwin" ]
  );
}
