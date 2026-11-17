# `a-check-only-door-copy-is-enforced-in-nixpkgs-evaluation` — den-hoag-exported-typemerge-drops-on-nixpkgs-engine-alnjf.
# Two options are declared under nixpkgs' `evalModules`, in every order of their declarations. `weave`: gen
# `enum "weave" [ "sateen" "twill" ]`, the same enum through `genMerge.mkOptionType` as a copy whose check admits `twill`
# alone, and gen `enum "loom" [ "satin" ]`. `count`: gen `int` beside gen `int` through both doors as a copy whose check
# admits even values. A check-only copy names itself as the declaration wherever it is carried, so the relation nixpkgs
# asks owes its check: `twill` and `satin` are served (enum extension), `sateen` (the copy rejects it within its own
# values) and `bobbin` (no declaration holds it) are refused, `4` is served and `3` refused, at every order.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  even = v: builtins.isInt v && lib.mod v 2 == 0;
  decl = {
    weave = {
      A = gt.enum "weave" [
        "sateen"
        "twill"
      ];
      K = genMerge.mkOptionType (
        gt.enum "weave" [
          "sateen"
          "twill"
        ]
        // {
          check = v: v == "twill";
        }
      );
      L = gt.enum "loom" [ "satin" ];
    };
    count = {
      G = gt.int;
      C = genMerge.mkOptionType (gt.int // { check = even; });
      D = genMerge.types.mkOptionType (gt.int // { check = even; });
    };
  };
  # each value, and whether every order serves it
  want = {
    weave = {
      twill = true;
      satin = true;
      sateen = false;
      bobbin = false;
    };
    count = {
      "4" = true;
      "3" = false;
    };
  };
  value = o: v: if o == "count" then lib.toInt v else v;
  perms =
    xs:
    if xs == [ ] then [ [ ] ] else lib.concatMap (x: map (p: [ x ] ++ p) (perms (lib.remove x xs))) xs;
  served =
    o: w: v:
    (builtins.tryEval (
      let
        c =
          (lib.evalModules {
            modules = map (k: { options.${o} = lib.mkOption { type = decl.${o}.${k}; }; }) w ++ [
              { ${o} = value o v; }
            ];
          }).config;
      in
      builtins.deepSeq c.${o} c.${o}
    )).success;
in
{
  construct = [ "redeclared-option-accepts-only-what-every-declaration-accepts" ];
  check = asserts (
    lib.mapAttrs (
      o: vs: lib.mapAttrs (v: _: map (w: served o w v) (perms (builtins.attrNames decl.${o}))) vs
    ) want == lib.mapAttrs (_: lib.mapAttrs (_: s: builtins.genList (_: s) 6)) want
  );
}
