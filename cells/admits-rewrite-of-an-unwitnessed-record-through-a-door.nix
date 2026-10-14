# `admits-rewrite-of-an-unwitnessed-record-through-a-door` — an-admits-rewrite-through-a-door-is-enforced, den-hoag-2632d
# (ADR-0025 item 1). The records `admits-rewrite-through-a-door` leaves out: gen's `submodule` and `deferredModule`, and the
# library constants `attrs`, `anything`, `raw`, `optionType` and `unspecified`. A `//` copy that states an `admits` of its
# own, passed through the published `types.defineType` and `mkOptionType`, refuses a value inside the record's own domain
# that the new `admits` drops, and a value it keeps reads as nixpkgs' `addCheck` of the same record through the same door
# reads it, declared once and twice and as a gen submodule's option in gen-merge's evaluation, and declared once and
# twice in nixpkgs' own `evalModules`. gen-merge used to read such a copy as the record it was copied from and serve the dropped value
# silently, because these folds carried no record of what they were completed with.
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
  noWeft = v: builtins.isAttrs v && !(v ? weft);
  isInt = builtins.isInt;
  # record, the copy's `admits`, a value it keeps, a value inside the record's own domain it drops, and what is
  # compared of a served value (a type's name for `optionType`, whose values are type records)
  rows = [
    {
      t = gt.submodule {
        options.warp = genMerge.mkOption {
          type = gt.int;
          default = 0;
        };
        options.weft = genMerge.mkOption {
          type = gt.int;
          default = 0;
        };
      };
      n = noWeft;
      ok.warp = 2;
      bad.weft = 5;
    }
    {
      t = gt.deferredModule;
      n = builtins.isAttrs;
      ok = { };
      bad = "/gen-demo-spool.nix";
    }
    {
      t = gt.attrs;
      n = noWeft;
      ok.warp = 2;
      bad.weft = 5;
    }
    {
      t = gt.anything;
      n = isInt;
      ok = 2;
      bad = "sateen";
    }
    {
      t = gt.raw;
      n = isInt;
      ok = 2;
      bad = "sateen";
    }
    {
      t = gt.unspecified;
      n = isInt;
      ok = 2;
      bad = "sateen";
    }
    {
      t = gt.optionType;
      n = v: v.name == gt.int.name;
      ok = gt.int;
      bad = gt.str;
      view = v: v.name;
    }
  ];
  view = r: r.view or (v: v);
  refused =
    r: engine: types: v:
    !(builtins.tryEval (builtins.deepSeq (view r (read engine types v)) null)).success;
  # what a declaration set reads at `v`: the value compared, or `null` when refused
  outcome =
    r: engine: types: v:
    let
      got = builtins.tryEval (
        builtins.deepSeq (view r (read engine types v)) (view r (read engine types v))
      );
    in
    if got.success then { inherit (got) value; } else null;
  # read as nixpkgs' `addCheck` of the same record through the same door reads it
  served =
    r: twin: engine: types: v:
    outcome r engine types v == outcome r engine (map (_: twin) types) v;
  doors = [
    gt.defineType
    genMerge.mkOptionType
  ];
  # the copy as the root (once, twice) and as a gen submodule's option
  holds =
    r: door:
    let
      x = door (r.t // { admits = r.n; });
      p = door (lib.types.addCheck r.t r.n);
      host = t: gt.submodule { options.weft = genMerge.mkOption { type = t; }; };
    in
    builtins.all (types: refused r "gen" types r.bad && served r p "gen" types r.ok) [
      [ x ]
      [
        x
        x
      ]
    ]
    && outcome r "gen" [ x ] r.ok != null
    && !(builtins.tryEval (
      builtins.deepSeq (view r (read "gen" [ (host x) ] { weft = r.bad; }).weft) null
    )).success
    &&
      view r (read "gen" [ (host x) ] { weft = r.ok; }).weft
      == view r (read "gen" [ (host p) ] { weft = r.ok; }).weft
    && builtins.all (types: refused r "np" types r.bad && served r p "np" types r.ok) [
      [ x ]
      [
        x
        x
      ]
    ];
  # the plain record through the same door serves the dropped value: the refusal is the rewrite's
  plain = r: door: !(refused r "gen" [ (door r.t) ] r.bad);
in
{
  construct = [ "an-admits-rewrite-through-a-door-is-enforced" ];
  check = asserts (builtins.all (r: builtins.all (d: holds r d && plain r d) doors) rows);
}
