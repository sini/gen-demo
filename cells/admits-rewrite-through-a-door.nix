# `admits-rewrite-through-a-door` — an-admits-rewrite-through-a-door-is-enforced, den-hoag-56u5o (ADR-0025
# item 1). A `//` copy of a gen container that rewrites its `admits` narrows the domain the copy states, and the
# published `types.defineType` and `mkOptionType` hand it on as the check rewrite it is: a value inside the
# container's own domain and outside the new `admits` is refused, declared once and twice, as the root and as a
# gen submodule's option, in gen-merge's evaluation and in nixpkgs' own; a value the new `admits` keeps is served
# as the plain container serves it. gen-merge used to publish the new `admits` as the door's `check` and fold by
# the container's own domain, serving the rejected value silently.
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
  noWeft = v: builtins.isAttrs v && !(v ? weft);
  # base, the narrowed `admits`, a value it keeps, a value inside the base's domain it drops
  rows = [
    {
      t = gt.listOf gt.int;
      n = v: builtins.isList v && builtins.length v <= 1;
      ok = [ 2 ];
      bad = [
        2
        5
      ];
    }
    {
      t = gt.attrsOf gt.int;
      n = noWeft;
      ok = {
        warp = 2;
      };
      bad = {
        weft = 5;
      };
    }
    {
      t = gt.lazyAttrsOf gt.int;
      n = noWeft;
      ok = {
        warp = 2;
      };
      bad = {
        weft = 5;
      };
    }
    {
      t = gt.nullOr gt.int;
      n = v: v == null || v < 5;
      ok = 2;
      bad = 5;
    }
    {
      t = gt.either gt.int gt.str;
      n = builtins.isInt;
      ok = 2;
      bad = "sateen";
    }
  ];
  doors = [
    gt.defineType
    genMerge.mkOptionType
  ];
  # the copy as the root (once, twice) and as a gen submodule's option
  holds =
    r: door:
    let
      x = door (r.t // { admits = r.n; });
      host = gt.submodule { options.weft = genMerge.mkOption { type = x; }; };
    in
    builtins.all (types: refused "gen" types r.bad && served "gen" types r.ok) [
      [ x ]
      [
        x
        x
      ]
    ]
    && refused "gen" [ host ] { weft = r.bad; }
    && served "gen" [ host ] { weft = r.ok; }
    && refused "np" [ x ] r.bad
    && served "np" [ x ] r.ok
    && refused "np" [ x x ] r.bad
    && served "np" [ x x ] r.ok;
  # the plain container through the same door serves the dropped value: the refusal is the rewrite's
  plain = r: door: served "gen" [ (door r.t) ] r.bad;
in
{
  construct = [ "an-admits-rewrite-through-a-door-is-enforced" ];
  check = asserts (builtins.all (r: builtins.all (d: holds r d && plain r d) doors) rows);
}
