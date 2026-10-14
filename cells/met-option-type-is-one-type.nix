# `met-option-type-is-one-type` — a-met-option-type-is-one-type, den-hoag-hnd82 (ADR-0034). An option declared twice,
# once with nixpkgs' `addCheck` over gen's `int` and once with `int`, has a MET type: the join restricted by the check
# it does not carry. That type is a gen-merge construction, `gen-merge.meet`, minted over its join and its owed
# operands, so:
#   1. the met type is one type with itself, and two declarations of the same meet, built twice over one operand
#      value, are one type;
#   2. a different meet (an `odd` check where the other owes `even`) is not one type: the two owed checks are sealed
#      functions, so the comparison is refused by name rather than decided;
#   3. the meet is still enforced: 2 is served, 3 (rejected by the owed check) and a string are refused.
# Before the mint, the met type carried its join's mark over a different check, and every reading in 1 was refused.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  value =
    e:
    let
      r = builtins.tryEval (builtins.deepSeq e e);
    in
    if r.success then r.value else "REFUSED";
  decl =
    types:
    (genMerge.evalModuleTree { } (
      map (type: { options.spool = genMerge.mkOption { inherit type; }; }) types
    )).options.spool.type;
  read =
    types: v:
    value
      (genMerge.evalModuleTree { } (
        map (type: { options.spool = genMerge.mkOption { inherit type; }; }) types ++ [ { spool = v; } ]
      )).config.spool;
  # one operand value, shared by both constructions
  evenInt = lib.types.addCheck gt.int (v: lib.mod v 2 == 0);
  oddInt = lib.types.addCheck gt.int (v: lib.mod v 2 == 1);
  met = decl [
    evenInt
    gt.int
  ];
in
{
  construct = [ "a-met-option-type-is-one-type" ];
  check = asserts (
    # 1
    met ? __meetJoin
    && value (gt.typeEq met met) == true
    &&
      value (
        gt.typeEq met (decl [
          evenInt
          gt.int
        ])
      ) == true
    # 2
    &&
      value (
        gt.typeEq met (decl [
          oddInt
          gt.int
        ])
      ) == "REFUSED"
    # 3
    &&
      read [
        evenInt
        gt.int
      ] 2 == 2
    &&
      read [
        evenInt
        gt.int
      ] 3 == "REFUSED"
    &&
      read [
        evenInt
        gt.int
      ] "x" == "REFUSED"
  );
}
