# shellcheck shell=bash
# ── row 40 -- a label outside L-hat at `labelOrder.precedes` is refused by name (gen-view par76,
#    ADR-0025 item 1) ──
# `precedes` read `ranks.${l}` for any label, so a name that is not a letter aborted uncatchably
# (`attribute 'selvage' missing`). The arms differ by the second label alone; the unplanted arm
# asserts the order's answer, so a library refusing every comparison cannot pass it.
row40='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  labels = genView.edgeLabels { letters = [ "tacks" "gathers" ]; };
  order = genView.labelOrder { alphabet = labels; layers = [ [ "gathers" ] [ "tacks" ] ]; endOfPath = -1; };
  answer = if order.precedes "gathers" LABEL then "gathers-first" else "not-ordered";
in BODY'
row40unplanted="${row40/LABEL/\"tacks\"}"
row40planted="${row40/LABEL/\"selvage\"}"
check "T5 row40 unplanted (two letters; the order's answer is the assertion)" \
  "${row40unplanted/BODY/answer}" 0 "" "$tmpdir/row40-green.err" 'gathers-first'
check "T5 row40 planted   (a name that is not a letter, refused by name)" \
  "${row40planted/BODY/answer}" 1 \
  "gen-view.labelOrder: 'selvage' is not a label of L̂ (gathers, tacks, or \`\$\`)" \
  "$tmpdir/row40-red.err"
check "T5 row40 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row40planted/BODY/if (builtins.tryEval answer).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row40-catch.err" 'CAUGHT'
