# `union-member-judged-whole` — den-hoag-e6m9d + den-hoag-c2z7q. A union takes a member only when the
# member takes the definitions WHOLE, as nixpkgs' `either` takes one only when its `merge.v2` reports
# no `headError`: in gen's evaluation (a `nullOr` around a gen `either`, first), and in nixpkgs'
# `lib.evalModules` around a gen `either` and a gen `nullOr` (gen's export answers `merge.v2`). Each
# set is covered pointwise by the first member and refused by it whole, so a red is gen taking it
# (and refusing inside) instead of the later member `all`.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  all = gt.mkOptionType {
    name = "all";
    check = _: true;
    merge = _: _: "all";
  };
  # gen's own evaluation
  own =
    type: vs:
    (genMerge.evalModuleTree { } (
      [ { options.seam = genMerge.mkOption { inherit type; }; } ] ++ map (v: { seam = v; }) vs
    )).config.seam;
  # nixpkgs' own evaluation, the gen type mounted inside nixpkgs' `either`
  mounted =
    type: vs:
    (lib.evalModules {
      modules = [ { options.seam = lib.mkOption { inherit type; }; } ] ++ map (v: { seam = v; }) vs;
    }).config.seam;
  refuses = e: !(builtins.tryEval (builtins.deepSeq e null)).success;
in
{
  construct = [ "a-union-member-is-judged-whole-in-both-engines" ];
  check = asserts (
    own (gt.either (gt.nullOr (gt.either gt.int gt.str)) all) [
      1
      "s"
    ] == "all"
    &&
      mounted (lib.types.either (gt.either gt.int gt.str) all) [
        1
        "s"
      ] == "all"
    &&
      mounted (lib.types.either (gt.nullOr gt.int) all) [
        null
        5
      ] == "all"
    # controls: a set the gen member takes whole is still its, in both engines
    &&
      own (gt.either (gt.nullOr (gt.either gt.int gt.str)) all) [
        1
        1
      ] == 1
    &&
      mounted (lib.types.either (gt.either gt.int gt.str) all) [
        1
        1
      ] == 1
    # control: the export's headError keeps the pointwise check, so a bad leaf is refused
    && refuses (mounted gt.int [ "s" ])
  );
}
