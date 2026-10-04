# shellcheck shell=bash
# ── row 150 -- a starting set outside the carrier is refused BY NAME at both arm heads
#    (gen-scope da163680, den-hoag-qy84y; ADR-0025 item 1) ──
# `leastModel seed program` takes a set of ground atoms: an attribute set whose every value is `true`.
# A seed carrying a payload was served by the closure arm (which reads the member's NAME and rebuilds
# canonically) and carried through by the round arm, so the two arms computed different things about a
# value the carrier does not contain. Both arms now refuse it, with the one sentence. The unary program
# routes to the closure arm and the binary one to the round arm, so each arm head is planted through the
# door; the canonical seed on each is the live control.
row150='let
  genScope = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  unary = genScope.mkProgram [ { head = "a"; } { head = "b"; pos = [ "a" ]; } ];
  binary = genScope.mkProgram [ { head = "a"; } { head = "b"; } { head = "c"; pos = [ "a" "b" ]; } ];
  model = seed: program: builtins.toJSON (builtins.attrNames (genScope.leastModel seed program).derived);
in BODY'
okU='model { q = true; } unary'
okR='model { q = true; } binary'
badU='model { q = 1; } unary'
badR='model { q = 1; } binary'
caught='if (builtins.tryEval (builtins.deepSeq (model { q = 1; } binary) true)).success then "ADMITTED" else "CAUGHT"'
check "T5 row150 unplanted (the canonical seed is admitted on the closure arm)" \
  "${row150/BODY/$okU}" 0 "" "$tmpdir/row150-green-u.err" '["a","b","q"]'
check "T5 row150 unplanted (the canonical seed is admitted on the round arm)" \
  "${row150/BODY/$okR}" 0 "" "$tmpdir/row150-green-r.err" '["a","b","c","q"]'
check "T5 row150 planted   (a payload seed is refused by name on the closure arm)" \
  "${row150/BODY/$badU}" 1 \
  "gen-scope: the seed carries a value on [\"q\"], the first of them a int. A starting set is a SET OF GROUND ATOMS" \
  "$tmpdir/row150-red-u.err"
check "T5 row150 planted   (a payload seed is refused by name on the round arm)" \
  "${row150/BODY/$badR}" 1 \
  "gen-scope: the seed carries a value on [\"q\"], the first of them a int. A starting set is a SET OF GROUND ATOMS" \
  "$tmpdir/row150-red-r.err"
check "T5 row150 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row150/BODY/$caught}" 0 "" "$tmpdir/row150-catch.err" 'CAUGHT'
