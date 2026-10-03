# `nested-container-keyed-on-read` — C156, den-hoag-mda6f. A gen `attrsOf` or `listOf` whose element
# is gen's own `attrsOf` or `listOf` of a gen submodule, in gen-merge's own `evalModuleTree`, gives
# nixpkgs' value for the same construction over its own types at an element beside a sibling that
# is outside the inner container's domain, beside a sibling whose own element throws, and beside a
# sibling element that `mkIf false` discharges. An inner `attrsOf` of non-containers is keyed
# over-approximately, by its definitions' attribute names; an inner `listOf`, and an inner `attrsOf`
# of attribute-keyed containers, are container nodes keyed where they are read, one per outer
# element; so no
# sibling's definitions are split or forced. The read used to abort with `expected a set but found
# an integer`, which `tryEval` cannot catch.
{
  asserts,
  genMerge,
  lib,
}:
let
  # `P` is the type vocabulary and `mkOption` its option constructor; the leaf is one int option.
  value =
    eval: P: mkOption: shape: def: read:
    read
      (eval {
        modules = [
          {
            options.warp = mkOption {
              type = shape P (P.submodule { options.x = mkOption { type = P.int; }; });
            };
          }
          { config.warp = def; }
        ];
      }).config.warp;
  holds =
    shape: def: read:
    value genMerge.evalModuleTree genMerge.types genMerge.mkOption shape def read
    == value lib.evalModules lib.types lib.mkOption shape def read;
  forced = throw "nested-container-keyed-on-read: a sibling's element was forced";
in
{
  construct = [ "C156" ];
  check = asserts (
    holds (P: S: P.attrsOf (P.attrsOf S)) {
      bobbin = 5;
      shuttle.k.x = 5;
    } (v: v.shuttle.k)
    && holds (P: S: P.attrsOf (P.listOf S)) {
      bobbin = 5;
      shuttle = [ { x = 5; } ];
    } (v: v.shuttle)
    && holds (P: S: P.listOf (P.attrsOf S)) [
      5
      { k.x = 5; }
    ] (v: builtins.elemAt v 1)
    && holds (P: S: P.attrsOf (P.attrsOf S)) {
      bobbin.k = forced;
      shuttle.k.x = 5;
    } (v: v.shuttle.k)
    && holds (P: S: P.attrsOf (P.attrsOf (P.attrsOf S))) {
      bobbin.k = forced;
      shuttle.k.j.x = 5;
    } (v: v.shuttle.k.j)
    && holds (P: S: P.attrsOf (P.attrsOf (P.nullOr S))) {
      bobbin.k = forced;
      shuttle.k.x = 5;
    } (v: v.shuttle.k)
    && holds (P: S: P.attrsOf (lib.types.attrsOf (P.attrsOf S))) {
      bobbin.k.j.x = 1;
      shuttle.k.j.x = 5;
    } (v: v)
    && holds (P: S: P.attrsOf (P.attrsOf S)) {
      bobbin.k = lib.mkIf false forced;
      bobbin.j.x = 2;
      shuttle.k.x = 5;
    } (v: v)
  );
}
