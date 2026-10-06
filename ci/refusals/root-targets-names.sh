# shellcheck shell=bash
# ── row 42 -- a root target's names are refused where the target is built (gen-view h0e7t) ──
# `placement.targets.root` checked only that `scope` and `channel` were present, so a lambda
# channel built a target and the abort came later, uncatchably, at whichever consumer interpolated
# it (`targetKey`, `writesOf`, `edgeSortKey`). The constructor now refuses a non-string or empty
# name by name, and the consumers refuse a hand-built target the same way. The two arms differ by
# the CHANNEL value only; the unplanted arm asserts the rendered key, so a library refusing every
# target cannot pass it. The key is the JSON of its names since gen-view qf55g (it was the
# separator join `root:pewter/settings`), re-pointed as row 26 was.
row_root_targets_names='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  target = genView.placement.targets.root { scope = "pewter"; channel = CHANNEL; };
in BODY'
row_root_targets_namesunplanted="${row_root_targets_names/CHANNEL/\"settings\"}"
row_root_targets_namesplanted="${row_root_targets_names/CHANNEL/(x: x)}"
check "T5 root-targets-names unplanted (a string channel keys the target)" \
  "${row_root_targets_namesunplanted/BODY/genView.placement.targetKey target}" 0 "" "$tmpdir/root-targets-names-green.err" '["root","pewter","settings"]'
check "T5 root-targets-names planted   (a lambda channel, refused by name at construction)" \
  "${row_root_targets_namesplanted/BODY/builtins.deepSeq target \"ADMITTED\"}" 1 \
  "gen-view.targets.root: field 'channel' is <a lambda>" \
  "$tmpdir/root-targets-names-red.err"
check "T5 root-targets-names catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_root_targets_namesplanted/BODY/if (builtins.tryEval (builtins.deepSeq target \"ADMITTED\")).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/root-targets-names-catch.err" 'CAUGHT'
