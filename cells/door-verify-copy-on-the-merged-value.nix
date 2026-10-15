# `door-verify-copy-on-the-merged-value` — a-door-reads-a-verify-copy-on-the-merged-value, den-hoag-5f99v (ADR-0025
# item 1, ADR-0039). A nixpkgs record copied with gen's `verify` (`attrsOf int // { verify }`) and passed through
# gen-merge's published `mkOptionType` reads that `verify` once, on the value its definitions merge to: a `verify`
# that needs two members two modules define is served when both are defined, and refuses a merged value it rejects,
# in nixpkgs' `lib.evalModules` and in gen-merge's evaluation beside its uncopied base. gen-merge used to read the
# `verify` per definition there, so each lone definition was rejected (or the `verify` aborted on a missing member) and
# the merged value was never read.
# Each refusal stands beside its passing twin, so a door refusing everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  np = lib.types;
  read =
    engine: types: defs:
    let
      mods =
        map (type: {
          options.skein = (if engine == "gen" then genMerge else lib).mkOption { inherit type; };
        }) types
        ++ map (v: { skein = v; }) defs;
    in
    if engine == "gen" then
      (genMerge.evalModuleTree { } mods).config.skein
    else
      (lib.evalModules { modules = mods; }).config.skein;
  refused =
    engine: types: defs:
    !(builtins.tryEval (builtins.deepSeq (read engine types defs) null)).success;
  # the warp and the weft, each defined by its own module: neither definition alone holds both
  woven = v: if v.warp == 1 && v.weft == 1 then null else "needs warp = 1 and weft = 1";
  skein = genMerge.mkOptionType (np.attrsOf np.int // { verify = woven; });
  arms = [
    {
      engine = "np";
      types = [ skein ];
    }
    {
      engine = "gen";
      types = [
        (np.attrsOf np.int)
        skein
      ];
    }
  ];
  holds =
    a:
    read a.engine a.types [
      { warp = 1; }
      { weft = 1; }
    ] == {
      warp = 1;
      weft = 1;
    }
    && refused a.engine a.types [
      { warp = 1; }
      { weft = 2; }
    ];
in
{
  construct = [ "a-door-reads-a-verify-copy-on-the-merged-value" ];
  check = asserts (builtins.all holds arms);
}
