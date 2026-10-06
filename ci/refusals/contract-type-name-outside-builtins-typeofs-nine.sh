# shellcheck shell=bash
# ── row 139 -- a contract type name outside builtins.typeOf's nine is refused by name when the
#    contract is formed (den-hoag-9kj1f; ADR-0025 item 1) ──
# gen-bind's `contract.isType type` asserts `builtins.typeOf value == type`, so `type` has a closed
# codomain: the nine names `typeOf` returns. It used to form for any other value: a misspelt or
# foreign `attrset` matched no value and blamed every value checked against it, and a non-string
# aborted uncatchably building the violation message. The door decodes `type` when `isType type` is
# formed. The unplanted arm declares `set` and asserts the attrset is served. Every arm is bound in
# the prelude, as row 116's are.
row_contract_type_name_outside_builtins_typeofs_nine='let
  bind = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.bind;
  served = t: bind.contract.apply (bind.contract.isType t) { weft = "linen"; } null;
  declared = builtins.toJSON (served "set");
  misspelt = builtins.toJSON (served "attrset");
  caught = if (builtins.tryEval (builtins.seq (bind.contract.isType "attrset") null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 contract-type-name-outside-builtins-typeofs-nine unplanted (a declared type name serves a value of that kind)" \
  "${row_contract_type_name_outside_builtins_typeofs_nine/BODY/declared}" 0 "" "$tmpdir/contract-type-name-outside-builtins-typeofs-nine-green.err" '{"weft":"linen"}'
check "T5 contract-type-name-outside-builtins-typeofs-nine planted   (a type name outside typeOf's nine is refused by name at formation)" \
  "${row_contract_type_name_outside_builtins_typeofs_nine/BODY/misspelt}" 1 \
  'gen-bind.contract.isType: `type` is "attrset", not one of "bool", "float", "int", "lambda", "list", "null", "path", "set", "string"' \
  "$tmpdir/contract-type-name-outside-builtins-typeofs-nine-red.err"
check "T5 contract-type-name-outside-builtins-typeofs-nine catchable  (the unknown type name is caught by tryEval, not an abort)" \
  "${row_contract_type_name_outside_builtins_typeofs_nine/BODY/caught}" 0 "" "$tmpdir/contract-type-name-outside-builtins-typeofs-nine-catch.err" 'CAUGHT'
