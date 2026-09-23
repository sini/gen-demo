# shellcheck shell=bash
# ── row 50 -- a refusal renders a float's VALUE through the one shared renderer (gen-prelude
#    `renderValue`, den-hoag-shared-refusal-renderer-6wtos) ──
# gen-view, gen-scope and gen-merge each carried their own copy of the refusal-value renderer, and
# gen-view's named every float by its type: `direction = 1.5` was refused as `<a float>`, discarding
# the value a reader acts on. The three now render through gen-prelude's `renderValue`, which prints
# a finite float by its value. Row 33's declaration; the arms differ by DIRECTION alone. The
# unplanted arm asserts the answer, the planted arm's substring is what separates the shared
# renderer from the retired copy, and the catchable arm is row 33's form.
row50='let
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
row50unplanted="${row50/DIRECTION/\"inbound\"}"
row50planted="${row50/DIRECTION/1.5}"
check "T5 row50 unplanted (a declared direction)" \
  "${row50unplanted/BODY/definition.direction}" 0 "" "$tmpdir/row50-green.err" 'inbound'
check "T5 row50 planted   (a float direction, refused by name with its value rendered)" \
  "${row50planted/BODY/builtins.deepSeq definition \"ADMITTED\"}" 1 \
  "gen-view.viewDefinition: field 'direction' is 1.5, which is not one of the declared arms" \
  "$tmpdir/row50-red.err"
check "T5 row50 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row50planted/BODY/if (builtins.tryEval (builtins.deepSeq definition \"ADMITTED\")).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row50-catch.err" 'CAUGHT'
