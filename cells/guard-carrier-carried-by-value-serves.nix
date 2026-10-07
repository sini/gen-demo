# `a-guard-carrier-carried-by-value` — guard-carrier-carried-by-value-serves, den-hoag-dmdou. `coat`
# includes the guard carrier `pocket` by value: both closures are registered, and `coat` serves what
# `pocket` serves where it stands. Red if a carrier value reaches the guard-record arm again: `coat`
# aborts uncatchably, `attribute 'condition' missing`.

{
  asserts,
  carriedByValueRegistrations,
  carriedByValueCoat,
  carriedByValuePocket,
}:

{
  construct = [ "a-guard-carrier-carried-by-value" ];
  check = asserts (
    carriedByValueRegistrations == 2
    &&
      carriedByValueCoat == [
        "tuck-pewter"
        "hem-pewter"
      ]
    && carriedByValueCoat == carriedByValuePocket
  );
}
