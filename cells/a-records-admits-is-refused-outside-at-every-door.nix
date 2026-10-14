# `a-records-admits-is-refused-outside-at-every-door` — den-hoag-gxybe. A record stating gen's `admits` and no
# `verify` is refused outside it wherever the fold gen's engine runs carries no witness of a guard of that `admits`:
# through `types.mkType`, `types.defineType`, `mkOptionType` and raw; as a `//` copy taking a fold of its own over a
# completed record, re-entered through a door; as a raw record spelling `_type`; and as a copy of gen's `attrs` taking a
# fold. Each serves its in-domain value. The `addCheck` twin is the control.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  even = v: builtins.isInt v && lib.mod v 2 == 0;
  fold = loc: defs: lib.mergeEqualOption loc defs;
  rec0 = {
    name = "evenT";
    admits = even;
  };
  read =
    type: v:
    (genMerge.evalModuleTree { } [
      { options.tally = genMerge.mkOption { inherit type; }; }
      { tally = v; }
    ]).config.tally;
  attempt = type: v: builtins.tryEval (builtins.deepSeq (read type v) (read type v));
  refused = type: v: !(attempt type v).success;
  served =
    type: v:
    (attempt type v) == {
      success = true;
      value = v;
    };
  both =
    good: bad: type:
    served type good && refused type bad;
  copy = gt.defineType rec0 // {
    mergeDefs = fold;
  };
  ints = [
    (gt.mkType rec0)
    (gt.defineType rec0)
    (genMerge.mkOptionType rec0)
    rec0
    (rec0 // { mergeDefs = fold; })
    copy
    (gt.defineType copy)
    (gt.mkType copy)
    (genMerge.mkOptionType copy)
    (rec0 // { _type = "option-type"; })
    (
      rec0
      // {
        _type = "option-type";
        mergeDefs = fold;
      }
    )
    (lib.types.addCheck lib.types.int even)
  ];
  attrsCopy = gt.attrs // {
    mergeDefs = fold;
  };
in
{
  construct = [ "a-records-admits-is-refused-outside-at-every-door" ];
  check = asserts (lib.all (both 4 3) ints && both { a = 1; } 1 attrsCopy);
}
