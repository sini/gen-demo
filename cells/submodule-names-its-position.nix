# `submodule-names-its-position` — C143, den-hoag-fpxsd. A gen `submodule` (`bobbin`) whose module
# reads `name`, under gen `attrsOf`, is named as nixpkgs' `submoduleWith` names it: the position's
# name is an overridable `_module.args.name` definition, so a module's `mkForce` wins, a caller's
# `name` handed through `withArgs` outranks both, and the docs read `‹name›`. Each must equal the
# same construction over nixpkgs' `submoduleWith`, where gen-merge served the attribute name over
# the `mkForce`, refused the caller's `name` at `withArgs`, and read the docs' prefix step.
{
  asserts,
  genMerge,
  lib,
}:
let
  mods = mk: [
    (
      { name, ... }:
      {
        options.weft = mk {
          type = lib.types.str;
          default = name;
        };
      }
    )
  ];
  forced = mkForce: [ { _module.args.name = mkForce "forced"; } ];
  bobbin =
    extra: args:
    let
      t = genMerge.types.submodule (mods genMerge.mkOption ++ extra);
    in
    if args == { } then t else t.withArgs args;
  ref =
    extra: args:
    lib.types.submoduleWith {
      modules = mods lib.mkOption ++ extra;
      specialArgs = args;
      shorthandOnlyDefinesConfig = true;
    };
  warp =
    type:
    (genMerge.evalModuleTree {
      modules = [
        { options.seam = genMerge.mkOption { type = genMerge.types.attrsOf type; }; }
        { seam.warp = { }; }
      ];
    }).config.seam.warp.weft;
  mounted =
    type:
    (lib.evalModules {
      modules = [
        { options.seam = lib.mkOption { type = lib.types.attrsOf type; }; }
        { seam.warp = { }; }
      ];
    }).config.seam.warp.weft;
  caller = {
    name = "caller";
  };
  docs = type: (type.getSubOptions [ "seam" ]).weft.default;
in
{
  construct = [ "C143" ];
  check = asserts (
    mounted (ref [ ] { }) == "warp"
    && warp (bobbin [ ] { }) == mounted (ref [ ] { })
    && mounted (ref (forced lib.mkForce) { }) == "forced"
    && warp (bobbin (forced genMerge.mkForce) { }) == mounted (ref (forced lib.mkForce) { })
    && mounted (ref (forced lib.mkForce) caller) == "caller"
    && warp (bobbin (forced genMerge.mkForce) caller) == mounted (ref (forced lib.mkForce) caller)
    && docs (ref [ ] { }) == "‹name›"
    && docs (bobbin [ ] { }) == docs (ref [ ] { })
  );
}
