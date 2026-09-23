# `corpus-stamp-no-inherit-discriminator` — C21, den-hoag-ppv0z. The PERTURBATION half, and what
# stops the cell above being two agreeing arms. The same staged tree with the parent dropped mints a
# DIFFERENT stamp, so the equality is non-vacuous: the instrument is shown to discriminate on the
# exact axis the equality asserts. The perturbed arm lands on
# `thimble:d3dc9389c41b780239d34cc9e1046d74ed8ead1af294db092f7bd3e79c9cba6a` — the corpus's own
# published stamp, the one `ci/refusals.sh` row 13 pins — which is what shows the instrument is the
# corpus's and not a lookalike. Each cell was driven RED independently while the other stayed green:
# dropping the `inherits` built-in from `evalSchema` reds the equality alone, and making the
# parent's option non-identifying reds this one alone.
#
# C21 — the PERTURBATION arm, and it is what stops the cell above being two
# agreeing arms. Drop the inheritance from the staged tree and the stamp MOVES, so
# the equality is non-vacuous: the instrument is shown to discriminate on the exact
# axis the equality asserts, rather than asserted to.
# DRIVEN RED: making `hank`'s option `internal` (so the parent contributes no
# identity key) reds THIS cell and leaves the equality green.
{
  asserts,
  c17Pewter,
  c21HeadIdhash,
  c21NoInheritIdhash,
}:
{
  construct = [ "C21" ];
  check = asserts (
    c21NoInheritIdhash != c21HeadIdhash
    # ★ AND THE INSTRUMENT IS THE CORPUS'S, ASSERTED RATHER THAN DOCUMENTED. Strip the
    # inheritance and this tree must collapse onto the LIVE corpus node's own stamp —
    # `genValues.thimbles.pewter`, the same value C17 pins and `ci/refusals.sh` row 13
    # asserts. Without this conjunct the two cells above measure a tree that differs
    # from the corpus by exactly the parent, while the README row and this construct's
    # header state the invariant over THE CORPUS: an author editing `c21ThimbleWith`'s
    # option set moves all three arms together, both cells stay green, and the stated
    # proposition goes false with nothing red. Relational — `c17Pewter.id_hash`, never
    # a digest literal — so the no-literals ruling is untouched.
    && c21NoInheritIdhash == c17Pewter.id_hash
  );
}
