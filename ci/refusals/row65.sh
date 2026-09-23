# shellcheck shell=bash
# ── row 65 -- a keyRef whose reference is the wrong type is refused by name, catchably
#    (gen-aspects bkdkg U3; ADR-0025 item 1) ──
# `keyRef` takes an origin-qualified string or `{ path; origin ? [ ]; }`, each field a "/"-joined
# string or a list of strings. A node VALUE handed where the reference goes used to abort past
# `tryEval` (`attribute 'path' missing`). The unplanted arm is the live control: a reference of the
# accepted form mints its key.
row65='let
  genAspects = (builtins.getFlake (toString ./.)).inputs.gen.lib.aspects.aspects;
  r = genAspects.keyRef REF;
in BODY'
row65string='"bolt/pewter/grosgrain"'
row65value='{ name = "grosgrain"; }'
row65ok="${row65/REF/$row65string}"
row65bad="${row65/REF/$row65value}"
check "T5 row65 unplanted (a string reference mints its key)" \
  "${row65ok/BODY/r.key}" 0 "" \
  "$tmpdir/row65-green.err" 'pewter/grosgrain'
check "T5 row65 planted   (a node value in the reference position is refused by name)" \
  "${row65bad/BODY/r.key}" 1 \
  "gen-aspects.keyRef: got a set with no 'path' field, expected a reference" \
  "$tmpdir/row65-red.err"
check "T5 row65 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row65bad/BODY/if (builtins.tryEval (builtins.deepSeq r true)).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row65-catch.err" 'CAUGHT'
