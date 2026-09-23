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
  # THE DYNAMIC EDGE, materialised: the atom's predicate is the label, its relata are the
  # endpoints. It keeps its own label (`piping`) rather than borrowing a declared one (`tacks`),
  # so it is never mistakable for a declaration.
  pipingEdge =
    if (mdl.resolve pipingHead).included then
      [
        {
          from = "grosgrain";
          to = "faille";
          label = "piping";
        }
      ]
    else
      [ ];
  # THE PROMOTION — a coordinate promoted into a node of the one graph by giving it edges
  # (ADR-0016 ruling 2). Both the node and its edges are read off `seamCoords`/`seamSpace`,
  # never restated as literals.
  seamPromotion =
    if (mdl.resolve seamHead).included then
      {
        nodes.${seamHead} = { };
        edges = map (d: {
          from = seamHead;
          to = seamCoords.${d};
          label = d;
        }) seamSpace.product.dims;
      }
    else
      {
        nodes = { };
        edges = [ ];
      };
in
{
  inherit
    pipingHead
    prog
    mdl
    pipingEdge
    seamPromotion
    ;
}
