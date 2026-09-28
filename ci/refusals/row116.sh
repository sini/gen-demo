# shellcheck shell=bash
# ── row 116 -- a field outside composeWith's closed layer is refused by name, catchably: the
#    closure oracle (den-hoag-ekum1; ADR-0025 item 1) ──
# gen-bind's `composeWith` layer is a CLOSED record whose four fields are all optional, so a
# misspelling there is an extra field, and only closure refuses it. The native closed formal used to
# abort on one (`called with unexpected argument`), past `tryEval`. The layer is a `prelude.door`
# now: `bindngs` beside a correct `bindings` is refused when the fold reaches the layer, naming the
# door, the field and the accepted set. The unplanted arm composes the same layer without it and
# asserts the answer. Every arm is bound in the prelude, as row 113's are.
row116='let
  bind = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.bind;
  answered = builtins.toJSON (bind.composeWith [ { bindings.spool = "linen"; } ]).bindings;
  extra = builtins.toJSON (bind.composeWith [ { bindings.spool = "linen"; bindngs.spool = "linen"; } ]).bindings;
  caught = if (builtins.tryEval (builtins.seq (bind.composeWith [ { bindings.spool = "linen"; bindngs.spool = "linen"; } ]) null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row116 unplanted (a composeWith layer with only its own fields composes)" \
  "${row116/BODY/answered}" 0 "" "$tmpdir/row116-green.err" '{"spool":"linen"}'
check "T5 row116 planted   (a field outside the closed layer is refused by name)" \
  "${row116/BODY/extra}" 1 \
  "gen-bind.composeWith: 'bindngs' is not an option of this door; the options are closed (accepted: 'bindings', 'provenance', 'contracts', 'mergeStrategies') (in prelude.checkOptions)" \
  "$tmpdir/row116-red.err"
check "T5 row116 catchable  (the extra field is caught by tryEval when the fold reaches the layer, not an abort)" \
  "${row116/BODY/caught}" 0 "" "$tmpdir/row116-catch.err" 'CAUGHT'
