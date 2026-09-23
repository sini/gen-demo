# `foreign-type-check` — C41, den-hoag-foreign-leaf-check-unenforced-v4h7k. A type stated in the
# foreign protocol has its `check` applied to every definition before gen-merge's own fold, as
# nixpkgs' `mergeDefinitions` does. `spool` typed `lib.types.str` used to accept `1`; it is now
# refused, beside the same option reading `sateen`; the message is `refusals` row 36's.
#
# C41 — den-hoag-foreign-leaf-check-unenforced-v4h7k: a foreign type's `check`
# is applied before gen-merge's own fold, as nixpkgs' `checkedAndMerged` does.
# `lib.types.str` used to accept `1` at every position gen-merge folds; it now
# refuses it (by name in `refusals` row 36). The refusal is read beside its control,
# the same option given a string, so a fold refusing everything cannot pass.
{
  asserts,
  genMerge,
  lib,
}:
{
  construct = [ "C41" ];
  check = asserts (
    let
      read =
        m:
        (genMerge.evalModuleTree {
          modules = [
            { options.spool = genMerge.mkOption { type = lib.types.str; }; }
            m
          ];
        }).config.spool;
    in
    !(builtins.tryEval (read {
      _file = "/demo/spool.nix";
      spool = 1;
    })).success
    && read { spool = "sateen"; } == "sateen"
  );
}
