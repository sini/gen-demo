# `leaf-container-verify-copy-at-nixpkgs-fold-judges-the-settled-value` — den-hoag-admdl. A gen `attrsOf int` copied
# with a `verify` that reads two members (`v.a`, `v.b`, no `or`), completed through `types.defineType` and
# `mkOptionType`, is declared in nixpkgs' own `lib.evalModules`, bare and as a member of a v2 `either` beside `str`.
# The `verify` refines the option's settled value, so a split (`a` in one module, `b` in another) is served at its
# merged value, as the raw copy is, and a split whose merged value the `verify` rejects is refused by name, catchably.
# Each door used to publish a one-definition reading to nixpkgs' fold, which aborted uncatchably on the member a
# single definition does not state.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = genMerge.types;
  np = lib.types;
  read =
    type: defs:
    (lib.evalModules {
      modules = [ { options.spool = lib.mkOption { inherit type; }; } ] ++ map (d: { spool = d; }) defs;
    }).config.spool;
  outcome =
    type: defs:
    let
      r = builtins.tryEval (builtins.deepSeq (read type defs) (read type defs));
    in
    if r.success then r.value else "REFUSED";
  copy = t.attrsOf t.int // {
    verify = v: if v.a == 1 && v.b == 1 then null else "a and b must both be 1";
  };
  mounts = [
    (y: y)
    (y: np.either y np.str)
  ];
  doors = [
    t.defineType
    genMerge.mkOptionType
  ];
  judged =
    ty:
    outcome ty [
      { a = 1; }
      { b = 1; }
    ] == {
      a = 1;
      b = 1;
    }
    &&
      outcome ty [
        { a = 2; }
        { b = 1; }
      ] == "REFUSED";
in
{
  construct = [ "a-gen-leaf-container-verify-copy-at-a-nixpkgs-fold-judges-its-settled-value" ];
  check = asserts (lib.all (door: lib.all (m: judged (m (door copy))) mounts) doors);
}
