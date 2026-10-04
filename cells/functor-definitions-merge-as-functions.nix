# `functor-definitions-merge-as-functions` — C145, den-hoag-1ypox. Two nixpkgs `setFunctionArgs`
# wrappers defined at one default-merged position are functions to nixpkgs' `lib.isFunction`, so
# gen-merge's shape-directed law takes its function arm for them, as nixpkgs' `mergeDefaultOption`
# does: the merged value is a function, and applied it merges both results pointwise, where gen-merge
# `//`-folded the two wrappers and kept only the last. A check-only `mkOptionType` refuses one wrapper
# written in two files exactly as it refuses one lambda written twice. A wrapper beside a plain
# attrset is still an attrset merge on both engines, which is the control.
{
  asserts,
  genMerge,
  lib,
}:
let
  one = x: [ x ];
  two = x: [ (x + 1) ];
  defsOf = map (v: {
    file = "/demo/warp.nix";
    value = v;
  });
  wrapped = defsOf [
    (lib.setFunctionArgs one { })
    (lib.setFunctionArgs two { })
  ];
  shared = lib.setFunctionArgs one { };
  thread = genMerge.mkOptionType {
    name = "thread";
    check = _: true;
  };
  heddle =
    vs:
    builtins.tryEval
      (genMerge.evalModuleTree { } (
        [
          { options.heddle = genMerge.mkOption { type = thread; }; }
        ]
        ++ map (v: { heddle = v; }) vs
      )).config.heddle;
  beside = defsOf [
    shared
    { b = 2; }
  ];
in
{
  construct = [ "C145" ];
  check = asserts (
    builtins.isFunction (lib.mergeDefaultOption [ "heddle" ] wrapped)
    && builtins.isFunction (genMerge.mergeDefaultOption [ "heddle" ] wrapped)
    &&
      genMerge.mergeDefaultOption [ "heddle" ] wrapped 1 == [
        1
        2
      ]
    && !(heddle [
      shared
      shared
    ]).success
    && !(heddle [
      one
      one
    ]).success
    &&
      builtins.attrNames (genMerge.mergeDefaultOption [ "heddle" ] beside)
      == builtins.attrNames (lib.mergeDefaultOption [ "heddle" ] beside)
  );
}
