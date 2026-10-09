# `verify-copy-inside-a-nixpkgs-container` — den-hoag-dyww5. A `//` copy that replaces a `spool`
# enum's `verify` keeps the enum's `check`, and nixpkgs' `listOf` folds its element by `check` alone,
# so declared alone under it the value the copy's `verify` rejects was served, where bare and under
# gen-merge's own `listOf` it is refused. gen-merge now folds the container so the copy's `verify` is
# read: `[ "weft" ]` is refused and its passing twin `[ "warp" ]` is served. The copy declared bare is
# `type-copy-refused-by-name`'s, and is unchanged.
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
  read =
    type: v:
    (genMerge.evalModuleTree { } [
      { options.spool = genMerge.mkOption { inherit type; }; }
      { spool = v; }
    ]).config.spool;
  refused = type: v: !(builtins.tryEval (builtins.deepSeq (read type v) null)).success;
in
{
  construct = [ "verify-copy-inside-a-nixpkgs-container-is-enforced" ];
  check = asserts (
    refused (lib.types.listOf taut) [ "weft" ]
    && read (lib.types.listOf taut) [ "warp" ] == [ "warp" ]
    && refused (T.listOf taut) [ "weft" ]
    && refused taut "weft"
  );
}
