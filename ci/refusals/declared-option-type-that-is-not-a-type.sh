# shellcheck shell=bash
# ── row 92 -- a declared option `type` that is not a type is refused BY NAME, catchably, where the
#    value fold demands it (den-hoag-ltnf7; ADR-0025 item 1) ──
# `types.enum` left bare is a constructor, not a type. Used as an option's `type` it was accepted
# silently and the definition returned unchecked: `spool` read `sateen` whatever the "type" said.
# The unplanted arm applies the same constructor and asserts a STDOUT VALUE, so a fold that refused
# every type cannot pass it; the planted arm's message names the option and the reason.
row_declared_option_type_that_is_not_a_type='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  read = type: (genMerge.evalModuleTree { } [
    { options.spool = genMerge.mkOption { inherit type; }; }
    { spool = "sateen"; }
  ]).config.spool;
  applied = read (genMerge.types.enum "e" [ "sateen" ]);
  bare = read genMerge.types.enum;
in BODY'
check "T5 declared-option-type-that-is-not-a-type unplanted (an applied constructor is a type, and admits)" \
  "${row_declared_option_type_that_is_not_a_type/BODY/applied}" 0 "" "$tmpdir/declared-option-type-that-is-not-a-type-green.err" 'sateen'
check "T5 declared-option-type-that-is-not-a-type planted   (a bare constructor as an option type is refused by name)" \
  "${row_declared_option_type_that_is_not_a_type/BODY/bare}" 1 \
  'gen-merge: option `spool'"'"' declares a `type'"'"' that is a function, not a type' "$tmpdir/declared-option-type-that-is-not-a-type-red.err"
check "T5 declared-option-type-that-is-not-a-type catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_declared_option_type_that_is_not_a_type/BODY/if (builtins.tryEval (builtins.deepSeq bare null)).success then \"ADMITTED\" else \"CAUGHT\"}" \
  0 "" "$tmpdir/declared-option-type-that-is-not-a-type-catch.err" 'CAUGHT'
