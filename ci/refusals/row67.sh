
# shellcheck shell=bash
# ── row 67 -- a keyRef string with no non-empty segment is refused by name, catchably
#    (gen-aspects den-hoag-6c5s3; ADR-0025 item 1) ──
# The string arm drops empty segments and takes the first as the origin, so `""` and `"/"` used to
# reach `builtins.head [ ]`, an abort past `tryEval`. The unplanted arm is the live control: a
# reference of the accepted form mints its key.
row67='let
  genAspects = (builtins.getFlake (toString ./.)).inputs.gen.lib.aspects.aspects;
  r = genAspects.keyRef REF;
in BODY'
row67string='"bolt/pewter/grosgrain"'
row67emptystring='""'
row67slashstring='"/"'
row67ok="${row67/REF/$row67string}"
row67empty="${row67/REF/$row67emptystring}"
row67slash="${row67/REF/$row67slashstring}"
check "T5 row67 unplanted (a string reference mints its key)" \
  "${row67ok/BODY/r.key}" 0 "" \
  "$tmpdir/row67-green.err" 'pewter/grosgrain'
check "T5 row67 planted   (an empty string reference is refused by name)" \
  "${row67empty/BODY/r.key}" 1 \
  'gen-aspects.keyRef: got the string "", which has no non-empty segment' \
  "$tmpdir/row67-red-empty.err"
check "T5 row67 planted   (an all-separator string reference is refused by name)" \
  "${row67slash/BODY/r.key}" 1 \
  'gen-aspects.keyRef: got the string "/", which has no non-empty segment' \
  "$tmpdir/row67-red-slash.err"
check "T5 row67 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row67slash/BODY/if (builtins.tryEval (builtins.deepSeq r true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row67-catch.err" 'CAUGHT'
