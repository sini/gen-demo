# `threaded-verify-on-the-settled-value` — den-hoag-x7qe5 (owner Ruling 8, ADR-0039: a `verify` is a refinement on
# the option node's settled value, never on its definition edges). Four shapes, each served where its `verify` admits
# the value (nixpkgs' own value, `lib.evalModules` over nixpkgs' types) and refused, catchably, where it rejects it:
# a gen `submodule` copied with a `verify` below nixpkgs' `uniq`, once and twice; the `mkOptionType` door over an
# `addCheck` copy of `either submodule str` stating the same `verify`, declared before a plain `attrsOf` and given one
# module-function definition; door copies declared last of four, in nixpkgs' own evaluation; and a wrapper's own
# check (`addCheck` over the threaded `uniq`), which stays the wrapper's; and a met record below two threaded `uniq`. A `verify` wanting two list elements, met
# from two one-element definitions, serves their merge. gen-merge served each rejected value: the thread answered
# with the copy's base, the meet read the combining fold's `verify` per definition, and nixpkgs' pairwise fold re-met
# the bare meet. The by-name half is `ci/refusals/a-verify-through-a-threaded-wrapper-is-refused-by-name.sh`.
{
  asserts,
  genMerge,
  lib,
}:
let
  np = lib.types;
  gt = genMerge.types;
  # keyed: a submodule declared at several declarations is one module, as nixpkgs dedupes it
  bobbin = K: mkOption: {
    key = "threaded-verify-on-the-settled-value";
    options.warp = mkOption {
      type = K.int;
      default = 0;
    };
    options.weft = mkOption {
      type = K.int;
      default = 0;
    };
  };
  subOf = K: mkOption: K.submodule (bobbin K mkOption);
  sub = subOf gt genMerge.mkOption;
  npSub = subOf np lib.mkOption;
  noTwo = v: !(builtins.isAttrs v) || (v.warp or 0) != 2;
  verify = v: if noTwo v then null else "the spool rejects warp 2";
  copy = sub // {
    inherit verify;
  };
  eith = gt.either sub gt.str;
  npEith = np.either npSub np.str;
  both = genMerge.mkOptionType (np.addCheck eith noTwo // { inherit verify; });
  notThree = v: !(builtins.isAttrs v) || (v.warp or 0) != 3;
  # `gen`: gen-merge's evaluation; `np`: nixpkgs' `lib.evalModules` over the same declarations; one option `spool`
  eval =
    engine: types: defs:
    let
      mkOption = if engine == "gen" then genMerge.mkOption else lib.mkOption;
      ms =
        map (type: { options.spool = mkOption { inherit type; }; }) types ++ map (d: { spool = d; }) defs;
      c =
        if engine == "gen" then
          (genMerge.evalModuleTree { } ms).config
        else
          (lib.evalModules { modules = ms; }).config;
    in
    builtins.tryEval (builtins.deepSeq c.spool c.spool);
  served =
    engine: types: defs: want:
    let
      r = eval engine types defs;
    in
    r.success && r.value == want;
  refused =
    engine: types: defs:
    !(eval engine types defs).success;
  v1 = {
    warp = 1;
    weft = 0;
  };
  # nixpkgs' own value for the same definitions, over nixpkgs' own types
  twin = types: defs: (eval "np" types defs).value;
  uniqCopy =
    served "gen" [ (np.uniq copy) ] [ { warp = 1; } ] (twin [ (np.uniq npSub) ] [ { warp = 1; } ])
    && refused "gen" [ (np.uniq copy) ] [ { warp = 2; } ]
    && served "gen" [ (np.uniq (np.uniq copy)) ] [ { warp = 1; } ] v1
    && refused "gen" [ (np.uniq (np.uniq copy)) ] [ { warp = 2; } ];
  doorMeet =
    let
      at = d: { k = { ... }: d; };
    in
    served "gen" [ (np.attrsOf both) (np.attrsOf eith) ] [ (at { warp = 1; }) ] (
      twin [ (np.attrsOf npEith) (np.attrsOf npEith) ] [ (at { warp = 1; }) ]
    )
    && refused "gen" [ (np.attrsOf both) (np.attrsOf eith) ] [ (at { warp = 2; }) ];
  wrapperCheck =
    served "gen" [ (np.addCheck (np.uniq copy) notThree) ] [ { warp = 1; } ] v1
    && refused "gen" [ (np.addCheck (np.uniq copy) notThree) ] [ { warp = 3; } ]
    && refused "gen" [ (np.addCheck (np.uniq copy) notThree) ] [ { warp = 2; } ];
  # each declaration its own door application, as separate modules write them
  lastInNixpkgs =
    let
      d = _: genMerge.mkOptionType (eith // { inherit verify; });
      last2 = [
        eith
        eith
        (d 3)
        (d 4)
      ];
    in
    served "np" last2 [ { warp = 1; } ] (twin [ npEith npEith npEith npEith ] [ { warp = 1; } ])
    && refused "np" last2 [ { warp = 2; } ]
    && refused "np" [ eith eith eith (d 4) ] [ { warp = 2; } ];
  # a met record (a door copy met with two plain declarations) below two threaded `uniq`
  metBelowTwo =
    let
      uu = t: np.uniq (np.uniq t);
      ds = [
        (uu eith)
        (uu eith)
        (uu (genMerge.mkOptionType (eith // { inherit verify; })))
      ];
    in
    served "gen" ds [ { warp = 1; } ] v1 && refused "gen" ds [ { warp = 2; } ];
  mergedList =
    served "gen"
      [
        (gt.attrsOf (gt.listOf gt.int))
        (gt.attrsOf (
          gt.listOf gt.int // { verify = v: if builtins.length v >= 2 then null else "one thread"; }
        ))
      ]
      [
        { k = [ 1 ]; }
        { k = [ 2 ]; }
      ]
      (
        twin
          [ (np.attrsOf (np.listOf np.int)) ]
          [
            { k = [ 1 ]; }
            { k = [ 2 ]; }
          ]
      );
in
{
  construct = [ "a-verify-is-read-on-the-settled-value-through-a-threaded-wrapper" ];
  check = asserts (
    uniqCopy && doorMeet && wrapperCheck && lastInNixpkgs && metBelowTwo && mergedList
  );
}
