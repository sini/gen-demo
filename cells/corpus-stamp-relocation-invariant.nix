# `corpus-stamp-relocation-invariant` — C21, den-hoag-ppv0z. The EQUALITY half. A `thimble` composed
# the RETIRED way (`imports = [ config.schema.hank ]`, read live off the tree being declared) and
# the RELOCATED way (`inherits = [ "hank" ]`, resolved by gen-schema's staged `evalSchema` pass)
# carry the same identity CONTENT, over the corpus's real instrument — gen-aspects' own
# `schemaOption`, `mkInstanceRegistry`, and C17's `extraModules` inlet. The two spellings are two
# declarations (`kindEq` says so), and an instance stamp carries its kind's minted identity, so the
# stamps themselves FOLLOW `kindEq` rather than agreeing. Relational, never a literal digest. The
# retired arm is APPARATUS, not a survival of the migrated class — the reference value has to be
# built the old way or there is nothing for the new way to be compared against.
#
# C21 — the EQUALITY cell: the relocated instance, recomputed under the retired kind, IS the retired
# instance, over one closed key set; and the stamps decide exactly as `kindEq` does. The recompute
# is not a tautology: it reads the relocated instance's values at the RETIRED kind's key set, and
# the key-set conjunct closes the extra-key direction.
# DRIVEN RED: seeding gen-schema's `evalSchema` so `parentsOf` returns `[ ]` (the `inherits`
# built-in dropped) reds the content and key-set conjuncts and leaves the discriminator green. The
# law conjunct is red at a stamp keyed by the kind NAME (the two spellings then mint one identity
# while `kindEq` says two).
{
  asserts,
  c21Schema,
  c21HeadKind,
  c21RelocatedKind,
  c21HeadInstance,
  c21RelocatedInstance,
}:
{
  construct = [ "C21" ];
  check = asserts (
    c21Schema.identityHashForKind c21HeadKind c21RelocatedInstance == c21HeadInstance.id_hash
    && c21RelocatedInstance._identityKeys == c21HeadInstance._identityKeys
    &&
      (c21HeadInstance.id_hash == c21RelocatedInstance.id_hash)
      == c21Schema.kindEq c21HeadKind c21RelocatedKind
  );
}
