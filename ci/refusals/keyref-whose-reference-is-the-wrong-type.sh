# shellcheck shell=bash
# ── row 65 -- a keyRef whose reference is the wrong type is refused by name, catchably
#    (gen-aspects bkdkg U3; ADR-0025 item 1) ──
# `keyRef` takes an origin-qualified string or `{ path; origin ? [ ]; }`, each field a "/"-joined
# string or a list of strings. A node VALUE handed where the reference goes used to abort past
# `tryEval` (`attribute 'path' missing`). The unplanted arm is the live control: a reference of the
# accepted form mints its key.
row_keyref_whose_reference_is_the_wrong_type='let
  genAspects = (builtins.getFlake (toString ./.)).inputs.gen.lib.aspects.aspects;
  r = genAspects.keyRef REF;
in BODY'
row_keyref_whose_reference_is_the_wrong_typestring='"bolt/pewter/grosgrain"'
row_keyref_whose_reference_is_the_wrong_typevalue='{ name = "grosgrain"; }'
row_keyref_whose_reference_is_the_wrong_typeok="${row_keyref_whose_reference_is_the_wrong_type/REF/$row_keyref_whose_reference_is_the_wrong_typestring}"
row_keyref_whose_reference_is_the_wrong_typebad="${row_keyref_whose_reference_is_the_wrong_type/REF/$row_keyref_whose_reference_is_the_wrong_typevalue}"
check "T5 keyref-whose-reference-is-the-wrong-type unplanted (a string reference mints its key)" \
  "${row_keyref_whose_reference_is_the_wrong_typeok/BODY/r.key}" 0 "" \
  "$tmpdir/keyref-whose-reference-is-the-wrong-type-green.err" 'pewter/grosgrain'
check "T5 keyref-whose-reference-is-the-wrong-type planted   (a node value in the reference position is refused by name)" \
  "${row_keyref_whose_reference_is_the_wrong_typebad/BODY/r.key}" 1 \
  "gen-aspects.keyRef: got a set with no 'path' field, expected a reference" \
  "$tmpdir/keyref-whose-reference-is-the-wrong-type-red.err"
check "T5 keyref-whose-reference-is-the-wrong-type catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_keyref_whose_reference_is_the_wrong_typebad/BODY/if (builtins.tryEval (builtins.deepSeq r true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/keyref-whose-reference-is-the-wrong-type-catch.err" 'CAUGHT'
