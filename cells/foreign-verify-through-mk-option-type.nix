# `foreign-verify-through-mk-option-type` — a-foreign-verify-through-mk-option-type-is-enforced, den-hoag-xj4tw
# (ADR-0025 item 1, ADR-0039). A nixpkgs record copied with gen's `verify` (`np.int // { verify }`, a keyed nixpkgs
# `submodule`, a `nullOr` of one) and passed through gen-merge's published `mkOptionType` keeps that `verify`: a value
# only the `verify` rejects is refused, declared once, twice, and after its uncopied base, in gen-merge's evaluation
# and in nixpkgs' own, and a value it admits is served. Beside an `either` alternative that admits the rejected value,
# declared twice, the value is served by that alternative, as `defineType` serves it. gen-merge used to answer
# nixpkgs' redeclaration and its submodule fixup with the nixpkgs constructor's own rebuild, which states no `verify`,
# and served the rejected value silently.
# Each refusal stands beside its passing twin, so a door refusing everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  np = lib.types;
  read =
    engine: types: v:
    let
      mods =
        map (type: {
          options.bobbin = (if engine == "gen" then genMerge else lib).mkOption { inherit type; };
        }) types
        ++ [ { bobbin = v; } ];
    in
    if engine == "gen" then
      (genMerge.evalModuleTree { } mods).config.bobbin
    else
      (lib.evalModules { modules = mods; }).config.bobbin;
  refused =
    engine: types: v:
    !(builtins.tryEval (builtins.deepSeq (read engine types v) null)).success;
  # a nixpkgs submodule with a `key`, so a redeclaration merges one module list
  spindle = np.submodule {
    key = "foreign-verify-through-mk-option-type";
    options.ply = lib.mkOption {
      type = np.int;
      default = 0;
    };
  };
  notTwoPly = v: if builtins.isAttrs v && (v.ply or 0) == 2 then "two ply" else null;
  rows = [
    {
      base = np.int;
      verify = v: if v == 20 then "twenty" else null;
      ok = 1;
      okValue = 1;
      bad = 20;
    }
    {
      base = spindle;
      verify = notTwoPly;
      ok = {
        ply = 1;
      };
      okValue = {
        ply = 1;
      };
      bad = {
        ply = 2;
      };
    }
    {
      base = np.nullOr spindle;
      verify = notTwoPly;
      ok = {
        ply = 1;
      };
      okValue = {
        ply = 1;
      };
      bad = {
        ply = 2;
      };
    }
  ];
  holds =
    r:
    let
      y = genMerge.mkOptionType (r.base // { inherit (r) verify; });
    in
    builtins.all
      (
        engine:
        builtins.all (types: refused engine types r.bad && read engine types r.ok == r.okValue) [
          [ y ]
          [
            y
            y
          ]
          [
            r.base
            y
          ]
        ]
      )
      [
        "gen"
        "np"
      ];
  # declared twice inside an `either` whose other member admits the rejected value: that member serves it
  member =
    let
      i = genMerge.mkOptionType (np.int // { verify = v: if v == 20 then "twenty" else null; });
      s = genMerge.mkOptionType (spindle // { verify = notTwoPly; });
    in
    builtins.all
      (
        engine:
        read engine [ (np.either i np.int) (np.either i np.int) ] 20 == 20
        &&
          read engine [ (np.either s (np.attrsOf np.int)) (np.either s (np.attrsOf np.int)) ] { ply = 2; }
          == {
            ply = 2;
          }
      )
      [
        "gen"
        "np"
      ];
in
{
  construct = [ "a-foreign-verify-through-mk-option-type-is-enforced" ];
  check = asserts (builtins.all holds rows && member);
}
