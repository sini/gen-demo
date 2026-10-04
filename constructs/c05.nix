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
  # THE DYNAMIC EDGE is the piping declaration's own `label`: its head, when included, IS the edge
  # `grosgrain -> faille` labelled `piping`. It keeps its own label rather than borrowing a declared
  # one (`tacks`), so it is never mistakable for a declaration.
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
      label = "piping";
    }
    {
      head = seamHead;
      pos = [ "nap:pewter" ];
      neg = [ "scotched:pewter" ];
      relata = map (d: seamCoords.${d}) seamSpace.product.dims;
    }
  ];
  prog =
    genProgram.program
      [
        "pewter"
        "damask"
        "grosgrain"
        "faille"
      ] # earlier passes settled these
      declarations;
  mdl = genProgram.model {
    prior = null;
    program = prog;
    interpretation = [ ];
    complete = true;
  };
  # THE CANDIDATES — what each conditional head's declaration names, read before solving and
  # whether or not the head resolves on. C7's gate relation carries these (ADR-0008 §3's "complete
  # at registration" over every declared production; den-hoag-6s1t (iii)). The reached values below
  # are the SAME records gated on the model, so the reached structure is a subset of the candidates
  # by construction.
  #
  # The labelled edges come from gen-program itself: `candidates` never reads the model, and
  # `reached` refuses a membership the model leaves undefined rather than dropping its edge.
  pipingEdges = genProgram.ruleEdges mdl declarations;
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
    inherit (seamCandidate) nodes;
    edges = pipingEdges.candidates ++ seamCandidate.edges;
  };
  # The promotion is still gated by hand: a head that becomes a NODE needs its identity from the one
  # mint, and gen-program's `ruleEdges` mints nothing.
  reachedOf =
    head: candidate:
    if (mdl.resolve head).included then
      candidate
    else
      {
        nodes = { };
        edges = [ ];
      };
  pipingEdge = pipingEdges.reached;
  seamPromotion = reachedOf seamHead seamCandidate;
in
{
  pipingDeclarations = declarations;
  inherit
    pipingHead
    prog
    mdl
    pipingEdge
    seamPromotion
    policyCandidates
    ;
}
