# `gen-door-mounted-as-its-rebuild` — C164, den-hoag-6yfat. A type built through gen-merge's own
# `mkOptionType` door whose author stated its fold apart from its rebuild is mounted at the option
# root as nixpkgs' `fixupOptionType` mounts the same exported record: as its `substSubModules`
# rebuild over the declaration's module set, whose merge is the one served. `treadle`, whose own
# merge answers a constant and whose rebuild is nixpkgs' `submodule` over `warp`, reads what nixpkgs'
# own `lib.evalModules` reads, alone, under gen's `attrsOf`, and as an option inside a submodule,
# where gen-merge served the constant. A `treadle` whose fold is its rebuild's reads what it read
# before. The record's own `check` rides on the rebuild, so a `treadle` demanding `weft` refuses a
# definition without it under gen's `attrsOf`, where nixpkgs' fix-up erases the check. A `treadle`
# stating `verify` is never mounted while it states it, and a copy that drops the `verify` reads what
# nixpkgs reads, alone and under gen's `attrsOf`, where gen-merge served the constant. The control
# is `treadle` with a null rebuild: it states a module set it cannot be mounted over, so it is
# refused catchably, never served silently.
{
  asserts,
  genMerge,
  lib,
}:
{
  construct = [ "gen-door-record-is-mounted-as-its-rebuild" ];
  check = asserts (
    let
      seam = mkOption: type: v: [
        { options.seam = mkOption { inherit type; }; }
        { seam = v; }
      ];
      read = type: v: (genMerge.evalModuleTree { } (seam genMerge.mkOption type v)).config.seam;
      nixpkgsRead = type: v: (lib.evalModules { modules = seam lib.mkOption type v; }).config.seam;
      json = builtins.toJSON;
      same = type: v: json (read type v) == json (nixpkgsRead type v);
      refused = type: v: !(builtins.tryEval (builtins.deepSeq (read type v) null)).success;
      loom = lib.types.submodule {
        options.warp = lib.mkOption {
          type = lib.types.str;
          default = "plain";
        };
      };
      treadle =
        extra:
        let
          self = genMerge.mkOptionType (
            {
              name = "treadle";
              check = builtins.isAttrs;
              merge = _: _: "selvedge";
              getSubOptions = loom.getSubOptions;
              getSubModules = [ ];
              substSubModules = _: loom;
              functor = lib.types.defaultFunctor "treadle" // {
                binOp = a: _: a;
                payload = { };
                type = _: self;
              };
            }
            // extra
          );
        in
        self;
      unverified = builtins.removeAttrs (treadle {
        verify = v: if (v.warp or "") == "sateen" then null else "warp must be sateen";
      }) [ "verify" ];
    in
    same (treadle { }) { warp = "sateen"; }
    && same (genMerge.types.attrsOf (treadle { })) { k.warp = "sateen"; }
    &&
      json (
        read (genMerge.types.submodule { options.t = genMerge.mkOption { type = treadle { }; }; }) {
          t.warp = "sateen";
        }
      ) == json (
        nixpkgsRead (lib.types.submodule { options.t = lib.mkOption { type = treadle { }; }; }) {
          t.warp = "sateen";
        }
      )
    && same (treadle { merge = loc: defs: loom.merge loc defs; }) { warp = "sateen"; }
    &&
      refused
        (genMerge.types.attrsOf (treadle {
          check = v: builtins.isAttrs v && v ? weft;
        }))
        {
          k.warp = "sateen";
        }
    && same unverified { warp = "sateen"; }
    && same (genMerge.types.attrsOf unverified) { k.warp = "sateen"; }
    && refused (treadle { substSubModules = _: null; }) { warp = "sateen"; }
  );
}
