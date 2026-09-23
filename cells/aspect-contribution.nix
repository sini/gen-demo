# `aspect-contribution` — C16. The corpus's own aspect facts (`genAspects.graphFacts`) contributed
# through `genAssemble`'s protocol alongside the node registry's declared membership; the labelled
# graph `genGraph.labeledFrom`/`forgetLabels` produces and the selector context
# `genSelect.adapters.registry.mkContext` builds over the PUBLISHED parent, both walked; oracle 5's
# structural-helper substitution armed at C16's own non-flat assembly (`children`/`subtreeOf`
# diverge) and at C1's flat one (the node set does not).
#
# C16 — the aspect graph, assembled through the contribution protocol (ADR-0012,
# ADR-0010 §3 toolkit item). The corpus's own aspect facts, contributed alongside the
# node registry's declared membership, queried through gen-graph's labelled graph and
# gen-select's context; oracle 5's structural-helper substitution armed at C16's own
# non-flat assembly (children/subtreeOf diverge) and at C1's flat one (the node set
# does not).
{
  asserts,
  c16ArmHand,
  c16ArmToolkit,
  c16Assembled,
  c16Ctx,
  c16Facts,
  c16Lg,
  c16O5Toolkit,
  c16Union,
  ev,
  genGraph,
  genSelect,
  genValues,
}:
{
  construct = [ "C16" ];
  check = asserts (
    # O1/O2 — the facts are a GRAPH, and they assemble; containment survives.
    #
    # ★ `stitch/trim` IS A NODE, AND ITS PRESENCE IS den-hoag-sezf's WITNESS 2 READ
    # STRUCTURALLY. `aspects.stitch.trim` is a guard record, and gen-aspects' walk
    # admits a guard leaf as a node. Pre-fix the two cross-module definitions merged
    # to a raw `{ _type = "merge"; contents = …; }` marker, which carries no
    # `__guard` and is therefore NOT a guard leaf — so the node would be silently
    # ABSENT from this list rather than present. The membership assertion below
    # discriminates the fix from the defect on its own, without reading the value.
    c16Facts.nodes == [
      "bartack"
      "hemline"
      "hemline/facing"
      "hemline/placket"
      "hemline/placket/eyelet"
      "stitch"
      "stitch/trim"
    ]
    &&
      c16Assembled.nodeOrder == [
        "bartack"
        "hemline"
        "hemline/facing"
        "hemline/placket"
        "hemline/placket/eyelet"
        "stitch"
        "stitch/trim"
        "damask"
        "faille"
        "grosgrain"
        "pewter"
      ]
    && c16Assembled.nodes."hemline/placket".parent == "hemline"
    &&
      c16Assembled.nodes."hemline/placket".decls == {
        __edges = {
          declares = [ ];
          members = [ ];
        };
        description = "Aspect placket";
        key = "hemline/placket";
      }
    # …and the guard leaf's projection is PINNED rather than left to whatever the
    # `or` fallbacks happen to produce: its `key` is its walk id (a guard record has
    # no `key` of its own) and its `description` is the representable absence. Both
    # arms of the projection above are therefore exercised by this cell, not just the
    # nested-aspect one.
    &&
      c16Assembled.nodes."stitch/trim".decls == {
        __edges = {
          declares = [ ];
          members = [ ];
        };
        description = null;
        key = "stitch/trim";
      }
    # O3 — containment travels CHILD -> PARENT, for a guard leaf exactly as for a
    # nested aspect: the parent comes from the walk position, not from the record's
    # `meta`, which is what lets a guard leaf (whose `meta.loc` gen-merge stamps) hold
    # an edge at all.
    &&
      c16Union.parentGraph.edges == [
        {
          from = "hemline/facing";
          to = "hemline";
        }
        {
          from = "hemline/placket";
          to = "hemline";
        }
        {
          from = "hemline/placket/eyelet";
          to = "hemline/placket";
        }
        {
          from = "stitch/trim";
          to = "stitch";
        }
      ]
    # O4 — includes travel under the caller's own label.
    &&
      map (g: g.label) c16Union.edgeGraphs == [
        "declares"
        "members"
      ]
    # O5 — the two contributions are ONE assembly, membership globally declared.
    &&
      c16Assembled.nodes."pewter".decls.__edges == {
        declares = [ ];
        members = [ "stitch" ];
      }
    && c16Assembled.nodes."bartack".decls.__edges.declares == [ "hemline/placket" ]
    # O6 — the query walks the labelled graph the union produced.
    &&
      genGraph.query {
        graph = c16Lg;
        from = "hemline";
        follow = genGraph.regex.star (genGraph.regex.lit "contains");
      } == [
        "hemline"
        "hemline/facing"
        "hemline/placket"
        "hemline/placket/eyelet"
      ]
    &&
      # `members` then `contains*` — the host's DECLARED membership followed by
      # containment, so the closure now reaches the guard leaf under `stitch` as well
      # as `stitch` itself. `pewter`'s own `members` edge is still the single one
      # (asserted at O5 below); the second answer is the `contains` step, which is the
      # point of running the star rather than a `members` literal.
      genGraph.query {
        graph = c16Lg;
        from = "pewter";
        follow = genGraph.regex.seq [
          (genGraph.regex.lit "members")
          (genGraph.regex.star (genGraph.regex.lit "contains"))
        ];
      } == [
        "stitch"
        "stitch/trim"
      ]
    &&
      genGraph.query {
        graph = c16Lg;
        from = "bartack";
        follow = genGraph.regex.seq [
          (genGraph.regex.lit "declares")
          (genGraph.regex.star (genGraph.regex.lit "contains"))
        ];
      } == [
        "hemline/placket"
        "hemline/placket/eyelet"
      ]
    &&
      genGraph.roots (genGraph.forgetLabels c16Lg) == [
        "bartack"
        "damask"
        "faille"
        "grosgrain"
        "hemline"
        "pewter"
      ]
    &&
      # `stitch` is no longer a leaf and that is not an omission: its guard leaf is
      # its child, so the containment edge moved the leaf one level down.
      genGraph.leaves (genGraph.forgetLabels c16Lg) == [
        "damask"
        "faille"
        "grosgrain"
        "hemline/facing"
        "hemline/placket/eyelet"
        "stitch/trim"
      ]
    && genGraph.cycles (genGraph.forgetLabels c16Lg) == [ ]
    # O7 — the selector reads the PUBLISHED parent, not a key split.
    && genSelect.matches (genSelect.descendant (genSelect.attrs {
      key = "hemline";
    }) genSelect.star) "hemline/placket/eyelet" c16Ctx
    && genSelect.matches (genSelect.child (genSelect.attrs {
      key = "hemline";
    }) genSelect.star) "hemline/placket" c16Ctx
    && !(genSelect.matches (genSelect.child (genSelect.attrs {
      key = "hemline";
    }) genSelect.star) "hemline/placket/eyelet" c16Ctx)
    && genSelect.matches (genSelect.has (genSelect.attrs { key = "hemline/facing"; })) "hemline" c16Ctx
    &&
      c16Ctx.ancestors "hemline/placket/eyelet" == [
        "hemline/placket"
        "hemline"
      ]
    &&
      c16Ctx.children "hemline" == [
        "hemline/facing"
        "hemline/placket"
      ]
    # O8 — `entryFor` is honoured and `sel.kind` is unsupported LOUDLY.
    && !(builtins.tryEval (
      builtins.deepSeq (genSelect.matches (genSelect.kind genValues.schema.thimble) "hemline" c16Ctx) true
    )).success
    && (c16Ctx.data "hemline/placket").__identity.id_hash == c16Facts.nodeData."hemline/placket".id_hash
    && (c16Ctx.data "hemline/placket").__identity.kind == null
    # O9 — oracle 5's instance, armed both ways.
    && c16ArmHand.get "hemline" "children" == { }
    &&
      builtins.attrNames (c16ArmToolkit.get "hemline" "children") == [
        "hemline/facing"
        "hemline/placket"
      ]
    && builtins.attrNames (c16ArmHand.subtreeOf "hemline") == [ "hemline" ]
    &&
      builtins.attrNames (c16ArmToolkit.subtreeOf "hemline") == [
        "hemline"
        "hemline/facing"
        "hemline/placket"
        "hemline/placket/eyelet"
      ]
    && ev.allNodes == c16O5Toolkit.allNodes
    &&
      ev.allNodeIds == [
        "damask"
        "faille"
        "grosgrain"
        "pewter"
        "seam:pewter:grosgrain"
      ]
    && c16O5Toolkit.allNodeIds == ev.allNodeIds
    # comparator control, same run: two genuinely different node sets compare false.
    && (ev.allNodeIds == c16Facts.nodes) == false
  );
}
