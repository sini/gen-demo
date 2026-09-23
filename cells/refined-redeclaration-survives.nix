# `refined-redeclaration-survives` — C37, den-hoag-refined-inherits-base-mint-oqrvg. `bobbin.picks`
# is declared in two modules of the staged pass with one let-bound refined type, and the kind's
# `refinements.picks` carries exactly one message. The kind's `.options` is not a read path (C17
# pins it empty). Two different refinements of one base are `refusals` row 30.
#
# C37 — den-hoag-refined-inherits-base-mint-oqrvg: `bobbin.picks` is declared
# in TWO modules of the staged pass with one let-bound refined type, and the merge
# relation keeps the refinement. The kind's `.options` is not a read path (C17 pins
# it empty), so the survivor is read off the kind's `refinements`. Two DIFFERENT
# refinements of one base are `refusals` row 30.
{ asserts, genValues }:
{
  construct = [ "C37" ];
  check = asserts (
    map (r: r.message) genValues.schema.bobbin.refinements.picks == [ "must be positive" ]
  );
}
