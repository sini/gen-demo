# ── C5 — a policy program producing a dynamic edge (ADR-0020, ADR-0022, ADR-0033) ──
# Computed ahead of C2 because its output joins C2's edge set: ONE graph (ADR-0012), never a
# second structure for the policy stratum's output. C12's promotion is a SECOND head in this
# SAME program, never a program invented for that row.
{
  genProgram,
  genScope,
  entityEmitters,
  seamCoords,
  seamHead,
}:
let
  pipingHead = "piping:grosgrain:faille";
  # THE DYNAMIC EDGE is the piping declaration's own `label`: its head, when included, IS the edge
  # `grosgrain -> faille` labelled `piping`. It keeps its own label rather than borrowing a declared
  # one (`tacks`), so it is never mistakable for a declaration. THE PROMOTED NODE is the seam
  # declaration's own `promote`: its head, when included, is a `seam` node over the labelled tuple
  # `seamCoords`. Edge or node is declared on the rule, not read off the relata count (both are 2).
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
      relata = seamCoords;
      promote = "seam";
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
  # The labelled edges and the promotion records come from gen-program itself: `candidates` and
  # `promotions` never read the model, and `reached` and `promoted` refuse a membership the model
  # leaves undefined rather than dropping it.
  ruled = genProgram.ruleEdges mdl declarations;
  # THE PROMOTION — the included promoted head, minted in this one call beside the entity emitters
  # its relata name (ADR-0016 rulings 2, 4, 5, 7), at pass 1, strictly after their pass 0. The
  # identity is the mint's, a hash over the relata's MINTED identities; gen-program supplies none.
  minted = genScope.mintStrata { } (entityEmitters ++ map (p: p // { pass = 1; }) ruled.promoted);
  promotedIds = builtins.listToAttrs (
    map (p: {
      name = p.identifier;
      value = null;
    }) ruled.promoted
  );
  seamPromotion = {
    nodes = builtins.intersectAttrs promotedIds minted.nodes;
    edges = builtins.filter (e: promotedIds ? ${e.from}) minted.edges;
  };
  # `policyCandidates.nodes` are CANDIDATE COORDINATES, keyed by the promotion records' identifiers
  # and identity-less (ADR-0016 ruling 2: a candidate is not a node until the policy stratum
  # promotes it). A promotion record is not a node; only the mint above makes one.
  policyCandidates = {
    nodes = builtins.listToAttrs (
      map (p: {
        name = p.identifier;
        value = { };
      }) ruled.promotions
    );
    edges = ruled.candidates;
  };
  pipingEdge = ruled.reached;
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
