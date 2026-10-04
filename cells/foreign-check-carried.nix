# `foreign-check-carried` — C110, den-hoag-4ifgb. A check nixpkgs states over a gen record is carried
# through gen-merge's fold: `addCheck` over gen-merge's own `int` refuses what its added check refuses,
# and nixpkgs' `nonEmptyListOf` over a gen `submodule`, which gen-merge re-homes as its own `listOf`,
# still refuses `[ ]`. gen-merge used to serve both, reading only the gen record's own domain. Each
# refusal stands beside its passing twin, so a fold refusing everything cannot pass; where the check
# reads a nested tree it is refused by name instead, and that message is `refusals` row 126's.
{
  asserts,
  genMerge,
  lib,
}:
let
  read =
    type: v:
    (genMerge.evalModuleTree { } [
      { options.spool = genMerge.mkOption { inherit type; }; }
      { spool = v; }
    ]).config.spool;
  refused = type: v: !(builtins.tryEval (builtins.deepSeq (read type v) null)).success;
  short = lib.types.addCheck genMerge.types.int (n: n < 3);
  bolt = genMerge.types.submodule {
    options.warp = genMerge.mkOption { type = genMerge.types.str; };
  };
in
{
  construct = [ "C110" ];
  check = asserts (
    refused short 5
    && read short 2 == 2
    && refused (lib.types.nonEmptyListOf bolt) [ ]
    && read (lib.types.nonEmptyListOf bolt) [ { warp = "sateen"; } ] == [ { warp = "sateen"; } ]
  );
}
