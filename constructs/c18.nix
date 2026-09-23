# ── C18 — A KINDED NODE SET, ASSEMBLED THROUGH THE CONTRIBUTION PROTOCOL ──
#
# C1 calls `genScope.buildRoots` DIRECTLY, and until now it had to: `assemble` supplied no
# `kinds`, so a contribution carrying `types` was accepted at the protocol boundary and
# refused one layer down by the substrate's registry check. A framework wanting kinded nodes
# had to abandon the toolkit and write the constructor call itself — which is the exact
# duplication gen-assemble exists to remove, and this corpus's C1 was the evidence.
#
# ★ IT IS A SECOND PATH OVER C1's OWN FACTS, NOT A SECOND C1. C1's `scope` still feeds C2,
# C5 and C12 unchanged; moving it onto the toolkit would put a protocol change and a corpus
# refactor in one declaration. What C18 asserts is that the two paths produce the SAME
# RECORD, which is the two-paths-one-answer shape and is what makes README *Finding 4*'s
# second and third clauses false.
#
# `c18Types` is C1's own declared kinds read back off C1's answer, so the protocol path is
# given exactly the input the direct path was given rather than a second classifier written
# here that could drift from it.
{
  genAssemble,
  genScope,
  nodes,
  scope,
}:
let
  c18Types = builtins.mapAttrs (_: n: n.type) scope.nodes;
  c18ThroughTheProtocol =
    types:
    genAssemble.assemble {
      contributions = [
        {
          name = "corpus";
          vertices = builtins.attrNames nodes;
          decls = nodes;
          inherit types;
        }
      ];
      kinds = genScope.mkKinds (
        map (n: genScope.mkKind { name = n; }) [
          "thimble"
          "bobbin"
          "seam"
        ]
      );
    };
in
{
  inherit c18Types c18ThroughTheProtocol;
}
