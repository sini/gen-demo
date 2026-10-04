# ── C186 — A COLLAPSED DIAMOND'S PRODUCERS STAY RECOVERABLE (den-hoag-u528o) ──
# `mintStrata` collapses two emitters of one identifier into one node when their contributions agree
# (a diamond: both reach the same minted fact). The node record is closed to `{ identity; kind;
# content; }`, so which emitters produced it was unrecoverable; the result now carries a sibling
# `sites`, `{ <identifier> = [ <site> … ]; }`, one entry per settled contribution in the merge's own
# order (provenance is the graph's own contribution set, ADR-0010 §2).
#
# `eyelet` is emitted twice, by `c:eyelet-a` and `c:eyelet-b`, agreeing on kind and content, so it
# collapses to one node; `rivet` is emitted once. Fresh identifiers, in a fresh `mintStrata` run, so no
# node pinned elsewhere in this corpus moves.
{ genScope }:
let
  emit = identifier: site: {
    pass = 0;
    inherit identifier site;
    kind = "grommet";
    relata = { };
    content = {
      finish = "brass";
    };
  };
in
{
  c186Minted = genScope.mintStrata { } [
    (emit "eyelet" "c:eyelet-a")
    (emit "eyelet" "c:eyelet-b")
    (emit "rivet" "c:rivet")
  ];
}
