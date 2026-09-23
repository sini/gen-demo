# `federated-link` — C11. The locally-declared capability equals what the requirer resolves to after
# the exchange (ADR-0027's equivalence survival).
#
# C11 — a packaged subgraph, federated: the capability declared locally equals
# the capability the requirer resolves to after the exchange (ADR-0027's equivalence
# survival). gen-link ships no adapter/lens surface, measured (README finding), so
# `link` substitutes for the absent adapter.
{
  asserts,
  federated,
  lib,
  selvageProvides,
}:
{
  construct = [ "C11" ];
  check = asserts (
    selvageProvides == [
      "warp"
      "weft"
    ]
    &&
      federated.resolved == {
        "loom/braid" = [
          "warp"
          "weft"
        ];
      }
    &&
      builtins.attrNames federated.nodes == [
        "loom/braid"
        "mill/stitch"
      ]
    &&
      federated.graph.edges == [
        {
          from = "loom/braid";
          to = "mill/stitch";
        }
      ]
    && (builtins.head federated.bound).relata == { selvageReq = "mill/stitch"; }
    && lib.all (n: lib.hasPrefix "aspect:" n.identity) (builtins.attrValues federated.nodes)
  );
}
