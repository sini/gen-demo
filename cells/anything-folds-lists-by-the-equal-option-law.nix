# `anything-folds-lists-by-the-equal-option-law` — den-hoag-h76uk (ADR-0039). gen-merge's `anything`
# folds list definitions as nixpkgs' `anything` does: nixpkgs' has no list arm, so lists reach its
# equality fold (`mergeEqualOption`), where equal lists give one copy and unequal lists are refused by
# name. Before, gen concatenated them: `[ 1 ]` beside `[ 1 ]` read `[ 1 1 ]` where nixpkgs serves
# `[ 1 ]`, and `[ 1 ]` beside `[ 2 ]` read `[ 2 1 ]` where nixpkgs refuses. A guard carrier's lists keep
# their own law, T4's (gen-aspects): an `includes` both of a carrier's firing definitions write
# concatenates, as the declared `listOf` does. Control: `raw`, which already folds by equality.
{
  asserts,
  genAspects,
  genMerge,
}:
let
  T = genMerge.types;
  declared =
    t: defs:
    (genMerge.evalModuleTree { } (
      [ { options.o = genMerge.mkOption { type = t; }; } ] ++ map (d: { o = d; }) defs
    )).config.o;
  free =
    defs:
    (genMerge.evalModuleTree { } (
      [ { freeformType = T.attrsOf T.anything; } ] ++ map (d: { k = d; }) defs
    )).config.k;
  ok = v: (builtins.tryEval (builtins.deepSeq v true)).success;
  gv = genAspects.mkGuardVocab { };
  carrierIncludes =
    (gv.applyGuard { thimble.name = "cortex"; }
      (genMerge.evalModuleTree { } [
        { options.aspects = (genAspects.mkAspectSchema { }).mkAspectOption { }; }
        { aspects.dup = gv.vocab.always { includes = [ "p" ]; }; }
        { aspects.dup = gv.vocab.always { includes = [ "q" ]; }; }
      ]).config.aspects.dup
    ).includes;
in
{
  construct = [ "anything-folds-lists-by-the-equal-option-law" ];
  check = asserts (
    declared T.anything [
      [ 1 ]
      [ 1 ]
    ] == [ 1 ]
    && !(ok (
      declared T.anything [
        [ 1 ]
        [ 2 ]
      ]
    ))
    && !(ok (free [
      (genMerge.mkOverride 40 [ 1 ])
      (genMerge.mkOverride 40 [ 2 ])
      [ 3 ]
    ]))
    &&
      declared T.anything [
        { a = [ 1 ]; }
        { a = [ 1 ]; }
      ] == {
        a = [ 1 ];
      }
    &&
      builtins.sort (x: y: x < y) carrierIncludes == [
        "p"
        "q"
      ]
    # control: `raw` folds equal lists to one copy
    &&
      declared T.raw [
        [ 1 ]
        [ 1 ]
      ] == [ 1 ]
  );
}
