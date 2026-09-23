# shellcheck shell=bash
# ── row 63 -- a node VALUE where a gen-assemble identifier door takes a name is refused by name,
#    catchably (gen-assemble bkdkg U5, ADR-0025 item 1) ──
# `mkId`/`idsOf` build `"<type>:<name>"` by interpolation and used to abort past `tryEval` on a
# record (`cannot coerce a set to a string`). Each now refuses what does not interpolate under its
# own name; `idsOf` checks its names before returning the list, so a caller reading only the length
# still meets the refusal. The unplanted arm is the live control: names answer.
row63='let
  A = (builtins.getFlake (toString ./.)).inputs.gen.lib.framework.assemble;
  pewter = { name = "pewter"; };
in BODY'
check "T5 row63 unplanted (names answer at both doors; the answer is the assertion)" \
  "${row63/BODY/builtins.toJSON [ (A.mkId \"host\" \"pewter\") (A.idsOf \"host\" [ \"pewter\" \"damask\" ]) ]}" 0 "" \
  "$tmpdir/row63-green.err" '["host:pewter",["host:pewter","host:damask"]]'
check "T5 row63 planted   (a node value where mkId takes a name, refused by name)" \
  "${row63/BODY/A.mkId \"host\" pewter}" 1 \
  "gen-assemble.mkId: the name is a set, expected a string" \
  "$tmpdir/row63-red.err"
check "T5 row63 catchable  (the idsOf refusal reaches a length read and is caught by tryEval)" \
  "${row63/BODY/if (builtins.tryEval (builtins.length (A.idsOf \"host\" [ pewter ]))).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row63-catch.err" 'CAUGHT'
