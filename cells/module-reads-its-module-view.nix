# `module-reads-its-module-view` — C154, den-hoag-eoka4. A loom's module reads `config._module`: the
# four keys nixpkgs' `internalModule` declares, whether or not any module sets `_module.args`; its
# `check`, `false` where the caller passed `check = false`; its `freeformType`, `null` and then the
# resolved type; its `specialArgs`, the caller's `shuttle`, mapped by a re-declaration's `apply`; and a
# gen `submodule` child reads its own `specialArgs`, not its parent's. Each must equal the same
# construction over nixpkgs' `evalModules`, where gen-merge's module aborted on `attribute '_module'
# missing` (or on `check`, `freeformType`, `specialArgs` missing beside `args`) and refused the
# `apply` by name.
{
  asserts,
  genMerge,
  lib,
}:
let
  loom =
    L: ty: extra:
    [
      { options.warp = L.mkOption { default = "w"; }; }
      (
        { config, ... }:
        {
          options.view = L.mkOption { };
          config.view = {
            keys = builtins.attrNames config._module;
            inherit (config._module) check;
            freeform = if config._module.freeformType == null then null else config._module.freeformType.name;
            shuttle = if config._module.specialArgs ? shuttle then config._module.specialArgs.shuttle else null;
          };
        }
      )
      {
        options.bobbin = L.mkOption {
          type = ty [
            (
              { config, ... }:
              {
                options.seen = L.mkOption { };
                config.seen = config._module.specialArgs;
              }
            )
          ];
          default = { };
        };
      }
    ]
    ++ extra;
  read = c: c.view // { child = c.bobbin.seen; };
  gen =
    args: extra:
    read
      (genMerge.evalModuleTree (
        args // { modules = loom genMerge genMerge.types.submodule (extra genMerge genMerge.types); }
      )).config;
  ref =
    args: extra:
    read
      (lib.evalModules (
        args
        // {
          modules = loom lib (mods: lib.types.submoduleWith { modules = mods; }) (extra lib lib.types);
        }
      )).config;
  none = _: _: [ ];
  freeform = _: T: [ { config._module.freeformType = T.lazyAttrsOf T.raw; } ];
  applied = L: _: [
    { options._module.specialArgs = L.mkOption { apply = s: s // { shuttle = "applied"; }; }; }
  ];
  caller = {
    specialArgs.shuttle = "S";
  };
in
{
  construct = [ "C154" ];
  check = asserts (
    ref { } none == {
      keys = [
        "args"
        "check"
        "freeformType"
        "specialArgs"
      ];
      check = true;
      freeform = null;
      shuttle = null;
      child = { };
    }
    && gen { } none == ref { } none
    && gen { check = false; } none == ref { check = false; } none
    && gen { } freeform == ref { } freeform
    && gen caller none == ref caller none
    && (ref caller applied).shuttle == "applied"
    && gen caller applied == ref caller applied
  );
}
