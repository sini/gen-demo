# `nixpkgs-submodule-check-override` — a-nixpkgs-submodule-check-override-is-enforced, den-hoag-ukitj
# (owner-ruled 2026-10-09, arm b1). A nixpkgs `submodule` given an ad-hoc `// { check }` override is
# enforced in gen's engine: declared alone, twice, beside the plain submodule in either order, and as a
# `listOf` / `attrsOf` element, raw and through `types.defineType`, a value the override admits is read
# and a value it rejects is refused by name. nixpkgs serves the first and silently serves the second;
# gen-merge used to refuse both. Each refusal stands beside its passing twin, so a fold refusing
# everything cannot pass, and neither can one serving everything.
# Through `mkOptionType` too, and for nixpkgs' `addCheck` as for the override (den-hoag-aux3h): the door
# completes the record with a gen relation, and its check still rides on every rebuild of its module set,
# redeclared beside the plain submodule, beside the plain one through the same door, or twice.
# And as a member of gen's `either` and `oneOf` at every one of those positions (den-hoag-78k2m): a
# union's members merge pairwise, and each member's join is met as a declaration's is. And as the
# `freeformType` of two modules, a plane no declaration list's fixup runs on.
{
  asserts,
  genMerge,
  lib,
}:
let
  ft = lib.types;
  gt = genMerge.types;
  read =
    types: v:
    (genMerge.evalModuleTree { } (
      map (type: { options.bobbin = genMerge.mkOption { inherit type; }; }) types ++ [ { bobbin = v; } ]
    )).config.bobbin;
  # the record as the `freeformType` of two modules: the value lands at a key nobody declares
  readFree =
    o: v:
    (genMerge.evalModuleTree { } [
      { freeformType = gt.lazyAttrsOf o; }
      { freeformType = gt.lazyAttrsOf o; }
      { bobbin = v; }
    ]).config.bobbin;
  tryRead = r: builtins.tryEval (builtins.deepSeq r r);
  attempt = types: v: tryRead (read types v);
  refused = types: v: !(attempt types v).success;
  served =
    types: v:
    let
      r = attempt types v;
    in
    r.success && r.value == v;
  plain = ft.submodule { options.warp = lib.mkOption { type = ft.int; }; };
  override = plain // {
    check = v: plain.check v && v.warp != 5;
  };
  added = ft.addCheck plain (v: v.warp != 5);
  ok = {
    warp = 2;
  };
  bad = {
    warp = 5;
  };
  positions = door: o: [
    {
      types = [
        (door plain)
        o
      ];
      inherit ok bad;
    }
    {
      types = [ o ];
      inherit ok bad;
    }
    {
      types = [
        o
        o
      ];
      inherit ok bad;
    }
    {
      types = [
        plain
        o
      ];
      inherit ok bad;
    }
    {
      types = [
        o
        plain
      ];
      inherit ok bad;
    }
    {
      types = [ (gt.listOf o) ];
      ok = [ ok ];
      bad = [ bad ];
    }
    {
      types = [ (gt.attrsOf o) ];
      ok.k = ok;
      bad.k = bad;
    }
  ];
  members = [
    (t: t)
    (t: gt.either t gt.str)
    (
      t:
      gt.oneOf [
        gt.str
        t
      ]
    )
  ];
  enforced =
    door: o:
    lib.all (
      u: lib.all (p: served (map u p.types) p.ok && refused (map u p.types) p.bad) (positions door o)
    ) members
    && (tryRead (readFree o ok)).value == ok
    && !(tryRead (readFree o bad)).success;
in
{
  construct = [ "a-nixpkgs-submodule-check-override-is-enforced" ];
  check = asserts (
    lib.all (door: enforced door (door override) && enforced door (door added)) [
      (d: d)
      gt.defineType
      genMerge.mkOptionType
    ]
  );
}
