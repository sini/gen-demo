# `mktype-refinements` — C36, den-hoag-mx07b. `bobbin` is built through gen-aspects' `mkType` arm,
# and its refined `picks` option is named in the kind's `refinements`, which the arm used to publish
# as a literal `{ }` so that the registry enforced nothing. The instance value is read beside it;
# the refusal of `picks = 0` is `refusals` row 32.
#
# C36 — den-hoag-mx07b: a kind built through gen-aspects' `mkType` arm derives
# its `refinements` from the option plane it publishes. `bobbin.picks` is refined,
# so the kind names it; before gen-schema `ecdb380` this arm published `{ }` and the
# registry enforced nothing. The instance value is read beside it (the default).
{ asserts, genValues }:
{
  construct = [ "C36" ];
  check = asserts (
    builtins.attrNames genValues.schema.bobbin.refinements == [ "picks" ]
    && genValues.bobbins.grosgrain.picks == 1
  );
}
