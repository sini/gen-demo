# `a-module-function-in-a-plain-definition-beside-a-closure` — module-fn-in-plain-definition-serves-every-closure,
# den-hoag-3849t. A plain definition beside a closure holds a module function in `includes` and another at
# the nested key `cuff`: all five closures are registered, `sleeve` serves `tuck`, `hem` and `cuff`, and
# `sleeveControl` (no carrier) serves `hem` and `cuff`. Red if the plain definition is held raw again:
# three registrations, and `sleeve` serves `[ "tuck-pewter" "<raw-function>" "<raw-function>" ]`.

{
  asserts,
  sleeveRegistrations,
  sleeveServed,
  sleeveControlServed,
}:

{
  construct = [ "a-module-function-in-a-plain-definition-beside-a-closure" ];
  check = asserts (
    sleeveRegistrations == 5
    &&
      sleeveServed == [
        "tuck-pewter"
        "hem-pewter"
        "cuff-pewter"
      ]
    &&
      sleeveControlServed == [
        "hem-pewter"
        "cuff-pewter"
      ]
  );
}
