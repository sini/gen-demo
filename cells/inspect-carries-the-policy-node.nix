# `inspect-carries-the-policy-node` — C25 over C5's promoted seam head. The subject carries C5's
# mint as `minted`, so the seam head is a node in the IR beside the registered ones, with C5's
# minted identity, and its two edges carry a rule origin whose derivation is C5's seam rule.
{
  asserts,
  c25PolicyIr,
  seamHead,
  seamPromotion,
}:
{
  construct = [ "C25" ];
  check = asserts (
    {
      node = builtins.filter (n: n.id == seamHead) c25PolicyIr.facts.nodes;
      edges = map (e: "${e.label}:${e.src}:${e.dst}:${e.origin.kind}") (
        builtins.filter (e: e.src == seamHead) c25PolicyIr.facts.edges
      );
      heads = map (d: d.rule.head) c25PolicyIr.facts.origins."thimble:${seamHead}:pewter".derivations;
    } == {
      node = [
        {
          id = seamHead;
          kind = "seam";
          attrs = {
            inherit (seamPromotion.nodes.${seamHead}) identity;
            content = { };
          };
        }
      ];
      edges = [
        "bobbin:${seamHead}:grosgrain:rule"
        "thimble:${seamHead}:pewter:rule"
      ];
      heads = [ seamHead ];
    }
  );
}
