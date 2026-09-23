# `aspect-foreign-reference` — C16b. The corpus declares a FOREIGN reference — `genAspects.keyRef
# "mill/stitch"`, a third position on `aspects.bartack.includes` — and the cell asserts it is
# published as a REFERENCE and never as an edge: present in `c16Facts.foreignIncludesOf` in the
# declaration's own `{ origin; path; key; }` shape, absent from `c16Facts.includesOf`, and every
# `declares` edge in the assembled contribution naming a member of its `vertices`. `aspect-cnf.nix`
# sets no `providerPrefix`, so this corpus's origin is `[ ]` and the sugar's first segment `mill`
# makes the reference foreign by construction. The population is stated because it IS one: three
# declared positions accounted for exactly once each across the three relations — one checked edge,
# one inline body, one foreign reference — over six vertices and one `declares` edge, with the
# totality control that a node declaring no foreign reference is PRESENT with an empty list rather
# than absent. The declaration was UNDECLARABLE before gen-aspects `3b6d41d`: the reference entered
# `includesOf`, became a `declares` edge to a non-member, and `genAssemble`'s
# `requireDeclaredMembership` refused the whole contribution by name.
#
# C16b — A FOREIGN REFERENCE IS PUBLISHED AS A REFERENCE AND NEVER AS AN EDGE.
# The corpus declares `keyRef "mill/stitch"` at `aspects.bartack.includes` (see
# `gen-modules/corpus.nix`): this file carries no `providerPrefix`, so the corpus's
# origin is `[ ]` — gen-link's `self`, "assigned by whoever federates me" — and the
# sugar's origin is its first segment, `mill`. gen-aspects cannot check that reference
# and no longer pretends to: it leaves `includesOf`, which now carries ONLY edges the
# library checked, and arrives in `foreignIncludesOf` in the declaration's own
# `{ origin; path; key; }` shape.
#
# ★ THIS DECLARATION WAS UNWRITABLE BEFORE. With the reference in `includesOf` it
# became a `declares` edge whose `to` is no vertex of this graph, and gen-assemble's
# `requireDeclaredMembership` refused the whole contribution by name. The cell is
# therefore red against the previous gen-aspects for two independent reasons: the
# relation it reads did not exist, and the corpus it reads did not evaluate.
#
# ★★ CARDINALITY IS STATED BECAUSE THE POPULATION IS TINY. `bartack.includes` is the
# only `includes` list in the whole corpus and it holds THREE positions — one checked
# edge, one inline body, one foreign reference. Clause 3 below is a universal over a
# population of ONE edge across SEVEN vertices, and a run that did not say so would
# be reporting a vacuous truth. Every figure here was read off this corpus, not
# copied — the seventh vertex is `stitch/trim`, the guard leaf den-hoag-sezf's
# witness 2 declares, and the totality control below covers it like any other node.
{
  asserts,
  c16AspectGraph,
  c16Assembled,
  c16Facts,
  genValues,
}:
{
  construct = [ "C16b" ];
  check = asserts (
    # O6a — the reference is PUBLISHED, in the declaration's own shape. Structured, not
    # a rendered "mill/stitch": the qualifier is recoverable without re-splitting a
    # string, which is the second source the relation exists to avoid.
    c16Facts.foreignIncludesOf."bartack" == [
      {
        origin = [ "mill" ];
        path = [ "stitch" ];
        key = "stitch";
      }
    ]
    # O6b — and it is NOT an edge. `includesOf` carries the one reference this library
    # COULD check, and nothing else; the foreign one did not merely fail to resolve, it
    # is not in this relation at all.
    && c16Facts.includesOf."bartack" == [ "hemline/placket" ]
    && !(builtins.elem "mill/stitch" c16Facts.includesOf."bartack")
    # CONTROL: the relation is TOTAL over `nodes` — a node with no foreign reference is
    # PRESENT with an empty list, so an absent key and "none declared" are not the same
    # answer, and O6a above cannot be read as "the only key that exists".
    && builtins.attrNames c16Facts.foreignIncludesOf == c16Facts.nodes
    && c16Facts.foreignIncludesOf."stitch" == [ ]
    # O6c — EVERY `declares` edge in the assembled contribution names a MEMBER. This is
    # the widening `danglingIncludeRefusal` names and `requireDeclaredMembership`
    # catches, asserted here at the contribution gen-demo actually builds.
    && builtins.all (
      e: builtins.elem e.from c16AspectGraph.vertices && builtins.elem e.to c16AspectGraph.vertices
    ) (builtins.head c16AspectGraph.edgeGraphs).graph.edges
    # CARDINALITY, all four figures from this corpus's own evaluation. The three
    # declared positions are accounted for EXACTLY ONCE across the three relations, so
    # neither clause above can pass by a position having been dropped.
    && builtins.length (builtins.head c16AspectGraph.edgeGraphs).graph.edges == 1
    && builtins.length c16AspectGraph.vertices == 7
    && builtins.length (builtins.concatLists (builtins.attrValues c16Facts.foreignIncludesOf)) == 1
    && builtins.length genValues.aspects.bartack.includes == 3
    &&
      (
        builtins.length c16Facts.includesOf."bartack"
        + builtins.length c16Facts.foreignIncludesOf."bartack"
        + builtins.length c16Facts.unresolvedIncludesOf."bartack"
      ) == 3
    # And the assembled view is UNMOVED by the new declaration: `bartack` still declares
    # exactly its one checked edge. The reference was added without widening the graph.
    && c16Assembled.nodes."bartack".decls.__edges.declares == [ "hemline/placket" ]
  );
}
