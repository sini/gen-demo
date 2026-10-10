# `nixpkgs-submodule-check-override` — a-nixpkgs-submodule-check-override-is-enforced, den-hoag-ukitj
# (owner-ruled 2026-10-09, arm b1). A nixpkgs `submodule` given an ad-hoc `// { check }` override is
# enforced in gen's engine: declared alone, twice, beside the plain submodule in either order, and as a
# `listOf` / `attrsOf` element, raw and through `types.defineType`, a value the override admits is read
# and a value it rejects is refused by name. nixpkgs serves the first and silently serves the second;
# gen-merge used to refuse both. Each refusal stands beside its passing twin, so a fold refusing
# everything cannot pass, and neither can one serving everything.
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
  attempt = types: v: builtins.tryEval (builtins.deepSeq (read types v) (read types v));
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
  ok = {
    warp = 2;
  };
  bad = {
    warp = 5;
  };
  positions = o: [
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
  enforced = o: lib.all (p: served p.types p.ok && refused p.types p.bad) (positions o);
in
{
  construct = [ "a-nixpkgs-submodule-check-override-is-enforced" ];
  check = asserts (
    lib.all (door: enforced (door override)) [
      (d: d)
      gt.defineType
    ]
  );
}
