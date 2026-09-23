# shellcheck shell=bash
# ── row 33 -- a refusal renders the value it refuses TOTALLY (gen-view p79do, ADR-0025 item 1) ──
# `direction` handed a lambda is refused by `viewDefinition`, whose message renders the value. It
# rendered through `toJSON`, which aborts on a function PAST `tryEval`, so the refusal itself became
# an uncatchable abort. The planted arm exits 1 either way, so its substring is what separates the
# named refusal from the abort, and the catchable arm is the one that measures item 1 (row 24's form).
row33='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  definition = genView.compositions.movement {
    channel = "settings"; relation = "declares"; root = "pewter"; direction = DIRECTION;
    admission = genView.labelWellFormedness { alphabet = labels; expression = "tacks*"; };
    order = genView.labelOrder { alphabet = labels; layers = [ [ "tacks" ] ]; endOfPath = -1; };
    wellFormed = _: true; tieSet = genView.tieSets.union; empty = [ ];
    combine = genView.combines.listAppend; dedup = genView.dedups.none;
  };
in BODY'
row33unplanted="${row33/DIRECTION/\"outbound\"}"
row33planted="${row33/DIRECTION/(x: x)}"
check "T5 row33 unplanted (a declared direction)" \
  "${row33unplanted/BODY/definition.direction}" 0 "" "$tmpdir/row33-green.err" 'outbound'
check "T5 row33 planted   (a lambda direction, refused by name)" \
  "${row33planted/BODY/builtins.deepSeq definition \"ADMITTED\"}" 1 \
  "gen-view.viewDefinition: field 'direction' is <a lambda>" \
  "$tmpdir/row33-red.err"
check "T5 row33 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row33planted/BODY/if (builtins.tryEval (builtins.deepSeq definition \"ADMITTED\")).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row33-catch.err" 'CAUGHT'
