# ── C5 — a policy program producing a dynamic edge (ADR-0020, ADR-0022, ADR-0033) ──
# Computed ahead of C2 because its output joins C2's edge set: ONE graph (ADR-0012), never a
# second structure for the policy stratum's output. C12's promotion is a SECOND head in this
# SAME program, never a program invented for that row.
{
  genProgram,
  seamCoords,
  seamHead,
  seamSpace,
}:
let
  pipingHead = "piping:grosgrain:faille";
  prog = genProgram.program {
    frozen = [
      "pewter"
      "damask"
      "grosgrain"
      "faille"
    ]; # earlier passes settled these
    declarations = [
      {
        head = "nap:pewter";
        relata = [ "pewter" ];
      }
      {
        head = pipingHead;
        pos = [ "nap:pewter" ];
        neg = [ "scotched:pewter" ];
        relata = [
          "grosgrain"
          "faille"
        ];
      }
      {
        head = seamHead;
        pos = [ "nap:pewter" ];
        neg = [ "scotched:pewter" ];
        relata = map (d: seamCoords.${d}) seamSpace.product.dims;
      }
    ];
  };
  mdl = genProgram.model {
    program = prog;
    interpretation = [ ];
    complete = true;
  };
  # THE CANDIDATES — what each conditional head's declaration names, read before solving and
  # whether or not the head resolves on. C7's gate relation carries these (ADR-0008 §3's "complete
  # at registration" over every declared production; den-hoag-6s1t (iii)). The materialised values
  # below are the SAME records gated on `.included`, so the reached structure is a subset of the
  # candidates by construction.
  #
  # THE DYNAMIC EDGE: the atom's predicate is the label, its relata are the endpoints. It keeps its
  # own label (`piping`) rather than borrowing a declared one (`tacks`), so it is never mistakable
  # for a declaration.
  pipingCandidate = {
    nodes = { };
    edges = [
      {
        from = "grosgrain";
        to = "faille";
        label = "piping";
      }
    ];
  };
  # THE PROMOTION — a coordinate promoted into a node of the one graph by giving it edges
  # (ADR-0016 ruling 2). Both the node and its edges are read off `seamCoords`/`seamSpace`,
  # never restated as literals.
  seamCandidate = {
    nodes.${seamHead} = { };
    edges = map (d: {
      from = seamHead;
      to = seamCoords.${d};
      label = d;
    }) seamSpace.product.dims;
  };
  policyCandidates = {
    nodes = pipingCandidate.nodes // seamCandidate.nodes;
    edges = pipingCandidate.edges ++ seamCandidate.edges;
  };
  reachedOf =
    head: candidate:
    if (mdl.resolve head).included then
      candidate
    else
      {
        nodes = { };
        edges = [ ];
      };
  pipingEdge = (reachedOf pipingHead pipingCandidate).edges;
  seamPromotion = reachedOf seamHead seamCandidate;
in
{
  inherit
    pipingHead
    prog
    mdl
    pipingEdge
    seamPromotion
    policyCandidates
    ;
}
