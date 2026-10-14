# `door-as-itself-states-its-check` — a-door-returned-as-itself-states-its-check, den-hoag-v4cw1.
# A door that returns a record as itself publishes that record's `check` and `merge` unchanged. A `//` copy whose check
# is marked coherent, as nixpkgs' `addCheck` marks its own, over a merge that does not state it, is read by nixpkgs'
# `lib.evalModules` through `merge.v2`'s `headError` alone, so gen-merge served a value the check rejects: a gen
# `nullOr` through `mkOptionType` inside nixpkgs' `either`, a nixpkgs `listOf` through `types.defineType` as the
# option's own type, and a `verify` copy of a gen `nullOr` and of a nixpkgs `nullOr` through `mkOptionType` inside
# `either`. The door's return now states its check in `headError`, as nixpkgs' `addCheck` does. Each refusal
# stands beside its passing twin, so a fold refusing everything cannot pass, and neither can one serving everything.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  gt = genMerge.types;
  read =
    type: v:
    (lib.evalModules {
      modules = [
        { options.bobbin = lib.mkOption { inherit type; }; }
        { bobbin = v; }
      ];
    }).config.bobbin;
  attempt = type: v: builtins.tryEval (builtins.deepSeq (read type v) (read type v));
  refused = type: v: !(attempt type v).success;
  served =
    type: v: want:
    (attempt type v) == {
      success = true;
      value = want;
    };
  marked =
    t: p:
    t
    // {
      check = {
        __functor = _: v: t.check v && p v;
        isV2MergeCoherent = true;
      };
    };
  bolt = gt.submodule {
    options.warp = genMerge.mkOption {
      type = gt.int;
      default = 0;
    };
  };
  notFive = v: !(builtins.isAttrs v) || v.warp or 0 != 5;
  short = v: !(builtins.isList v) || builtins.length v < 3;
  spool = ft.either (genMerge.mkOptionType (marked (gt.nullOr bolt) notFive)) ft.str;
  reel = gt.defineType (marked (ft.listOf ft.int) short);
  # a `verify` copy, of a gen container and of a nixpkgs one, with a marked check beside it
  cask = ft.either (genMerge.mkOptionType (
    marked (gt.nullOr bolt // { verify = _: null; }) notFive
  )) ft.str;
  hamper = ft.either (genMerge.mkOptionType (
    marked (ft.nullOr bolt // { verify = _: null; }) notFive
  )) ft.str;
in
{
  construct = [ "a-door-returned-as-itself-states-its-check" ];
  check = asserts (
    refused spool { warp = 5; }
    && served spool { warp = 2; } { warp = 2; }
    && served spool "s" "s"
    && refused reel [
      1
      2
      3
    ]
    && served reel [ 1 2 ] [ 1 2 ]
    && refused cask { warp = 5; }
    && served cask { warp = 2; } { warp = 2; }
    && refused hamper { warp = 5; }
    && served hamper { warp = 2; } { warp = 2; }
  );
}
