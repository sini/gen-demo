# `a-foreign-relation-decides-beside-a-gen-leaf` — den-hoag-q5nmu. A nixpkgs `int` alias whose own
# `typeMerge` answers `int`, declared after gen's `int` for one option, used to be refused: the earlier
# gen leaf's relation does not know the alias by name, and its refusal ended the fold step, where
# nixpkgs asks only the later declaration and serves. The later declaration now decides, as nixpkgs
# lets it, and the join is met: a value either declaration's check rejects stays refused. The same
# holds through gen-merge's door on both records. Live controls: an even-only alias still refuses an
# odd value, and of two gen constructions of one name, a value one of them rejects stays refused.

{
  asserts,
  genMerge,
  lib,
}:

let
  np = lib.types;
  t = genMerge.types;
  door = genMerge.mkOptionType;
  alias =
    name: check:
    let
      self = lib.mkOptionType {
        inherit name check;
        merge = lib.mergeEqualOption;
        functor = np.defaultFunctor name // {
          type = _: self;
          payload = { };
          binOp = _: _: { };
        };
        typeMerge = f: if f.name == "int" || f.name == name then np.int else null;
      };
    in
    self;
  count = alias "count" builtins.isInt;
  even = alias "even" (v: builtins.isInt v && lib.mod v 2 == 0);
  read =
    types: v:
    (genMerge.evalModuleTree { } (
      builtins.genList (i: {
        _file = "/demo/rig${toString i}.nix";
        options.rig = genMerge.mkOption { type = builtins.elemAt types i; };
      }) (builtins.length types)
      ++ [ { rig = v; } ]
    )).config.rig;
  decides = e: (builtins.tryEval (builtins.deepSeq e true)).success;
  lt10 = v: builtins.isInt v && v < 10;
in
{
  construct = [ "a-later-foreign-relation-decides" ];
  check = asserts (
    # the later foreign alias decides, and serves what both declarations admit
    read [ t.int count ] 3 == 3
    && read [ t.int even ] 4 == 4
    && read [ (door np.int) (door even) ] 4 == 4
    && read [ t.int (door even) ] 4 == 4
    # the join is met: a value the alias's own check rejects stays refused
    && !(decides (read [ t.int even ] 3))
    && !(decides (read [ (door np.int) (door even) ] 3))
    # two gen constructions of one name: a value one of them rejects stays refused
    && !(decides (
      read [
        (t.mkOptionType {
          name = "int";
          check = lt10;
        })
        t.int
      ] 50
    ))
  );
}
