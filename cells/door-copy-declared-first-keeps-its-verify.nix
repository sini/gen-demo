# `door-copy-declared-first-keeps-its-verify` — den-hoag-s1um3. A gen `int` with a replaced `verify`, handed through
# `types.defineType` and through `mkOptionType`, is declared FIRST and the plain gen `int` later, under nixpkgs' own
# `evalModules`. nixpkgs merges the two by calling the later declaration's relation on the earlier one's functor, and
# that relation is gen's: the copy's functor names the copy as the declaration beside its completion, and the relation
# meets the join with it. The value the copy's `verify` rejects is refused in both orders, and a value every check
# admits is served.
{
  asserts,
  genMerge,
  lib,
}:
let
  gt = genMerge.types;
  copy = gt.int // {
    verify = v: if v == 7 then "seven is out" else null;
  };
  read =
    ts: v:
    (lib.evalModules {
      modules = map (t: { options.x = lib.mkOption { type = t; }; }) ts ++ [ { x = v; } ];
    }).config.x;
  outcome =
    ts: v:
    let
      r = builtins.tryEval (builtins.deepSeq (read ts v) (read ts v));
    in
    if r.success then r.value else "refused";
  keeps =
    door:
    let
      c = door copy;
    in
    outcome [
      c
      gt.int
    ] 7 == "refused"
    &&
      outcome [
        c
        gt.int
      ] 3 == 3
    &&
      outcome [
        gt.int
        c
      ] 7 == "refused";
in
{
  construct = [ "a-door-copy-declared-first-keeps-its-verify" ];
  check = asserts (keeps gt.defineType && keeps genMerge.mkOptionType);
}
