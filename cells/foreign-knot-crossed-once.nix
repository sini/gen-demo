# `foreign-knot-crossed-once` — C150, den-hoag-23dqs. A foreign knot closed THROUGH a gen door,
# `r = mkOptionType (types.either types.int (types.listOf r))`, aborts uncatchably at construction (the
# argued exception in gen-merge's "Known byte-mode boundaries"). Its way out is to close the knot on
# the foreign side and carry it through the door once. Through `mkOptionType` that serves nixpkgs'
# value, under gen-merge's `evalModuleTree` and under nixpkgs' own `lib.evalModules`. Through
# `deriveType` it serves the same value, but only because the re-homing walk answers "may nest" at its
# fuel's exhaustion and so re-homes a cyclic container; an acyclic foreign container there is the
# vocabulary's named refusal. The control: the same knot under `uniq`, a container outside the six,
# is the walk's named refusal at its fuel, and `tryEval` catches it.
{
  asserts,
  genMerge,
  lib,
}:
let
  inherit (lib) types;
  once =
    holder:
    let
      r = holder (types.either types.int (types.listOf r));
    in
    r;
  value = [
    1
    [ 2 ]
  ];
  read =
    eval: mkOption: type:
    (eval {
      modules = [
        { options.warp = mkOption { inherit type; }; }
        { warp = value; }
      ];
    }).config.warp;
  native = read (
    r: genMerge.evalModuleTree (removeAttrs r [ "modules" ]) r.modules
  ) genMerge.mkOption;
  derived = t: genMerge.deriveType { } "warp" t;
  uniqRead = builtins.tryEval (
    builtins.deepSeq (native (genMerge.mkOptionType (once types.uniq))) true
  );
in
{
  construct = [ "foreign-knot-crosses-a-gen-door-once" ];
  check = asserts (
    native (genMerge.mkOptionType (once (x: x))) == value
    && read lib.evalModules lib.mkOption (genMerge.mkOptionType (once (x: x))) == value
    && native (derived (once (x: x))) == value
    && !uniqRead.success
  );
}
