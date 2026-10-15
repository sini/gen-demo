# `foreign-option-value-meta` — den-hoag-xroc7. An option declared with nixpkgs' own types answers nixpkgs'
# v2-merge metadata, `valueMeta`, on gen-merge's evaluated record: an `attrsOf str` names its definitions'
# attributes under `attrs` and carries its type under `_internal`, and a `str`, whose merge states no `v2`,
# answers `{ }`, each equal to what nixpkgs' own `lib.evalModules` answers for the same modules, where
# gen-merge refused the read by name. An option of gen-merge's own type still refuses it, catchably, so a
# record serving every read cannot pass.

{
  asserts,
  genMerge,
  lib,
}:

let
  modules = [
    {
      options.warp = lib.mkOption { type = lib.types.attrsOf lib.types.str; };
      options.weft = lib.mkOption { type = lib.types.str; };
    }
    {
      config.warp = {
        selvage = "s";
        bias = "b";
      };
      config.weft = "w";
    }
  ];
  read = ev: {
    names = builtins.attrNames ev.options.warp.valueMeta.attrs;
    typed = ev.options.warp.valueMeta._internal.type == ev.options.warp.type;
    leaf = ev.options.weft.valueMeta;
  };
  native = read (genMerge.evalModuleTree { } modules);
  nixpkgs = read (lib.evalModules { inherit modules; });
  expected = {
    names = [
      "bias"
      "selvage"
    ];
    typed = true;
    leaf = { };
  };
  own =
    (genMerge.evalModuleTree { } [
      { options.pleat = genMerge.mkOption { type = genMerge.types.attrsOf genMerge.types.str; }; }
      { config.pleat.tuck = "t"; }
    ]).options.pleat;
in

{
  construct = [ "a-foreign-option-answers-its-v2-merge-metadata" ];
  check = asserts (
    native == expected
    && nixpkgs == expected
    && !(builtins.tryEval (builtins.deepSeq own.valueMeta null)).success
    && own.value == { tuck = "t"; }
  );
}
