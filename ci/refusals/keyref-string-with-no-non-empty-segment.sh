
# shellcheck shell=bash
# ── row 67 -- a keyRef string with no non-empty segment is refused by name, catchably
#    (gen-aspects den-hoag-6c5s3; ADR-0025 item 1) ──
# The string arm drops empty segments and takes the first as the origin, so `""` and `"/"` used to
# reach `builtins.head [ ]`, an abort past `tryEval`. The unplanted arm is the live control: a
# reference of the accepted form mints its key.
row_keyref_string_with_no_non_empty_segment='let
  genAspects = (builtins.getFlake (toString ./.)).inputs.gen.lib.aspects.aspects;
  r = genAspects.keyRef REF;
in BODY'
row_keyref_string_with_no_non_empty_segmentstring='"bolt/pewter/grosgrain"'
row_keyref_string_with_no_non_empty_segmentemptystring='""'
row_keyref_string_with_no_non_empty_segmentslashstring='"/"'
row_keyref_string_with_no_non_empty_segmentok="${row_keyref_string_with_no_non_empty_segment/REF/$row_keyref_string_with_no_non_empty_segmentstring}"
row_keyref_string_with_no_non_empty_segmentempty="${row_keyref_string_with_no_non_empty_segment/REF/$row_keyref_string_with_no_non_empty_segmentemptystring}"
row_keyref_string_with_no_non_empty_segmentslash="${row_keyref_string_with_no_non_empty_segment/REF/$row_keyref_string_with_no_non_empty_segmentslashstring}"
check "T5 keyref-string-with-no-non-empty-segment unplanted (a string reference mints its key)" \
  "${row_keyref_string_with_no_non_empty_segmentok/BODY/r.key}" 0 "" \
  "$tmpdir/keyref-string-with-no-non-empty-segment-green.err" 'pewter/grosgrain'
check "T5 keyref-string-with-no-non-empty-segment planted   (an empty string reference is refused by name)" \
  "${row_keyref_string_with_no_non_empty_segmentempty/BODY/r.key}" 1 \
  'gen-aspects.keyRef: got the string "", which has no non-empty segment' \
  "$tmpdir/keyref-string-with-no-non-empty-segment-red-empty.err"
check "T5 keyref-string-with-no-non-empty-segment planted   (an all-separator string reference is refused by name)" \
  "${row_keyref_string_with_no_non_empty_segmentslash/BODY/r.key}" 1 \
  'gen-aspects.keyRef: got the string "/", which has no non-empty segment' \
  "$tmpdir/keyref-string-with-no-non-empty-segment-red-slash.err"
check "T5 keyref-string-with-no-non-empty-segment catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_keyref_string_with_no_non_empty_segmentslash/BODY/if (builtins.tryEval (builtins.deepSeq r true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/keyref-string-with-no-non-empty-segment-catch.err" 'CAUGHT'
