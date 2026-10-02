# `foreign-submodule-consumer-refuses` — C126, den-hoag-threadedforeign-substsubmodules-abort-srpix.
# A foreign record outside the six whose `substSubModules` CONSUMES its argument as modules is
# rebuilt through gen-merge's threaded channel and refused catchably, where it aborted uncatchably
# (`expected a list but found a set`): nixpkgs' `attrTag` given a gen `submodule` element, and a
# payload-null `mkOptionType` copy of a nixpkgs freeform `submodule` over that element. A copy whose
# `substSubModules` and `getSubModules` are both null is valid nixpkgs, and is refused rather than
# aborting with `not a function but null`. nixpkgs' `attrsWith` with a non-default `placeholder`, a
# container outside the six that FORWARDS the module list, holds the same element and serves, so a
# channel refusing everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
{
  construct = [ "C126" ];
  check = asserts (
    let
      read =
        type: v:
        (genMerge.evalModuleTree {
          modules = [
            { options.seam = genMerge.mkOption { inherit type; }; }
            { seam = v; }
          ];
        }).config.seam;
      refused = type: v: !(builtins.tryEval (builtins.deepSeq (read type v) null)).success;
      bolt = genMerge.types.submodule {
        options.warp = genMerge.mkOption { type = genMerge.types.str; };
      };
      loom = lib.types.submodule { freeformType = lib.types.attrsOf bolt; };
      copy =
        extra:
        lib.mkOptionType (
          {
            name = "submodule";
            inherit (loom)
              check
              merge
              getSubOptions
              getSubModules
              substSubModules
              nestedTypes
              emptyValue
              description
              ;
          }
          // extra
        );
    in
    refused (
      lib.types.attrTag { a = lib.mkOption { type = lib.types.submodule { }; }; }
      // {
        nestedTypes.elemType = bolt;
      }
    ) { a = { }; }
    && refused (copy { }) { k.warp = "sateen"; }
    && refused (copy {
      getSubModules = null;
      substSubModules = null;
    }) { k.warp = "sateen"; }
    &&
      (read (lib.types.attrsWith {
        elemType = bolt;
        placeholder = "bolt";
      }) { k.warp = "sateen"; }).k.warp == "sateen"
  );
}
