# shellcheck shell=bash
# ── row 2 -- a policy relatum not in `frozen` (mirrors C5's program) ──
row_policy_relatum_not_in_frozen='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genProgram = gen.lib.framework.program;
  mkProg = frozenList: genProgram.program frozenList [
      { head = "nap:pewter"; relata = [ "pewter" ]; }
      { head = "piping:grosgrain:faille"; pos = [ "nap:pewter" ]; neg = [ "scotched:pewter" ]; relata = [ "grosgrain" "faille" ]; }
    ];
in builtins.toJSON (mkProg FROZEN).atoms'
check "T5 policy-relatum-not-in-frozen unplanted (faille frozen)" "${row_policy_relatum_not_in_frozen/FROZEN/[ \"pewter\" \"damask\" \"grosgrain\" \"faille\" ]}" 0 "" \
  "$tmpdir/policy-relatum-not-in-frozen-green.err" '["nap:pewter","piping:grosgrain:faille","scotched:pewter"]'
check "T5 policy-relatum-not-in-frozen planted   (faille not frozen)" "${row_policy_relatum_not_in_frozen/FROZEN/[ \"pewter\" \"damask\" \"grosgrain\" ]}" 1 \
  "gen-program: 'faille' is not in the frozen set of relata that strictly earlier passes settled, so it does not resolve" \
  "$tmpdir/policy-relatum-not-in-frozen-red.err"
