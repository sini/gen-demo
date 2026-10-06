# shellcheck shell=bash
# ── row 97 -- a mint refusal names its KIND and its LABEL (gen-identity, den-hoag-xvww) ──
# A lambda in an identity position was refused by type alone: "a lambda in an identity position",
# with nothing saying which kind was being minted or which label held it, so a caller minting over
# several relata could not tell which was at fault. The refusal now ends `; kind "<kind>", label
# "<label>"`. The plant sits under `spool`, the label walked SECOND (labels are walked in name
# order), so a frame that named the first label, or a fixed one, cannot pass; the wanted text is one
# line carrying the type, the kind and the label together. The unplanted arm is the same mint with a
# string under `spool`, and asserts the identity.
row_mint_refusal_names_its_kind_and_its_label='let
  inherit ((builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.identity) hashIdentity;
in hashIdentity "thimble" [ "spool" "bobbin" ] (l: if l == "spool" then SPOOL else "linen")'
row_mint_refusal_names_its_kind_and_its_labelunplanted="${row_mint_refusal_names_its_kind_and_its_label/SPOOL/\"pewter\"}"
row_mint_refusal_names_its_kind_and_its_labelplanted="${row_mint_refusal_names_its_kind_and_its_label/SPOOL/(x: x)}"
check "T5 mint-refusal-names-its-kind-and-its-label unplanted (a string under spool mints, and the identity is the assertion)" \
  "$row_mint_refusal_names_its_kind_and_its_labelunplanted" 0 "" "$tmpdir/mint-refusal-names-its-kind-and-its-label-green.err" \
  'thimble:c1f12d31e4a4b8e053cda1ee3fa8e89b62c218bbef89ecde7573778606ce6c23'
check "T5 mint-refusal-names-its-kind-and-its-label planted   (a lambda under spool, refused naming the kind and the label)" \
  "builtins.deepSeq ($row_mint_refusal_names_its_kind_and_its_labelplanted) \"ADMITTED\"" 1 \
  'identity: a lambda in an identity position; kind "thimble", label "spool"' \
  "$tmpdir/mint-refusal-names-its-kind-and-its-label-red.err"
check "T5 mint-refusal-names-its-kind-and-its-label catchable  (the refusal is caught by tryEval, not an abort)" \
  "if (builtins.tryEval ($row_mint_refusal_names_its_kind_and_its_labelplanted)).success then \"ADMITTED\" else \"CAUGHT\"" 0 "" \
  "$tmpdir/mint-refusal-names-its-kind-and-its-label-catch.err" 'CAUGHT'
