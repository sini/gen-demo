# `corpus-stamp-no-inherit-discriminator` — C21, den-hoag-ppv0z. The PERTURBATION half. The same
# staged tree with the parent dropped has a DIFFERENT closed key set from the relocated one, so the
# instrument is shown to discriminate on the axis the composition moves. It is judged on the KEY
# plane because two declarations' stamps differ whatever their keys are — a stamp inequality here
# could no longer be driven red.
#
# DRIVEN RED: making `hank`'s option non-identifying (`identity = false`, so the parent contributes no
# identity key) reds the key-set inequality. Giving `c21ThimbleWith` an
# identity-bearing option the corpus's thimble does not have reds the corpus tie's key-set conjunct.
{
  asserts,
  c17Thimble,
  c17Pewter,
  c21Schema,
  c21RelocatedInstance,
  c21NoInheritInstance,
}:
{
  construct = [ "C21" ];
  check = asserts (
    c21NoInheritInstance._identityKeys != c21RelocatedInstance._identityKeys
    # ★ AND THE INSTRUMENT IS THE CORPUS'S, ASSERTED RATHER THAN DOCUMENTED. Strip the inheritance
    # and this tree must carry the LIVE corpus node's identity: its content, recomputed under the
    # corpus's own thimble kind, is `genValues.thimbles.pewter`'s stamp (the value C17 pins), and
    # its closed key set is that node's. The key-set conjunct is the half the recompute cannot see:
    # the recompute reads only the corpus kind's keys, so an author adding an identity-bearing
    # option to `c21ThimbleWith` would leave it green.
    && c21Schema.identityHashForKind c17Thimble c21NoInheritInstance == c17Pewter.id_hash
    && c21NoInheritInstance._identityKeys == c17Pewter._identityKeys
  );
}
