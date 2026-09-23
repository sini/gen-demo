# ── C3 — a binding node (ADR-0016) ──
# THE ONE SOURCE for the labelled relata — C4's carrier reads its names, so the two
# declarations cannot drift apart.
{ genScope, genView }:
let
  bastingRelata = {
    warp = "pewter";
    weft = "grosgrain";
  };
  minted = genScope.mintStrata {
    kinds = { };
    emitters = [
      {
        pass = 0;
        identifier = "pewter";
        kind = "thimble";
        relata = { };
        content = {
          spool = "linen";
        };
        site = "c:pewter";
      }
      {
        pass = 0;
        identifier = "grosgrain";
        kind = "bobbin";
        relata = { };
        content = {
          gauge = "fine";
        };
        site = "c:gros";
      }
      {
        pass = 1;
        identifier = "basting:pewter:grosgrain";
        kind = "basting";
        content = {
          tension = "slack";
        };
        relata = bastingRelata;
        site = "c:basting";
      }
    ];
  };

  # THE IDENTITY ORDER MARK — one layer holding every letter of the alphabet, with `$` tied to
  # them. `viewRelation`'s `orderMark` is REQUIRED and total (M9), so "this query carries no
  # order mark" has to be WRITTEN DOWN rather than defaulted: under this mark every composite
  # rank is `(0, rank_q l)` and the lexicographic product degenerates to the declaration's own
  # order exactly, which is what keeps C4, C4b and their controls measuring what they measured
  # before the field existed. Derived from the alphabet rather than restated per site, so an
  # alphabet that gains a letter cannot leave a mark silently ranking fewer letters than the
  # order it is composed with — that mismatch is a refusal, not a default.
  identityMark =
    labels:
    genView.labelOrder {
      alphabet = labels;
      layers = [ labels.letters ];
      endOfPath = 0;
    };
in
{
  inherit bastingRelata minted identityMark;
}
