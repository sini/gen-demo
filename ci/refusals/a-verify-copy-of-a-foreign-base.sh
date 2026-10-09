# shellcheck shell=bash
# ── a `// { verify }` copy of a nixpkgs base keeps the base's check (mirrors `foreign-verify-copy`) ──
# nixpkgs refuses `5` at `lib.types.attrs` by name; the copy used to abort uncatchably in the base's
# raw merge (`expected a set but found an integer`), because its `verify` read as a gen leaf's and
# the base's own check was skipped. The unplanted arm is the same copy given a set and prints it,
# so a fold refusing everything cannot pass; the catchable arm holds that the refusal is a throw.
row_a_verify_copy_of_a_foreign_base='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
  read = v: (genMerge.evalModuleTree { } [
      { options.spool = genMerge.mkOption { type = lib.types.attrs // { verify = _: null; }; }; }
      { spool = v; }
    ]).config.spool;
  green = (read { warp = "sateen"; }).warp;
  planted = builtins.deepSeq (read 5) "SERVED";
  caught = if (builtins.tryEval planted).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 a-verify-copy-of-a-foreign-base unplanted (the copy given a set its base admits)" \
  "${row_a_verify_copy_of_a_foreign_base/BODY/green}" 0 "" "$tmpdir/a-verify-copy-of-a-foreign-base-green.err" 'sateen'
check "T5 a-verify-copy-of-a-foreign-base planted   (the copy given a value its base rejects is refused by name)" \
  "${row_a_verify_copy_of_a_foreign_base/BODY/planted}" 1 \
  "gen-merge: a definition for option \`spool' is not of type \`attribute set'" \
  "$tmpdir/a-verify-copy-of-a-foreign-base-red.err"
check "T5 a-verify-copy-of-a-foreign-base catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_a_verify_copy_of_a_foreign_base/BODY/caught}" 0 "" "$tmpdir/a-verify-copy-of-a-foreign-base-catch.err" 'CAUGHT'
