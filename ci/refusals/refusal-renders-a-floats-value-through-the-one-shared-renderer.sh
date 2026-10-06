# shellcheck shell=bash
# ── row 50 -- a refusal renders a float's VALUE through the one shared renderer (gen-prelude
#    `renderValue`, den-hoag-shared-refusal-renderer-6wtos) ──
# gen-view, gen-scope and gen-merge each carried their own copy of the refusal-value renderer, and
# gen-view's named every float by its type: `direction = 1.5` was refused as `<a float>`, discarding
# the value a reader acts on. The three now render through gen-prelude's `renderValue`, which prints
# a finite float by its value. Row 33's declaration; the arms differ by DIRECTION alone. The
# unplanted arm asserts the answer, the planted arm's substring is what separates the shared
# renderer from the retired copy, and the catchable arm is row 33's form.
row_refusal_renders_a_floats_value_through_the_one_shared_renderer='let
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
row_refusal_renders_a_floats_value_through_the_one_shared_rendererunplanted="${row_refusal_renders_a_floats_value_through_the_one_shared_renderer/DIRECTION/\"inbound\"}"
row_refusal_renders_a_floats_value_through_the_one_shared_rendererplanted="${row_refusal_renders_a_floats_value_through_the_one_shared_renderer/DIRECTION/1.5}"
check "T5 refusal-renders-a-floats-value-through-the-one-shared-renderer unplanted (a declared direction)" \
  "${row_refusal_renders_a_floats_value_through_the_one_shared_rendererunplanted/BODY/definition.direction}" 0 "" "$tmpdir/refusal-renders-a-floats-value-through-the-one-shared-renderer-green.err" 'inbound'
check "T5 refusal-renders-a-floats-value-through-the-one-shared-renderer planted   (a float direction, refused by name with its value rendered)" \
  "${row_refusal_renders_a_floats_value_through_the_one_shared_rendererplanted/BODY/builtins.deepSeq definition \"ADMITTED\"}" 1 \
  "gen-view.viewDefinition: field 'direction' is 1.5, which is not one of the declared arms" \
  "$tmpdir/refusal-renders-a-floats-value-through-the-one-shared-renderer-red.err"
check "T5 refusal-renders-a-floats-value-through-the-one-shared-renderer catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_refusal_renders_a_floats_value_through_the_one_shared_rendererplanted/BODY/if (builtins.tryEval (builtins.deepSeq definition \"ADMITTED\")).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/refusal-renders-a-floats-value-through-the-one-shared-renderer-catch.err" 'CAUGHT'
