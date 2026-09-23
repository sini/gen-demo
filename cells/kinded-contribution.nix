# `kinded-contribution` — C18. The same facts assembled by BOTH paths: C1's direct
# `genScope.buildRoots` call, and `genAssemble.assemble` with that same three-kind registry routed
# as `kinds`. The cell asserts the two records are IDENTICAL — `nodes`, `nodeOrder` and the registry
# all have to agree — with a negative control on the same comparator that changes one node's kind
# and reads false, and it reads the kinds back through the same `nodesOfType` door C1's own queries
# use, so the equality is not two sides equally empty. It also asserts `kinds` is still NOT an
# eighth contribution key: offered on a contribution it is refused by name. C1 could not be written
# through the protocol before `gen-assemble` `d08cebf`, which is what Finding 4 recorded.
#
# C18 — A KINDED NODE SET REACHES THE ASSEMBLY THROUGH THE PROTOCOL.
# C1 calls `genScope.buildRoots` directly because it had to: `assemble` supplied no
# `kinds`, so `types` — a key the contribution record declares itself TOTAL over — was
# accepted at the boundary and refused one layer down. The claim is that the toolkit
# path and the direct path now answer the SAME RECORD over the SAME FACTS, which is
# what retires the corpus's own README *Finding 4*.
#
# ★ THE CELL IS RED AGAINST THE PREVIOUS gen-assemble FOR A STRUCTURAL REASON, not a
# value mismatch: `assemble` had no `kinds` formal, so the call below is a
# `called with unexpected argument 'kinds'` abort there.
{
  asserts,
  c18ThroughTheProtocol,
  c18Types,
  genAssemble,
  genScope,
  nodes,
  scope,
  thimbles,
}:
{
  construct = [ "C18" ];
  check = asserts (
    # O1 — WHOLE-RECORD EQUALITY, both paths, C1's own facts. Not a spot-check on one
    # field: `nodes`, `nodeOrder` and the registry itself all have to agree.
    (c18ThroughTheProtocol c18Types) == scope
    # ★ NEGATIVE CONTROL, SAME COMPARATOR, SAME RUN: change ONE node's kind and the
    # equality reads false. Without it the cell passes on any comparator that says true.
    && ((c18ThroughTheProtocol (c18Types // { damask = "bobbin"; })) == scope) == false
    # O2 — and the kinds SURVIVE the protocol as kinds, read through the same evaluator
    # door C1's own queries use, so the equality above is not two sides equally empty.
    &&
      builtins.attrNames (
        (genScope.eval {
          scope = c18ThroughTheProtocol c18Types;
          attributes.children = _: _: { };
        }).nodesOfType
          "thimble"
      ) == thimbles
    # CARDINALITY, read off this corpus rather than assumed: three kinds are declared,
    # every node carries one, and the node set is the one C1 built.
    &&
      builtins.attrNames (c18ThroughTheProtocol c18Types).kinds.kinds == [
        "bobbin"
        "seam"
        "thimble"
      ]
    && builtins.all (t: t != null) (builtins.attrValues c18Types)
    && builtins.length (builtins.attrNames c18Types) == builtins.length (builtins.attrNames nodes)
    # O3 — `kinds` is still NOT an eighth contribution key. Offered ON a contribution it
    # is refused by name, so the routing bought the capability without widening the
    # record the protocol declares itself total over.
    && !(builtins.tryEval (
      builtins.deepSeq (genAssemble.union {
        contributions = [
          {
            name = "corpus";
            vertices = builtins.attrNames nodes;
            kinds = genScope.mkKinds [ (genScope.mkKind { name = "thimble"; }) ];
          }
        ];
      }) 1
    )).success
  );
}
