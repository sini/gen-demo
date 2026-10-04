# `foreign-submodule-consumer-serves` — C126, den-hoag-threadedforeign-substsubmodules-abort-srpix
# and den-hoag-threadedforeign-parity-residue-0hew4. A foreign record outside the six whose
# `substSubModules` CONSUMES its argument as modules does not thread gen-merge's channel, and where
# it aborted uncatchably (`expected a list but found a set`) it now reads what nixpkgs' own
# `lib.evalModules` reads: at the option root it is mounted over its module set as nixpkgs'
# `fixupOptionType` mounts it. Two such records: nixpkgs' `attrTag` given a gen `submodule` element,
# and a payload-null `mkOptionType` copy of a nixpkgs freeform `submodule` over that element. A copy
# whose `substSubModules` and `getSubModules` are both null is valid nixpkgs but states no module set
# to be mounted over, and is refused rather than aborting with `not a function but null`. nixpkgs'
# `attrsWith` with a non-default `placeholder`, a container outside the six that FORWARDS the
# module list, holds the same element and serves, so a channel refusing everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
{
  construct = [ "C126" ];
  check = asserts (
    let
      seam = type: v: [
        { options.seam = genMerge.mkOption { inherit type; }; }
        { seam = v; }
      ];
      read = type: v: (genMerge.evalModuleTree { } (seam type v)).config.seam;
      nixpkgsRead = type: v: (lib.evalModules { modules = seam type v; }).config.seam;
      same = type: v: builtins.toJSON (read type v) == builtins.toJSON (nixpkgsRead type v);
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
    same (
      lib.types.attrTag { a = lib.mkOption { type = lib.types.submodule { }; }; }
      // {
        nestedTypes.elemType = bolt;
      }
    ) { a = { }; }
    && same (copy { }) { k.warp = "sateen"; }
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
