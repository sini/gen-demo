# `attrs-unions-disjoint-contributions` — C23, den-hoag-241d7. Two modules contributing disjoint
# keys to one `attrs` option both survive. The empty value alone does not buy this — a type can
# state an empty and still state no fold — so this is the container strategy's second half and not a
# restatement of the cell above.
#
# C23 — two modules contributing DISJOINT keys to one `attrs` option both
# survive. The empty value alone does not buy this: a type can state an empty and
# still have no fold, and then the corpus's second contributor is the one that
# reds. Pinned as an equality over the whole attrset rather than a key-presence
# test, so a fold that unions the keys but loses a VALUE is caught here too.
# DRIVEN RED: a fold returning one definition reds THIS cell and leaves the
# empty-value cell above green.
{ asserts, c23Disjoint }:
{
  construct = [ "C23" ];
  check = asserts (
    c23Disjoint == {
      warp = "flax";
      weft = "tussah";
    }
  );
}
