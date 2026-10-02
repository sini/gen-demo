# `foreign-consumer-mounted-at-root` — C144, den-hoag-threadedforeign-parity-residue-0hew4. A
# foreign record outside the six that declares a gen nesting element reaches gen-merge's threaded
# channel. Where its rebuild threads, at any depth, it serves nixpkgs' value: nixpkgs' `uniq` over
# `attrsOf bolt`, two containers in. Where its rebuild CONSUMES the handed list as its own modules
# (a payload-null `mkOptionType` copy of a nixpkgs freeform `submodule` over `bolt`), it does not
# thread, and at the option root it is mounted as nixpkgs' `fixupOptionType` mounts it, over the
# declaration's module set: the copy, and nixpkgs' `uniq` over the copy, each read what nixpkgs'
# own `lib.evalModules` reads. The control is that copy with a null `substSubModules` and
# `getSubModules`: it states no module set to be mounted over, so it is refused catchably, never
# served silently.
{
  asserts,
  genMerge,
  lib,
}:
{
  construct = [ "C144" ];
  check = asserts (
    let
      seam = type: v: [
        { options.seam = genMerge.mkOption { inherit type; }; }
        { seam = v; }
      ];
      read = type: v: (genMerge.evalModuleTree { modules = seam type v; }).config.seam;
      nixpkgsRead = type: v: (lib.evalModules { modules = seam type v; }).config.seam;
      same = type: v: builtins.toJSON (read type v) == builtins.toJSON (nixpkgsRead type v);
      refused = type: v: !(builtins.tryEval (builtins.deepSeq (read type v) null)).success;
      bolt = genMerge.types.submodule {
        options.warp = genMerge.mkOption {
          type = genMerge.types.str;
          default = "plain";
        };
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
    same (lib.types.uniq (lib.types.attrsOf bolt)) { k.warp = "sateen"; }
    && same (copy { }) {
      k.warp = "sateen";
      j = { };
    }
    && same (lib.types.uniq (copy { })) { k.warp = "sateen"; }
    && (read (copy { }) { j = { }; }).j.warp == "plain"
    && refused (copy {
      getSubModules = null;
      substSubModules = null;
    }) { k.warp = "sateen"; }
  );
}
