# `corpus-stamp-relocation-invariant` — C21, den-hoag-ppv0z. The EQUALITY half. A `thimble` composed
# the RETIRED way (`imports = [ config.schema.hank ]`, read live off the tree being declared) and
# the RELOCATED way (`inherits = [ "hank" ]`, resolved by gen-schema's staged `evalSchema` pass)
# mint the SAME `id_hash`, over the corpus's real instrument — gen-aspects' own `schemaOption`,
# `mkInstanceRegistry`, and C17's `extraModules` inlet. Relational, never a literal digest: the
# digests this pair was designed against were measured at another lock, and asserting one here would
# relay a figure across a rev boundary. The retired arm is APPARATUS, not a survival of the migrated
# class — the reference value has to be built the old way or there is nothing for the new way to be
# compared against.
#
# C21 — the EQUALITY cell: the relocated spelling mints the stamp the retired
# one did. This is the half that pins what the value must be when unperturbed, and
# without it the discriminator below asserts nothing — a perturbation that moves a
# value proves nothing unless something says what the unmoved value is.
# DRIVEN RED: seeding gen-schema's `evalSchema` so `parentsOf` returns `[ ]` (the
# `inherits` built-in dropped) reds THIS cell and leaves the discriminator green.
{
  asserts,
  c21HeadIdhash,
  c21RelocatedIdhash,
}:
{
  construct = [ "C21" ];
  check = asserts (c21RelocatedIdhash == c21HeadIdhash);
}
