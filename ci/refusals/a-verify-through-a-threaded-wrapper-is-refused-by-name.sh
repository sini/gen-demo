# shellcheck shell=bash
# ── a `verify` below nixpkgs' `uniq`, and at the meet of a door copy, is read on the settled value ──
# A gen `submodule` copied with a `verify`, below `lib.types.uniq`, and the `mkOptionType` door over an `addCheck`
# copy stating the same `verify`, declared before a plain `attrsOf`: a value the `verify` rejects is refused by the
# `verify`'s own text (den-hoag-x7qe5; owner Ruling 8, ADR-0039). gen-merge served both values. The unplanted arm is
# the same declarations given a value the `verify` admits and prints it, so a fold refusing everything cannot pass;
# the catchable arm holds that the refusal is a throw.
row_a_verify_through_a_threaded_wrapper='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
  np = lib.types;
  sub = genMerge.types.submodule {
    key = "a-verify-through-a-threaded-wrapper";
    options.warp = genMerge.mkOption { type = genMerge.types.int; default = 0; };
  };
  verify = v: if (v.warp or 0) != 2 then null else "the spool rejects warp 2";
  read = types: v: (genMerge.evalModuleTree { } (
      map (type: { options.spool = genMerge.mkOption { inherit type; }; }) types ++ [ { spool = v; } ]
    )).config.spool;
  uniq = [ (np.uniq (sub // { inherit verify; })) ];
  eith = genMerge.types.either sub genMerge.types.str;
  meet = [
    (np.attrsOf (genMerge.mkOptionType (np.addCheck eith (v: (v.warp or 0) != 2) // { inherit verify; })))
    (np.attrsOf eith)
  ];
  green = "${toString (read uniq { warp = 1; }).warp} ${toString (read meet { k = { ... }: { warp = 1; }; }).k.warp}";
  planted = builtins.deepSeq (read uniq { warp = 2; }) "SERVED";
  plantedMeet = builtins.deepSeq (read meet { k = { ... }: { warp = 2; }; }) "SERVED";
  caught = if (builtins.tryEval planted).success || (builtins.tryEval plantedMeet).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 a-verify-through-a-threaded-wrapper-is-refused-by-name unplanted (the values the verify admits are served)" \
  "${row_a_verify_through_a_threaded_wrapper/BODY/green}" 0 "" "$tmpdir/a-verify-through-a-threaded-wrapper-green.err" '1 1'
check "T5 a-verify-through-a-threaded-wrapper-is-refused-by-name planted   (below uniq, the rejected value is refused by the verify)" \
  "${row_a_verify_through_a_threaded_wrapper/BODY/planted}" 1 \
  "gen-merge: a definition for option \`spool' is not of the expected type: the spool rejects warp 2" \
  "$tmpdir/a-verify-through-a-threaded-wrapper-red.err"
check "T5 a-verify-through-a-threaded-wrapper-is-refused-by-name planted   (at the meet, the rejected value is refused by the verify)" \
  "${row_a_verify_through_a_threaded_wrapper/BODY/plantedMeet}" 1 \
  "gen-merge: a definition for option \`spool.k' is not of the expected type: the spool rejects warp 2" \
  "$tmpdir/a-verify-through-a-threaded-wrapper-meet-red.err"
check "T5 a-verify-through-a-threaded-wrapper-is-refused-by-name catchable  (each refusal is caught by tryEval, not an abort)" \
  "${row_a_verify_through_a_threaded_wrapper/BODY/caught}" 0 "" "$tmpdir/a-verify-through-a-threaded-wrapper-catch.err" 'CAUGHT'
