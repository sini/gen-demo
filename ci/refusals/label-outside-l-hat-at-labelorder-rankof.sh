# shellcheck shell=bash
# ── row 40 -- a label outside L-hat at `labelOrder.rankOf` is refused by name (gen-view par76,
#    ADR-0025 item 1; the label order is gen-scope's since den-hoag-gayc D14) ──
# The rank read `ranks.${l}` for any label, so a name that is not a letter aborted uncatchably
# (`attribute 'selvage' missing`). The arms differ by the second label alone; the unplanted arm
# asserts the order's answer, so a library refusing every comparison cannot pass it.
row_label_outside_l_hat_at_labelorder_rankof='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  genScope = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  labels = genView.edgeLabels { letters = [ "tacks" "gathers" ]; };
  order = genScope.labelOrder { alphabet = labels.letters; layers = [ [ "gathers" ] [ "tacks" ] ]; endOfPath = -1; };
  answer = if order.rankOf "gathers" < order.rankOf LABEL then "gathers-first" else "not-ordered";
in BODY'
row_label_outside_l_hat_at_labelorder_rankofunplanted="${row_label_outside_l_hat_at_labelorder_rankof/LABEL/\"tacks\"}"
row_label_outside_l_hat_at_labelorder_rankofplanted="${row_label_outside_l_hat_at_labelorder_rankof/LABEL/\"selvage\"}"
check "T5 label-outside-l-hat-at-labelorder-rankof unplanted (two letters; the order's answer is the assertion)" \
  "${row_label_outside_l_hat_at_labelorder_rankofunplanted/BODY/answer}" 0 "" "$tmpdir/label-outside-l-hat-at-labelorder-rankof-green.err" 'gathers-first'
check "T5 label-outside-l-hat-at-labelorder-rankof planted   (a name that is not a letter, refused by name)" \
  "${row_label_outside_l_hat_at_labelorder_rankofplanted/BODY/answer}" 1 \
  "gen-scope.labelOrder: 'selvage' is not a label of L̂ ([\"tacks\",\"gathers\"], or \`\$\`)" \
  "$tmpdir/label-outside-l-hat-at-labelorder-rankof-red.err"
check "T5 label-outside-l-hat-at-labelorder-rankof catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_label_outside_l_hat_at_labelorder_rankofplanted/BODY/if (builtins.tryEval answer).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/label-outside-l-hat-at-labelorder-rankof-catch.err" 'CAUGHT'
