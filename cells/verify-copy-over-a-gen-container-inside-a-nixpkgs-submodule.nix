# `verify-copy-over-a-gen-container-inside-a-nixpkgs-submodule` — den-hoag-89s7p. A `//` copy that replaces the
# `verify` of a gen `listOf spool` keeps the container's own fold, which never reads the replaced `verify`, so a
# nixpkgs `submodule` evaluating it as an option served the list the copy rejects, at any depth, under a nixpkgs
# `attrsOf`, or as the element of a nixpkgs `listOf` or a tag of a nixpkgs `attrTag` declared inside it. gen-merge
# now judges the copy at the option's own read, as it judges a copy over a leaf: `[ "weft" ]` is refused, its
# passing twin `[ "warp" ]` is served, and an option the configuration never reads is never judged.
{
  asserts,
  genMerge,
  lib,
}:
let
  T = genMerge.types;
  spools = T.listOf (
    T.enum "spool" [
      "warp"
      "weft"
    ]
  );
  taut = spools // {
    verify = v: if builtins.elem "weft" v then "the copy admits warp alone" else null;
  };
  sub = t: lib.types.submodule { options.y = lib.mkOption { type = t; }; };
  read =
    type: v:
    (genMerge.evalModuleTree { } [
      { options.loom = genMerge.mkOption { inherit type; }; }
      { loom = v; }
    ]).config.loom;
  refused = type: v: !(builtins.tryEval (builtins.deepSeq (read type v) null)).success;
  # a sibling whose type is an error: nixpkgs never forces it while only `y` is read
  lazySub = lib.types.submodule {
    options.y = lib.mkOption { type = taut; };
    options.z = lib.mkOption { type = throw "the unread sibling's type"; };
  };
in
{
  construct = [ "verify-copy-over-a-gen-container-inside-a-nixpkgs-submodule-is-enforced" ];
  check = asserts (
    refused (sub taut) { y = [ "weft" ]; }
    && read (sub taut) { y = [ "warp" ]; } == { y = [ "warp" ]; }
    && refused (sub (sub taut)) { y.y = [ "weft" ]; }
    && refused (lib.types.attrsOf (sub taut)) { k.y = [ "weft" ]; }
    && refused (sub (lib.types.listOf taut)) { y = [ [ "weft" ] ]; }
    && read (sub (lib.types.listOf taut)) { y = [ [ "warp" ] ]; } == { y = [ [ "warp" ] ]; }
    && refused (sub (lib.types.attrTag { t = lib.mkOption { type = taut; }; })) { y.t = [ "weft" ]; }
    && (read lazySub { y = [ "warp" ]; }).y == [ "warp" ]
  );
}
