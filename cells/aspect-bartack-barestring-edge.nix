# `aspect-bartack-barestring-edge` — C16c (den-hoag-zxgan). The bare-string fourth position of
# `aspects.bartack.includes` (`gen-modules/corpus.nix`) names the same target as the by-value first
# position, `hemline/placket`, and the two forms must be INTERCHANGEABLE at the edge layer — the
# whole point of ruling a bare string a reference (den-hoag-2zjg1) rather than a distinct shape of
# content. Federating the corpus's own aspect tree through gen-link and reading `.graph` shows both
# positions land as the identical `{ from; to; }` record.
#
# `.manifest` is the WRONG instrument for this claim. gen-link's manifest records cross-origin
# resolution and hole-filling; `bartack` and `hemline/placket` are both this corpus's own nodes, so a
# same-origin edge is invisible to `.manifest` whether it is declared once, twice, or not at all —
# the instrument cannot distinguish the fixed behaviour from a regression that dropped the edge
# outright. `.graph`, the edge relation gen-link's own `normalize.edgesOf` builds directly off the
# registry (never through gen-aspects' `graphFacts`; the two libraries' fixes are independent, per
# the design spec's Gate Q1), is the one instrument that can.
#
# THE THIRD ELEMENT of `bartackEdges` below is `bartack`'s existing FOREIGN reference
# (`genAspects.keyRef "mill/stitch"`, `aspect-foreign-reference.nix`'s C16b): gen-link's `.graph`
# carries it as an edge (unlike gen-aspects' `includesOf`, which excludes a foreign reference
# entirely), because a foreign keyRef is still a reference at gen-link's layer — only unresolved,
# since no `mill`-origin source is federated here. Its presence is the reason `.graph`, unlike
# `.manifest`, sees every reference position and is therefore the right place to compare the two
# local forms against each other.
{
  asserts,
  c16Cnf,
  genLink,
  genValues,
}:
let
  federated = genLink.link {
    sources = [
      {
        registry = genValues.aspects;
        keySemantics = c16Cnf.keySemantics;
        origin = [ "corpus" ];
      }
    ];
  };
  bartackEdges = builtins.filter (e: e.from == "corpus/bartack") federated.graph.edges;
in
{
  construct = [ "bare-string-include-equals-its-by-value-control" ];
  check = asserts (
    bartackEdges == [
      {
        from = "corpus/bartack";
        to = "corpus/hemline/placket";
      }
      {
        from = "corpus/bartack";
        to = "mill/stitch";
      }
      {
        from = "corpus/bartack";
        to = "corpus/hemline/placket";
      }
    ]
    # THE CLAIM ITSELF: the by-value edge (position 0) and the bare-string edge (position 3) are
    # not merely equal in value, they are the SAME record a distinct target could not produce.
    && (builtins.elemAt bartackEdges 0) == (builtins.elemAt bartackEdges 2)
    && builtins.length bartackEdges == 3
  );
}
