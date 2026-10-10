# `module-reads-its-engine-option-records` — den-hoag-a67l3, den-hoag-pm14k. A loom's module reads its
# own `options._module.<k>` records, the four nixpkgs' `internalModule` declares: their types
# (`unspecified` and `nullOr optionType` among them), whether each is defined, and the values of
# `check`, `freeformType` (two `attrsOf` freeform definitions, merged) and `specialArgs`; an untyped
# option's record states `unspecified`; a gen `submodule` child reads its own. Each must equal the same
# construction over nixpkgs' `evalModules`, where gen-merge's module aborted on `attribute '_module'
# missing` and the untyped record on `attribute 'type' missing`. `args` is compared on the names the
# modules set (den-hoag-d2o0g).

{
  asserts,
  genMerge,
  lib,
}:
let
  loom =
    L: T: sub: extra:
    [
      {
        _file = "warp";
        options.warp = L.mkOption { };
        config.warp = "w";
      }
      (
        { options, ... }:
        {
          _file = "view";
          options.view = L.mkOption { };
          config.view = {
            types = builtins.mapAttrs (_: r: r.type.name) options._module;
            defined = builtins.mapAttrs (_: r: r.isDefined) options._module;
            elem = options._module.freeformType.type.nestedTypes.elemType.name;
            untyped = options.warp.type.name;
            argNames = builtins.attrNames options._module.args.value;
            inherit (options._module.check) value;
            freeform = options._module.freeformType.value.name;
            freeformElem = options._module.freeformType.value.nestedTypes.elemType.name;
            shuttle = options._module.specialArgs.value.shuttle or null;
          };
        }
      )
      {
        _file = "bobbin";
        options.bobbin = L.mkOption {
          type = sub [
            (
              { options, ... }:
              {
                options.seen = L.mkOption { };
                config.seen = options._module.specialArgs.type.name;
              }
            )
          ];
          default = { };
        };
      }
      {
        _file = "ff1";
        config._module.freeformType = T.attrsOf T.int;
      }
      {
        _file = "ff2";
        config._module.freeformType = T.attrsOf T.int;
      }
      {
        _file = "loose";
        config.loose = 3;
        config._module.args.thread = 1;
      }
    ]
    ++ extra;
  read =
    c:
    c.view
    // {
      child = c.bobbin.seen;
      inherit (c) loose;
    };
  gen =
    args:
    read
      ((r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules) (
        args // { modules = loom genMerge genMerge.types genMerge.types.submodule [ ]; }
      )).config;
  ref =
    args:
    read
      (lib.evalModules (
        args // { modules = loom lib lib.types (mods: lib.types.submoduleWith { modules = mods; }) [ ]; }
      )).config;
  caller.specialArgs.shuttle = "S";
in
{
  construct = [ "module-reads-its-engine-option-records-as-nixpkgs-does" ];
  check = asserts (
    (ref caller).types == {
      args = "lazyAttrsOf";
      check = "bool";
      freeformType = "nullOr";
      specialArgs = "unspecified";
    }
    && (ref caller).untyped == "unspecified"
    && (ref caller).child == "unspecified"
    && (ref caller).freeform == "attrsOf"
    && (ref caller).loose == 3
    && gen caller == removeAttrs (ref caller) [ "argNames" ] // { argNames = (gen caller).argNames; }
    &&
      builtins.filter (n: n != "extendModules" && n != "moduleType") (ref caller).argNames == (gen caller)
      .argNames
  );
}
