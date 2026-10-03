# shellcheck shell=bash
# ── row 139 -- a contract type name outside builtins.typeOf's nine is refused by name when the
#    contract is formed (den-hoag-9kj1f; ADR-0025 item 1) ──
# gen-bind's `contract.isType type` asserts `builtins.typeOf value == type`, so `type` has a closed
# codomain: the nine names `typeOf` returns. It used to form for any other value: a misspelt or
# foreign `attrset` matched no value and blamed every value checked against it, and a non-string
# aborted uncatchably building the violation message. The door decodes `type` when `isType type` is
# formed. The unplanted arm declares `set` and asserts the attrset is served. Every arm is bound in
# the prelude, as row 116's are.
row139='let
  bind = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.bind;
  served = t: bind.contract.apply (bind.contract.isType t) { weft = "linen"; } null;
  declared = builtins.toJSON (served "set");
  misspelt = builtins.toJSON (served "attrset");
  caught = if (builtins.tryEval (builtins.seq (bind.contract.isType "attrset") null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row139 unplanted (a declared type name serves a value of that kind)" \
  "${row139/BODY/declared}" 0 "" "$tmpdir/row139-green.err" '{"weft":"linen"}'
check "T5 row139 planted   (a type name outside typeOf's nine is refused by name at formation)" \
  "${row139/BODY/misspelt}" 1 \
  'gen-bind.contract.isType: `type` is "attrset", not one of "bool", "float", "int", "lambda", "list", "null", "path", "set", "string"' \
  "$tmpdir/row139-red.err"
check "T5 row139 catchable  (the unknown type name is caught by tryEval, not an abort)" \
  "${row139/BODY/caught}" 0 "" "$tmpdir/row139-catch.err" 'CAUGHT'
