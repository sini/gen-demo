# `corpus-stamp-relocation-invariant` — C21, den-hoag-ppv0z, den-hoag-cxlc0. A `thimble` composed
# the RETIRED way (`imports = [ config.schema.hank ]`, read live off the tree being declared) is
# REFUSED, catchably; the same `thimble` composed the RELOCATED way (`inherits = [ "hank" ]`,
# resolved by gen-schema's staged `evalSchema` pass) carries `hank`'s identity-bearing `selvage`,
# over the corpus's real instrument — gen-aspects' own `schemaOption`, `mkInstanceRegistry`, and
# C17's `extraModules` inlet; and the no-inherit arm does not, so the composition conjunct is not
# vacuous. The refusal's message is `refusals` row 120's.
#
# DRIVEN RED: gen-schema before den-hoag-cxlc0 composes the retired arm, which reds the first
# conjunct; seeding `evalSchema` so `parentsOf` returns `[ ]` reds the second.
{
  asserts,
  c21HeadKind,
  c21RelocatedInstance,
  c21NoInheritInstance,
}:
{
  construct = [ "C21" ];
  check = asserts (
    !(builtins.tryEval c21HeadKind.kind).success
    && builtins.elem "selvage" c21RelocatedInstance._identityKeys
    && !(builtins.elem "selvage" c21NoInheritInstance._identityKeys)
  );
}
