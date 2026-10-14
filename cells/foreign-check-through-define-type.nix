# `foreign-check-through-define-type` — a-foreign-check-through-define-type-is-enforced, den-hoag-zdp46 (ADR-0025
# item 1). A descriptor handed to gen-merge's published `types.defineType` stating nixpkgs' `check` beside gen's own
# words (`admits`, `verify`, `mergeDefs`) keeps that check: a value only the check rejects is refused, declared once and
# twice, in gen-merge's evaluation and in nixpkgs' own, and a value every stated predicate admits is served. Beside a
# `verify`, the check also decides union membership: `either <it> int` serves the rejected value by `int`. gen-merge
# used to derive the door's `check` from `verify` or `admits` alone, falling back to `_: true`, and served the
# rejected value silently.
# A descriptor carrying nixpkgs' own `listOf int` fold (the record with `_type` removed) and stating a `check` that
# rejects a list of three or more, with a `verify` that rejects a list holding 9, keeps both: the fold's own refusal of
# the ad-hoc check does not refuse the list both admit, and the `verify` is not lost when it is declared twice in
# nixpkgs' evaluation.
# Each refusal stands beside its passing twin, so a door refusing everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  read =
    engine: types: v:
    let
      mods =
        map (type: {
          options.spool = (if engine == "gen" then genMerge else lib).mkOption { inherit type; };
        }) types
        ++ [ { spool = v; } ];
    in
    if engine == "gen" then
      (genMerge.evalModuleTree { } mods).config.spool
    else
      (lib.evalModules { modules = mods; }).config.spool;
  refused =
    engine: types: v:
    !(builtins.tryEval (builtins.deepSeq (read engine types v) null)).success;
  served =
    engine: types: v:
    read engine types v == v;
  # the check rejects 3, alone or beside a domain that admits it
  check = v: builtins.isInt v && v != 3;
  rows = [
    { }
    { admits = builtins.isInt; }
    { verify = v: if builtins.isInt v then null else "not an int"; }
    { mergeDefs = loc: defs: lib.mergeEqualOption loc defs; }
  ];
  holds =
    r:
    let
      x = gt.defineType (
        {
          name = "selvage";
          inherit check;
        }
        // r
      );
    in
    builtins.all
      (
        engine:
        builtins.all (types: refused engine types 3 && served engine types 4) [
          [ x ]
          [
            x
            x
          ]
        ]
      )
      [
        "gen"
        "np"
      ];
  member =
    let
      x = gt.defineType {
        name = "selvage";
        inherit check;
        verify = v: if builtins.isInt v then null else "not an int";
      };
    in
    read "gen" [ (gt.either x gt.int) ] 3 == 3
    && read "np" [ (lib.types.either x lib.types.int) ] 3 == 3;
  fold =
    let
      x = gt.defineType (
        builtins.removeAttrs (lib.types.listOf lib.types.int) [ "_type" ]
        // {
          check = v: builtins.isList v && builtins.length v < 3;
          verify = v: if builtins.isList v && !(builtins.elem 9 v) then null else "holds 9";
        }
      );
    in
    builtins.all
      (
        engine:
        builtins.all
          (
            types:
            served engine types [ 1 ]
            && refused engine types [
              1
              2
              3
            ]
            && refused engine types [ 9 ]
          )
          [
            [ x ]
            [
              x
              x
            ]
          ]
      )
      [
        "gen"
        "np"
      ];
in
{
  construct = [ "a-foreign-check-through-define-type-is-enforced" ];
  check = asserts (builtins.all holds rows && member && fold);
}
