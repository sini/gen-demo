# `redeclared-foreign-submodule-reads-its-definition-in-place` — den-hoag-coek8. A `spool` option of a nixpkgs `submodule`
# is declared in `reel.nix` over a module stating `yarn = [ "reel" ]`, and redeclared in `bobbin.nix` over one stating
# `yarn = [ "bobbin" ]`. `wind.nix` defines it by a function module (`yarn = [ "wind" ]`) and `tie.nix` by an attrset
# (`yarn = [ "tie" ]`). The same loom states `spools`, the element of a redeclared `attrsOf`, the engine's own container
# family, and `skein`, whose function definition imports a module of its own. Each list must equal the same loom over
# nixpkgs' `evalModules`, which reads `wind` first. gen-merge located each declaration's module set twice, once in the
# declaration fold and again at the option's root, and read `wind` after both declarations' modules.
{
  asserts,
  genMerge,
  lib,
}:
let
  L = lib;
  T = L.types;
  yarn = {
    options.yarn = L.mkOption {
      type = T.listOf T.str;
      default = [ ];
    };
  };
  reel = {
    _file = "reel.nix";
    imports = [ yarn ];
    yarn = [ "reel" ];
  };
  bobbin = {
    _file = "bobbin.nix";
    yarn = [ "bobbin" ];
  };
  loom = C: [
    {
      _file = "reel.nix";
      options.spool = L.mkOption { type = T.submodule reel; };
      options.spools = L.mkOption { type = C.attrsOf (T.submodule reel); };
      options.skein = L.mkOption { type = T.submodule reel; };
    }
    {
      _file = "bobbin.nix";
      options.spool = L.mkOption { type = T.submodule bobbin; };
      options.spools = L.mkOption { type = C.attrsOf (T.submodule bobbin); };
      options.skein = L.mkOption { type = T.submodule bobbin; };
    }
    {
      _file = "wind.nix";
      spool = { ... }: { yarn = [ "wind" ]; };
      spools.s = { ... }: { yarn = [ "wind" ]; };
      skein =
        { ... }:
        {
          imports = [
            {
              _file = "knot.nix";
              yarn = [ "knot" ];
            }
          ];
          yarn = [ "wind" ];
        };
    }
    {
      _file = "tie.nix";
      spool.yarn = [ "tie" ];
      spools.s.yarn = [ "tie" ];
      skein.yarn = [ "tie" ];
    }
  ];
  read = ev: {
    spool = ev.config.spool.yarn;
    spools = ev.config.spools.s.yarn;
    skein = ev.config.skein.yarn;
  };
  gen = read (genMerge.evalModuleTree { } (loom genMerge.types));
  ref = read (lib.evalModules { modules = loom lib.types; });
in
{
  construct = [ "a-redeclared-nixpkgs-submodule-reads-a-function-definition-where-nixpkgs-does" ];
  check = asserts (
    ref == {
      spool = [
        "wind"
        "bobbin"
        "reel"
        "tie"
      ];
      spools = [
        "wind"
        "bobbin"
        "reel"
        "tie"
      ];
      skein = [
        "knot"
        "wind"
        "bobbin"
        "reel"
        "tie"
      ];
    }
    && gen == ref
  );
}
