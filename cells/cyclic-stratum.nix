# `cyclic-stratum` — C15. `runScc`'s iterate-from-bottom ascent over a two-member SCC with an
# external `higherStrata` dependency, which the acyclic rebuilder cannot express at all.
#
# C15 — the cyclic stratum, solved: both members reach each other and the
# external `higherStrata` supplied, by `runScc`'s iterate-from-bottom ascent rather
# than the acyclic rebuilder, which cannot express a cycle at all.
{ asserts, solvedScc }:
{
  construct = [ "C15" ];
  check = asserts (
    solvedScc == {
      chintz = [
        "chintz"
        "organdy"
        "tulle"
      ];
      tulle = [
        "chintz"
        "organdy"
        "tulle"
      ];
    }
  );
}
