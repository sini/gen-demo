# shellcheck shell=bash
# ── row 88 -- a module function whose result is not a module is refused BY NAME, catchably, at
#    gen-merge's module reader (den-hoag-w1k40; ADR-0025 item 1; nixpkgs `unifyModuleSyntax` parity) ──
# A module function applied to the module arguments must return the module itself. One returning a
# function (here, itself) used to abort inside gen-merge (`expected a set but found a function`, which
# `tryEval` cannot contain), where nixpkgs refuses it catchably (`does not look like a module`). The
# unplanted arm is the same site with a module function returning a module and asserts a STDOUT
# VALUE, so a reader that refused everything cannot pass it.
row88='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  selfM = { lib, ... }: selfM;
  goodM = _: { spool = 5; };
  spool = MODULE: (genMerge.evalModuleTree { modules = [
    { options.spool = genMerge.mkOption { type = genMerge.types.int; default = 0; }; }
    MODULE
  ]; }).config.spool;
in BODY'
check "T5 row88 unplanted (a module function returning a module merges)" \
  "${row88/BODY/builtins.toJSON (spool goodM)}" 0 "" "$tmpdir/row88-green.err" '5'
check "T5 row88 planted   (a module function returning a function is refused by name)" \
  "${row88/BODY/builtins.toJSON (spool (_: selfM))}" 1 \
  "gen-merge: module \`<gen-merge>' is a function whose result is lambda, not an attribute set" \
  "$tmpdir/row88-red.err"
check "T5 row88 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row88/BODY/if (builtins.tryEval (builtins.deepSeq (spool (_: selfM)) null)).success then \"ADMITTED\" else \"CAUGHT\"}" \
  0 "" "$tmpdir/row88-catch.err" 'CAUGHT'
