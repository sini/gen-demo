# shellcheck shell=bash
# ── row 42 -- a root target's names are refused where the target is built (gen-view h0e7t) ──
# `placement.targets.root` checked only that `scope` and `channel` were present, so a lambda
# channel built a target and the abort came later, uncatchably, at whichever consumer interpolated
# it (`targetKey`, `writesOf`, `edgeSortKey`). The constructor now refuses a non-string or empty
# name by name, and the consumers refuse a hand-built target the same way. The two arms differ by
# the CHANNEL value only; the unplanted arm asserts the rendered key, so a library refusing every
# target cannot pass it. The key is the JSON of its names since gen-view qf55g (it was the
# separator join `root:pewter/settings`), re-pointed as row 26 was.
row42='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  target = genView.placement.targets.root { scope = "pewter"; channel = CHANNEL; };
in BODY'
row42unplanted="${row42/CHANNEL/\"settings\"}"
row42planted="${row42/CHANNEL/(x: x)}"
check "T5 row42 unplanted (a string channel keys the target)" \
  "${row42unplanted/BODY/genView.placement.targetKey target}" 0 "" "$tmpdir/row42-green.err" '["root","pewter","settings"]'
check "T5 row42 planted   (a lambda channel, refused by name at construction)" \
  "${row42planted/BODY/builtins.deepSeq target \"ADMITTED\"}" 1 \
  "gen-view.targets.root: field 'channel' is <a lambda>" \
  "$tmpdir/row42-red.err"
check "T5 row42 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row42planted/BODY/if (builtins.tryEval (builtins.deepSeq target \"ADMITTED\")).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row42-catch.err" 'CAUGHT'
