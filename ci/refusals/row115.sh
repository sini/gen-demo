# shellcheck shell=bash
# ── row 115 -- a misspelt field on a crossing binding constructor is refused by name, catchably
#    (den-hoag-ekum1; ADR-0025 item 1) ──
# gen-bind's `crossing.binding.plain` takes one closed record, `{ value; mark; }`, every field
# required. Its native closed formal used to abort on a misspelt field (`called with unexpected
# argument`), past `tryEval`. It is a `prelude.door` now: the typo `vaule` beside the correct
# `mark` is refused when the constructor is applied, naming the constructor, the field and the
# accepted set. The unplanted arm is the same constructor under the correct spelling and asserts the
# binding it builds, so a door that refused everything cannot pass it. Every arm is bound in the
# prelude, as row 113's are.
row115='let
  x = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.bind.crossing;
  answered = (x.binding.plain { value = "linen"; mark = x.mark.open; }).__binding;
  misspelt = builtins.toJSON (x.binding.plain { vaule = "linen"; value = "linen"; mark = x.mark.open; });
  caught = if (builtins.tryEval (builtins.seq (x.binding.plain { vaule = "linen"; value = "linen"; mark = x.mark.open; }) null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row115 unplanted (binding.plain with its fields spelt right builds the binding)" \
  "${row115/BODY/answered}" 0 "" "$tmpdir/row115-green.err" 'Plain'
check "T5 row115 planted   (a misspelt field on binding.plain is refused by name)" \
  "${row115/BODY/misspelt}" 1 \
  "gen-bind.crossing.binding.plain: 'vaule' is not an option of this door; the options are closed (accepted: 'value', 'mark') (in prelude.checkOptions)" \
  "$tmpdir/row115-red.err"
check "T5 row115 catchable  (the refusal is caught by tryEval at the constructor's application, not an abort)" \
  "${row115/BODY/caught}" 0 "" "$tmpdir/row115-catch.err" 'CAUGHT'
