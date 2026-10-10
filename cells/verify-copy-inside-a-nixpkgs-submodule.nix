# `verify-copy-inside-a-nixpkgs-submodule` — den-hoag-dk6zg. A `//` copy that replaces a `spool` enum's
# `verify` keeps the enum's `check`, and a nixpkgs `submodule` evaluates its options with nixpkgs' own
# option evaluation, which reads that `check` alone, so the value the copy's `verify` rejects was served
# inside it, at any depth, under a nixpkgs `attrsOf`, as the member a nixpkgs `either` chooses, or below a
# `coercedTo`'s final member. gen-merge now reads each such option of the submodule's evaluation where
# nixpkgs reads its check, at the option's own read: `"weft"` is refused, its passing twin `"warp"` is
# served, and an option the configuration never reads is never judged.
{
  asserts,
  genMerge,
  lib,
}:
let
  T = genMerge.types;
  spool = T.enum "spool" [
    "warp"
    "weft"
  ];
  taut = spool // {
    verify = v: if v == "weft" then "the copy admits warp alone" else spool.verify v;
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
  construct = [ "verify-copy-inside-a-nixpkgs-submodule-is-enforced" ];
  check = asserts (
    refused (sub taut) { y = "weft"; }
    && read (sub taut) { y = "warp"; } == { y = "warp"; }
    && refused (sub (sub taut)) { y.y = "weft"; }
    && refused (lib.types.attrsOf (sub taut)) { k.y = "weft"; }
    && refused (lib.types.attrTag { y = lib.mkOption { type = taut; }; }) { y = "weft"; }
    && refused (sub (lib.types.either lib.types.int taut)) { y = "weft"; }
    && read (sub (lib.types.either lib.types.int taut)) { y = "warp"; } == { y = "warp"; }
    && refused (sub (lib.types.coercedTo lib.types.str (s: [ s ]) (lib.types.listOf taut))) {
      y = "weft";
    }
    && (read lazySub { y = "warp"; }).y == "warp"
  );
}
