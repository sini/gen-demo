# ── C1 — kinds and nodes (ADR-0012) ──
# The node union across both registries, plus C12's promoted coordinate node once C5's
# program admits it. `damask` is the one C2 reaches only across two `tacks` hops; `faille`
# is the one no DECLARED edge reaches at all, which is what makes C5's dynamic edge
# observable rather than a sentence.
{
  genScope,
  genValues,
  seamPromotion,
}:
let
  nodes = genValues.thimbles // genValues.bobbins // seamPromotion.nodes;

  scope = genScope.buildRoots {
    kinds = genScope.mkKinds (
      map (n: genScope.mkKind { name = n; }) [
        "thimble"
        "bobbin"
        "seam"
      ]
    );
    parentGraph = genScope.vertices (builtins.attrNames nodes);
    decls = nodes;
    types = builtins.mapAttrs (
      n: _:
      if genValues.thimbles ? ${n} then
        "thimble"
      else if genValues.bobbins ? ${n} then
        "bobbin"
      else
        "seam"
    ) nodes;
  };

  ev = genScope.eval {
    inherit scope;
    # A flat scope: nothing is contained in anything, so `children` selects nothing.
    attributes.children = _: _: { };
  };

  thimbles = builtins.attrNames (ev.nodesOfType "thimble");
  bobbinNodes = builtins.attrNames (ev.nodesOfType "bobbin");
  seamNodes = builtins.attrNames (ev.nodesOfType "seam");
in
{
  inherit
    nodes
    scope
    ev
    thimbles
    bobbinNodes
    seamNodes
    ;
}
