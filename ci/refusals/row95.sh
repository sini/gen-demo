# shellcheck shell=bash
# ── row 95 -- a non-type in an ELEMENT position is refused BY NAME, catchably, where a fold demands
#    the element (den-hoag-m074d; ADR-0025 item 1) ──
# `types.enum` left bare is a constructor, not a type. As a container's element (`attrsOf types.enum`)
# it was accepted silently and every definition returned unchecked: `bolts.warp` read `sateen`
# whatever the "type" said. The unplanted arm applies the same constructor and asserts a STDOUT VALUE,
# so a fold that refused every element cannot pass it; the planted arm's message names the element's
# position and the reason. Every addressing is bound in the prelude: a `}` inside a
# `${row95/BODY/...}` replacement would end the expansion early.
row95='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  read = type: (genMerge.evalModuleTree { modules = [
    { options.bolts = genMerge.mkOption { inherit type; }; }
    { bolts.warp = "sateen"; }
  ]; }).config.bolts;
  applied = (read (genMerge.types.attrsOf (genMerge.types.enum "e" [ "sateen" ]))).warp;
  bare = read (genMerge.types.attrsOf genMerge.types.enum);
  planted = builtins.toJSON bare;
  caught = if (builtins.tryEval (builtins.deepSeq bare null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row95 unplanted (an applied constructor is an element type, and admits)" \
  "${row95/BODY/applied}" 0 "" "$tmpdir/row95-green.err" 'sateen'
check "T5 row95 planted   (a bare constructor as an element type is refused by name)" \
  "${row95/BODY/planted}" 1 \
  'gen-merge: option `bolts.warp'"'"' is folded through an element type that is a function, not a type' "$tmpdir/row95-red.err"
check "T5 row95 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row95/BODY/caught}" 0 "" "$tmpdir/row95-catch.err" 'CAUGHT'
