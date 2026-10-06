# shellcheck shell=bash
# ── row 33 -- a refusal renders the value it refuses TOTALLY (gen-view p79do, ADR-0025 item 1) ──
# `direction` handed a lambda is refused by `viewDefinition`, whose message renders the value. It
# rendered through `toJSON`, which aborts on a function PAST `tryEval`, so the refusal itself became
# an uncatchable abort. The planted arm exits 1 either way, so its substring is what separates the
# named refusal from the abort, and the catchable arm is the one that measures item 1 (row 24's form).
row_refusal_renders_the_value_it_refuses_totally='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  genScope = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  definition = genView.compositions.movement {
    channel = "settings"; relation = "declares"; root = "pewter"; direction = DIRECTION;
    admission = genScope.wellFormed { alphabet = labels.letters; expression = "tacks*"; };
    order = genScope.labelOrder { alphabet = labels.letters; layers = [ [ "tacks" ] ]; endOfPath = -1; };
    wellFormed = _: true; tieSet = genView.tieSets.union; empty = [ ];
    combine = genView.combines.listAppend; dedup = genView.dedups.none;
  };
in BODY'
row_refusal_renders_the_value_it_refuses_totallyunplanted="${row_refusal_renders_the_value_it_refuses_totally/DIRECTION/\"outbound\"}"
row_refusal_renders_the_value_it_refuses_totallyplanted="${row_refusal_renders_the_value_it_refuses_totally/DIRECTION/(x: x)}"
check "T5 refusal-renders-the-value-it-refuses-totally unplanted (a declared direction)" \
  "${row_refusal_renders_the_value_it_refuses_totallyunplanted/BODY/definition.direction}" 0 "" "$tmpdir/refusal-renders-the-value-it-refuses-totally-green.err" 'outbound'
check "T5 refusal-renders-the-value-it-refuses-totally planted   (a lambda direction, refused by name)" \
  "${row_refusal_renders_the_value_it_refuses_totallyplanted/BODY/builtins.deepSeq definition \"ADMITTED\"}" 1 \
  "gen-view.viewDefinition: field 'direction' is <a lambda>" \
  "$tmpdir/refusal-renders-the-value-it-refuses-totally-red.err"
check "T5 refusal-renders-the-value-it-refuses-totally catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_refusal_renders_the_value_it_refuses_totallyplanted/BODY/if (builtins.tryEval (builtins.deepSeq definition \"ADMITTED\")).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/refusal-renders-the-value-it-refuses-totally-catch.err" 'CAUGHT'
