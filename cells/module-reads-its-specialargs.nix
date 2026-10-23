# `module-reads-its-specialargs` — den-hoag-specialargs-module-arg-b01wy. A loom's module reads the module
# argument `specialArgs`: as a formal while folding values, as a formal while choosing its `imports`, and from
# the whole argument set (`args@{ ... }`); a `_module.args.specialArgs` definition does not reach it, a caller's
# own `specialArgs.specialArgs` does, and a gen `submodule` child reads its own type's arguments, not its
# parent's. Each must equal the same construction over nixpkgs' `evalModules`, where gen-merge refused the
# formal by name (`module argument `specialArgs' is not defined`) and aborted on the argument set's read.
{
  asserts,
  genMerge,
  lib,
}:
let
  loom =
    L: sub: extra:
    [
      {
        options.weft = L.mkOption { };
        options.pick = L.mkOption { };
        options.whole = L.mkOption { };
        options.bobbin = L.mkOption {
          type = sub [
            ({ specialArgs, ... }: {
              options.seen = L.mkOption { };
              config.seen = builtins.attrNames specialArgs;
            })
          ] { reed = "R"; };
          default = { };
        };
      }
      ({ specialArgs, ... }: { config.weft = specialArgs.shuttle or null; })
      ({ specialArgs, ... }: {
        imports =
          if specialArgs ? shuttle then [ { config.pick = "picked"; } ] else [ { config.pick = "none"; } ];
      })
      (
        args@{ ... }:
        {
          config.whole = builtins.attrNames args.specialArgs;
        }
      )
    ]
    ++ extra;
  read = c: {
    inherit (c) weft pick whole;
    child = c.bobbin.seen;
  };
  gen =
    args: extra:
    read
      ((r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules) (
        args // { modules = loom genMerge (mods: a: (genMerge.types.submodule mods).withArgs a) extra; }
      )).config;
  ref =
    args: extra:
    read
      (lib.evalModules (
        args
        // {
          modules = loom lib (
            mods: a:
            lib.types.submoduleWith {
              modules = mods;
              specialArgs = a;
            }
          ) extra;
        }
      )).config;
  none = [ ];
  planted = [
    {
      config._module.args.specialArgs = {
        heddle = "H";
      };
    }
  ];
  caller = {
    specialArgs.shuttle = "S";
  };
  own = {
    specialArgs = {
      shuttle = "S";
      specialArgs = {
        warp = "W";
      };
    };
  };
in
{
  construct = [ "module-reads-its-specialargs-as-nixpkgs-does" ];
  check = asserts (
    ref caller none == {
      weft = "S";
      pick = "picked";
      whole = [ "shuttle" ];
      child = [ "reed" ];
    }
    && gen caller none == ref caller none
    && gen { } none == ref { } none
    && gen caller planted == ref caller planted
    && gen own none == ref own none
    && (ref own none).whole == [ "warp" ]
  );
}
