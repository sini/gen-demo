# `freeform-merge-locates-its-submodules` — den-hoag-htwjd. A loom whose freeform type is defined by
# three modules, each an `attrsOf` submodule declaring one sub-option and two declaring the same one,
# reads the merged freeform type's sub-option `declarations`: each names the file that defined it, in
# nixpkgs' module order, where gen-merge read `<unknown-file>`. nixpkgs' `optionType.merge` rebuilds a
# type of two or more definitions over each definition's located module set; one definition is its own
# type and stays unlocated on both engines. Each must equal the same construction over nixpkgs'
# `evalModules`.

{
  asserts,
  genMerge,
  lib,
}:
let
  free =
    L: T: sub: file: opts: {
      _file = file;
      config._module.freeformType = T.attrsOf (sub { options = opts; });
    };
  loom = L: T: sub: [
    (free L T sub "warp" { shed = L.mkOption { }; })
    (free L T sub "weft" {
      pick = L.mkOption { };
      shed = L.mkOption { };
    })
    (free L T sub "selvage" { reed = L.mkOption { }; })
  ];
  read =
    L: T: sub: ev:
    let
      subOpts = mods: (ev mods).options._module.freeformType.value.getSubOptions [ ];
      merged = subOpts (loom L T sub);
      one = subOpts [ (free L T sub "warp" { shed = L.mkOption { }; }) ];
    in
    {
      pick = merged.pick.declarations;
      shed = merged.shed.declarations;
      reed = merged.reed.declarations;
      one = one.shed.declarations;
    };
  gen = read genMerge genMerge.types genMerge.types.submodule (genMerge.evalModuleTree { });
  ref = read lib lib.types (m: lib.types.submoduleWith { modules = [ m ]; }) (
    mods: lib.evalModules { modules = mods; }
  );
in
{
  construct = [ "a-merged-freeform-type-locates-its-submodules-as-nixpkgs-does" ];
  check = asserts (
    ref.pick == [ "weft" ]
    && ref.reed == [ "selvage" ]
    && builtins.sort builtins.lessThan ref.shed == [
      "warp"
      "weft"
    ]
    && ref.one == [ "<unknown-file>" ]
    && gen == ref
  );
}
