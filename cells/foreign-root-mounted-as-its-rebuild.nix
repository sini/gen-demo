# `foreign-root-mounted-as-its-rebuild` — C152, den-hoag-gijly and den-hoag-2lmky. A foreign option
# type that states a module set (`getSubModules`) is mounted at the option root as nixpkgs'
# `fixupOptionType` mounts it: as its `substSubModules` rebuild over the declaration's module set,
# whose merge is the one served, judged before any read of the record. `heddle`, a hand-written
# `mkOptionType` whose own merge answers a constant and whose rebuild is nixpkgs' `submodule` over
# `warp`, reads what nixpkgs' own `lib.evalModules` reads, alone and under nixpkgs' `uniq`, where
# gen-merge served the constant. nixpkgs' own `submodule` and `attrsOf submodule` roots read what
# they read before. `shuttle`, a payload-null `mkOptionType` copy of a nixpkgs `submodule` whose
# module set only sets `warp`, given a definition that declares `warp`, reads what nixpkgs reads,
# where gen-merge refused it by reading the copy's `nestedTypes`. The control is `heddle` with no
# rebuild (`mkOptionType`'s default `m: null`): it states a module set it cannot be mounted over, so
# it is refused catchably, never served silently.
{
  asserts,
  genMerge,
  lib,
}:
{
  construct = [ "C152" ];
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
      loom = lib.types.submodule {
        options.warp = lib.mkOption {
          type = lib.types.str;
          default = "plain";
        };
      };
      heddle =
        extra:
        lib.mkOptionType (
          {
            name = "heddle";
            check = builtins.isAttrs;
            merge = _: _: "selvedge";
            getSubModules = [ ];
            substSubModules = _: loom;
          }
          // extra
        );
      sets = lib.types.submodule { config.warp = "sateen"; };
      shuttle = lib.mkOptionType {
        name = "submodule";
        inherit (sets)
          check
          merge
          getSubOptions
          getSubModules
          substSubModules
          nestedTypes
          emptyValue
          description
          ;
      };
    in
    same (heddle { }) { warp = "sateen"; }
    && same (lib.types.uniq (heddle { })) { }
    && same loom { warp = "sateen"; }
    && same (lib.types.attrsOf loom) { k.warp = "sateen"; }
    && same shuttle (_: {
      options.warp = lib.mkOption { type = lib.types.str; };
    })
    && refused (heddle { substSubModules = _: null; }) { warp = "sateen"; }
  );
}
