# `check-rewritten-submodule-below-a-union` — den-hoag-n8ssa (ADR-0039, the serve half; ADR-0025 item 1).
# A gen `submodule` whose check is rewritten, by nixpkgs `addCheck` and by the override written out,
# is placed in a gen union, raw and re-completed through `types.defineType` and `mkOptionType`.
# The check is enforced at every door: `{ a = 2; }`, which it admits, is served, and `{ a = 1; }`,
# which it rejects, is refused by name. Through `mkOptionType` the admitted value used to be refused
# ("its called `mergeDefs' does not evaluate the nested tree"): the door rebuilt the record with its
# called fold and dropped the threaded sibling a union folds a nesting member by. The union over a gen
# `listOf` is the one the carried check is enforced in by the engine rather than by the either member
# test, so a door that dropped the carried check is seen there.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  read =
    type: v:
    (genMerge.evalModuleTree { } [
      { options.bobbin = genMerge.mkOption { inherit type; }; }
      { bobbin = v; }
    ]).config.bobbin;
  refused = v: !(builtins.tryEval (builtins.deepSeq v null)).success;
  plain = t.submodule { options.a = genMerge.mkOption { type = t.int; }; };
  notOne = v: v.a != 1;
  overrides = [
    (lib.types.addCheck plain notOne)
    (plain // { check = v: plain.check v && notOne v; })
  ];
  doors = [
    (d: d)
    t.defineType
    genMerge.mkOptionType
  ];
  unions = [
    {
      u = d: t.either d t.str;
      w = v: v;
    }
    {
      u = d: t.nullOr (t.either d t.str);
      w = v: v;
    }
    {
      u = d: t.attrsOf (t.either d t.str);
      w = v: { k = v; };
    }
    {
      u = d: t.either (t.listOf d) t.str;
      w = v: [ v ];
    }
  ];
  enforced =
    d:
    lib.all (
      s: read (s.u d) (s.w { a = 2; }) == s.w { a = 2; } && refused (read (s.u d) (s.w { a = 1; }))
    ) unions;
in
{
  construct = [ "a-check-rewritten-submodule-is-enforced-below-a-union" ];
  check = asserts (lib.all (door: lib.all (o: enforced (door o)) overrides) doors);
}
