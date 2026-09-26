# shellcheck shell=bash
# ── row 97 -- a mint refusal names its KIND and its LABEL (gen-identity, den-hoag-xvww) ──
# A lambda in an identity position was refused by type alone: "a lambda in an identity position",
# with nothing saying which kind was being minted or which label held it, so a caller minting over
# several relata could not tell which was at fault. The refusal now ends `; kind "<kind>", label
# "<label>"`. The plant sits under `spool`, the label walked SECOND (labels are walked in name
# order), so a frame that named the first label, or a fixed one, cannot pass; the wanted text is one
# line carrying the type, the kind and the label together. The unplanted arm is the same mint with a
# string under `spool`, and asserts the identity.
row97='let
  inherit ((builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.identity) hashIdentity;
in hashIdentity "thimble" [ "spool" "bobbin" ] (l: if l == "spool" then SPOOL else "linen")'
row97unplanted="${row97/SPOOL/\"pewter\"}"
row97planted="${row97/SPOOL/(x: x)}"
check "T5 row97 unplanted (a string under spool mints, and the identity is the assertion)" \
  "$row97unplanted" 0 "" "$tmpdir/row97-green.err" \
  'thimble:c1f12d31e4a4b8e053cda1ee3fa8e89b62c218bbef89ecde7573778606ce6c23'
check "T5 row97 planted   (a lambda under spool, refused naming the kind and the label)" \
  "builtins.deepSeq ($row97planted) \"ADMITTED\"" 1 \
  'identity: a lambda in an identity position; kind "thimble", label "spool"' \
  "$tmpdir/row97-red.err"
check "T5 row97 catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval ($row97planted)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/row97-catch.err" 'CAUGHT'
