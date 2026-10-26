# `a-borrowed-import-fold-is-not-the-records-own` — a-records-admits-is-refused-outside-at-every-door, den-hoag-mvevv
# (ADR-0025 item 1). A `//` copy of a record `mkOptionType` imported, taking ANOTHER import's checked fold (a gen
# `mkOptionType` record's, or nixpkgs' `int` through the door), as that import completed it or rebuilt without its
# completion, keeps its own `check` and `admits` beside a fold that checks someone else's. gen-merge's engine refuses a
# definition outside the copy's own domain, raw and through each door, at the option and as a `listOf` / `attrsOf`
# element, as nixpkgs' `evalModules` refuses it, and serves an in-domain one. gen-merge used to trust an import's checked
# fold by its presence and serve the outside value silently. The intact import is the control.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  even = v: builtins.isInt v && lib.mod v 2 == 0;
  read =
    engine: type: v:
    let
      mods = [
        { options.tally = (if engine == "gen" then genMerge else lib).mkOption { inherit type; }; }
        { tally = v; }
      ];
    in
    if engine == "gen" then
      (genMerge.evalModuleTree { } mods).config.tally
    else
      (lib.evalModules { modules = mods; }).config.tally;
  attempt =
    engine: type: v:
    builtins.tryEval (builtins.deepSeq (read engine type v) (read engine type v));
  refused =
    engine: type: v:
    !(attempt engine type v).success;
  served =
    engine: type: v:
    attempt engine type v == {
      success = true;
      value = v;
    };
  evenT = genMerge.mkOptionType {
    name = "evenT";
    check = even;
  };
  anyT = genMerge.mkOptionType {
    name = "anyT";
    check = _: true;
  };
  evenRecord = gt.defineType {
    name = "evenT";
    admits = even;
  };
  intFold = (genMerge.mkOptionType lib.types.int).mergeDefs;
  # the borrowed fold rebuilt without the completion its own import's door gave it
  rebuilt = fold: builtins.removeAttrs fold [ "completed" ];
  copies = [
    (evenT // { inherit (anyT) mergeDefs; })
    (evenRecord // { mergeDefs = intFold; })
    (evenT // { mergeDefs = rebuilt anyT.mergeDefs; })
    (evenRecord // { mergeDefs = rebuilt intFold; })
  ];
  doors = [
    (t: t)
    gt.defineType
    genMerge.mkOptionType
    gt.mkOptionType
  ];
  positions = [
    {
      w = t: t;
      v = x: x;
    }
    {
      w = gt.listOf;
      v = x: [ x ];
    }
    {
      w = gt.attrsOf;
      v = x: { till = x; };
    }
  ];
  holds =
    t:
    lib.all (
      p: refused "gen" (p.w t) (p.v 3) && served "gen" (p.w t) (p.v 4) && refused "np" (p.w t) (p.v 3)
    ) positions;
in
{
  construct = [ "a-records-admits-is-refused-outside-at-every-door" ];
  check = asserts (lib.all (door: lib.all (c: holds (door c)) copies) doors && holds evenT);
}
