# `a-release-nullor-without-v2-below-a-submodule` — den-hoag-wsbgz. Whether nixpkgs' `nullOr` ships a v2 merge depends
# on the release: nixos-26.05's does not. Its stock `nullOr` (lib/types.nix at 26f4107e47e3, copied over this lib's
# `nullOr` functor, since `elemTypeFunctor` is not exported) is declared below a stock `submodule`, over a gen `int`
# copy whose `verify` rejects 7. gen's engine walks the element and refuses 7 by name, as it does over this release's
# v2 `nullOr`, and serves an accepted value.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  nullOr2605 =
    elemType:
    lib.mkOptionType rec {
      name = "nullOr";
      description = "null or ${
        t.optionDescriptionPhrase (class: class == "noun" || class == "conjunction") elemType
      }";
      descriptionClass = "conjunction";
      check = x: x == null || elemType.check x;
      merge =
        loc: defs:
        let
          nulls = builtins.filter (def: def.value == null) defs;
        in
        if nulls == [ ] then
          elemType.merge loc defs
        else if builtins.length nulls == builtins.length defs then
          null
        else
          throw "The option `${lib.showOption loc}` is defined both null and not null, in ${lib.options.showFiles (lib.options.getFiles defs)}.";
      emptyValue = {
        value = null;
      };
      getSubOptions = elemType.getSubOptions;
      getSubModules = elemType.getSubModules;
      substSubModules = m: nullOr2605 (elemType.substSubModules m);
      functor = (t.nullOr elemType).functor // {
        type = payload: nullOr2605 payload.elemType;
      };
      nestedTypes.elemType = elemType;
    };
  C = genMerge.types.int // {
    verify = v: if v == 7 then "rejected by the copy" else genMerge.types.int.verify v;
  };
  port =
    T: v:
    (genMerge.evalModuleTree { } [
      {
        options.service = lib.mkOption {
          type = t.submodule { options.port = lib.mkOption { type = T; }; };
        };
      }
      { config.service.port = v; }
    ]).config.service.port;
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
in
{
  construct = [ "a-release-nullor-without-v2-below-a-submodule-enforces-a-gen-copy" ];
  check = asserts (
    !((nullOr2605 C).merge ? v2)
    && refused (port (nullOr2605 C) 7)
    && port (nullOr2605 C) 3 == 3
    && port (nullOr2605 C) null == null
    && refused (port (t.nullOr C) 7)
  );
}
