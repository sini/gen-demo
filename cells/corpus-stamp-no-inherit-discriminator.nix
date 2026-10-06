# `corpus-stamp-no-inherit-discriminator` — C21, den-hoag-ppv0z, den-hoag-cxlc0. A CONTROL, not an
# alias-landing cell: `c21NoInheritKind` is built through the explicit staged `evalSchema` pass with
# the parent omitted outright (`c21RelocatedSchema { }`) — it never composes
# `imports = [ config.schema.hank ]` and so never reaches den-hoag-cxlc0's value-test walk or its
# warning. What it controls for: that the identity-key-set equality the SIBLING cell
# (`corpus-stamp-relocation-invariant`) asserts is non-vacuous. The PERTURBATION half. The same
# staged tree with the parent dropped has a DIFFERENT closed key set from the relocated one, so the
# instrument is shown to discriminate on the axis the composition moves. It is judged on the KEY
# plane because two declarations' stamps differ whatever their keys are — a stamp inequality here
# could no longer be driven red.
#
# INVARIANT ACROSS den-hoag-cxlc0: GREEN, byte-identical derivation, at gen-schema efb32a43
# (`--override-input gen github:sini/gen/5564adb`, pre-cxlc0 entirely) and at gen-schema e249807
# (the alias, the committed lock) — the sibling cell is the live control that the SAME override DOES
# discriminate (RED at 5564adb, GREEN at the lock, same run), so this cell's flat GREEN is a real
# invariance and not a broken predicate.
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
  construct = [ "relocation-its-deprecated-spelling-aliased" ];
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
