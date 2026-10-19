# `typedef-custom-merge` — den-hoag-6orb8 U3. A `typedef` states its own fold, options first:
# `typedef { merge = m; } "tally" isInt`, `m` the foreign protocol's `loc: defs: value`.
#   1. two definitions of a `tally` fold to their sum, in gen-merge's evaluation and mounted in nixpkgs'
#      own `lib.evalModules`, as `mkOptionType` with the same `merge` does (the control);
#   2. each definition is checked before the fold and the result after: a string definition is refused
#      before the sum sees it, and a `merge` returning a string is refused, in both engines;
#   3. `merge` is a component of the type: one binding declared twice folds, two separately written
#      merges are refused, and two typedefs over one registered `merge` term fold;
#   4. the positional `typedef "tally" isInt` and an unknown option are refused.
# Each refusal stands beside its passing twin, so a door refusing everything cannot pass.
{
  asserts,
  genAlgebra,
  genMerge,
  inputs,
  lib,
}:
let
  T = genMerge.types;
  mint = inputs.gen.lib.substrate.identity.hashIdentity;
  read =
    engine: types: vs:
    let
      mods =
        map (type: {
          options.tally = (if engine == "gen" then genMerge else lib).mkOption { inherit type; };
        }) types
        ++ map (v: { tally = v; }) vs;
      r =
        if engine == "gen" then
          (genMerge.evalModuleTree { } mods).config.tally
        else
          (lib.evalModules { modules = mods; }).config.tally;
      t = builtins.tryEval (builtins.deepSeq r r);
    in
    if t.success then t.value else "REFUSED";
  isInt = v: builtins.isInt v;
  sum = _loc: defs: builtins.foldl' (a: d: a + d.value) 0 defs;
  sum' = _loc: defs: builtins.foldl' (a: d: a + d.value) 0 defs;
  tallies = {
    revision = "r1";
    members.sum =
      _a: _loc: defs:
      builtins.foldl' (a: d: a + d.value) 0 defs;
  };
  sumOf = genAlgebra.mkIntensional mint tallies "sum";
  tally = m: T.typedef { merge = m; } "tally" isInt;
  built = e: (builtins.tryEval (builtins.seq e true)).success;
in
{
  construct = [ "typedef-custom-merge" ];
  check = asserts (
    # 1 — the stated fold, in both engines, beside the mkOptionType control
    read "gen" [ (tally sum) ] [ 2 3 ] == 5
    && read "nixpkgs" [ (tally sum) ] [ 2 3 ] == 5
    &&
      read "gen"
        [
          (genMerge.mkOptionType {
            name = "tally";
            check = isInt;
            merge = sum;
          })
        ]
        [ 2 3 ] == 5
    # 2 — checked before the fold and after it
    && read "gen" [ (tally sum) ] [ 2 "a" ] == "REFUSED"
    && read "nixpkgs" [ (tally sum) ] [ 2 "a" ] == "REFUSED"
    && read "gen" [ (tally (_: _: "x")) ] [ 2 3 ] == "REFUSED"
    && read "nixpkgs" [ (tally (_: _: "x")) ] [ 2 3 ] == "REFUSED"
    && read "gen" [ (tally (_: _: 4)) ] [ 2 3 ] == 4
    # 3 — a component of the type
    && read "gen" [ (tally sum) (tally sum) ] [ 2 3 ] == 5
    && read "gen" [ (tally sum) (tally sum') ] [ 2 3 ] == "REFUSED"
    &&
      read "gen"
        [
          (tally (sumOf { }))
          (tally (sumOf { }))
        ]
        [ 2 3 ] == 5
    # 4 — the door
    && !(built (T.typedef "tally" isInt))
    && !(built (T.typedef { mrege = sum; } "tally" isInt))
    && built (T.typedef { } "tally" isInt)
  );
}
