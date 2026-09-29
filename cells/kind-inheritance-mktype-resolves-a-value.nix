# `kind-inheritance-mktype-resolves-a-value` — C26's `mkType` branch, den-hoag-fwoa8. The same
# `notch`/`dart` pair, staged through `evalSchema` over a schema option whose `mkType` result is a
# bare module functor that publishes no collections. `evalSchema` reads `inherits` off the kind
# value, so a result that dropped it composed nothing and said nothing; the kind entry now writes
# `inherits` on both branches. The twin without `inherits` lacks `grade`, the cell's own
# discriminator.
{
  asserts,
  c26BareMkTypeGrade,
  c26BareMkTypeInherits,
  c26BareMkTypeNoInheritHasGrade,
}:
{
  construct = [ "C26" ];
  check = asserts (
    c26BareMkTypeGrade == "waxed"
    && c26BareMkTypeInherits == [ "notch" ]
    && c26BareMkTypeNoInheritHasGrade == false
  );
}
