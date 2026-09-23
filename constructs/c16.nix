# ── C16 — the aspect graph itself, assembled through the contribution protocol (ADR-0012,
# ADR-0010 §3). `cnf` is the SAME value `gen.aspectCnf` above takes, bound once and reused:
# the declaration cannot be read back out of the compose result. `genValues.aspects` is the
# nested aspect root the corpus declares.
{
  genAspects,
  genAssemble,
  genGraph,
  genScope,
  genSelect,
  genValues,
  scope,
}:
let
  c16Cnf = import ../aspect-cnf.nix;
  c16Facts = genAspects.graphFacts c16Cnf genValues.aspects;

  # CONTAINMENT travels as `parentGraph`, and the edge runs CHILD -> PARENT (gen-scope groups
  # a `P` contribution's edges by `e.from` and reads `e.to` as the parent).
  c16ParentGraph = genScope.overlays (
    map (
      id:
      let
        p = c16Facts.parentOf.${id};
      in
      if p == null then genScope.vertex id else genScope.edge id p
    ) c16Facts.nodes
  );

  # INCLUDES travels under a label of the caller's own. NOT `I` — that is gen-scope's own
  # import relation between scopes, reserved by gen-assemble at the entry.
  c16IncludesGraph = genScope.overlays (
    builtins.concatMap (id: map (t: genScope.edge id t) c16Facts.includesOf.${id}) c16Facts.nodes
  );

  c16AspectGraph = {
    name = "aspect-graph";
    vertices = c16Facts.nodes; # DECLARED membership; the only key that says a node exists
    parentGraph = c16ParentGraph;
    edgeGraphs = [
      {
        label = "declares";
        graph = c16IncludesGraph;
      }
    ];
    # A STATED PROJECTION of `nodeData`, not the raw record — `eyelet`/`includes` would
    # otherwise enter the assembly twice, once as shape and once as content, and `id_hash` is
    # internal addressing only (ADR-0016 ruling 5), read through the selector context below.
    #
    # ★ TOTAL OVER `vertices`, AND THE HETEROGENEITY IT ABSORBS IS THE LIBRARY'S OWN RULING.
    # gen-aspects' membership predicate admits a GUARD LEAF as a node — `walk.nix`, verbatim:
    # "a nested aspect or a guard leaf is a node, class content is not" — and a guard record
    # carries neither `key` nor `description`, only `{ __guard; fragments; meta; name; }`. So
    # `inherit (v) key description` was total only while this corpus declared no guard at an
    # aspect key; `aspects.stitch.trim` (den-hoag-sezf's witness 2) made it abort
    # `attribute 'description' missing`. The walk id is the right name to fall back to and not
    # merely an available one: `facts.nix` rules the node id the origin-qualified WALK POSITION
    # and deliberately NOT `identity.key`, because a guard record's minted key is its
    # predicate-and-body hash rather than its position, so `id` is the only name a guard leaf
    # has here. `description = null` is gen-aspects' own representable absence, the same answer
    # `gusset` gives for a declared-but-unset class.
    decls = builtins.mapAttrs (id: v: {
      key = v.key or id;
      description = v.description or null;
    }) c16Facts.nodeData;
  };

  # THE SECOND CONTRIBUTION — the corpus's own node registry, which already declares aspect
  # membership. The union point is only exercised because something else is in the list.
  c16RegNodes = genValues.thimbles // genValues.bobbins;
  c16Registry = {
    name = "node-registry";
    vertices = builtins.attrNames c16RegNodes;
    edgeGraphs = [
      {
        label = "members";
        graph = genScope.overlays (
          builtins.concatMap (id: map (a: genScope.edge id a) (genValues.thimbles.${id}.aspects or [ ])) (
            builtins.attrNames genValues.thimbles
          )
        );
      }
    ];
  };

  c16Contributions = [
    c16AspectGraph
    c16Registry
  ];
  c16Union = genAssemble.union { contributions = c16Contributions; };
  c16Assembled = genAssemble.assemble { contributions = c16Contributions; };

  # ── the queries — §3.3's primitive table, both doors ──
  #
  # `c16Structural` is the same binding oracle 5's instance below substitutes — one call site
  # defined once and reused by both. `c16LabelGraph` reads one label's graph back off the
  # union (post-protocol); `c16Out` turns that graph into the `id -> [ids]` shape
  # `labeledFrom`'s `perLabel` wants, by the same from/to convention as containment above.
  c16Structural = genAssemble.structuralDecls c16Assembled.nodes;
  c16LabelGraph =
    label: (builtins.head (builtins.filter (g: g.label == label) c16Union.edgeGraphs)).graph;
  c16Out = g: id: map (e: e.to) (builtins.filter (e: e.from == id) g.edges);

  c16Lg = genGraph.labeledFrom {
    nodes = c16Assembled.nodeOrder;
    perLabel = {
      # THE INVERSION IS THE TOOLKIT'S, NOT HAND-ROLLED: `c16Structural.children` is
      # `genAssemble.structuralDecls`'s own `_self: id: filterAttrs (_: n: n.parent == id) nodes`.
      contains = id: builtins.attrNames (c16Structural.children null id);
      declares = c16Out (c16LabelGraph "declares");
      members = c16Out (c16LabelGraph "members");
    };
  };

  # The context is built with `parent` = the PUBLISHED `parentOf`, NOT a key split and NOT
  # `_: null` — the fix §3.4 names. `entryFor` is stated explicitly so the identity the
  # context projects is gen-aspects' own `aspectId`. `sel.kind` is left unsupported (its
  # default `null`): gen-aspects mints no kind value for an aspect node, so there is none to
  # pass and none to invent.
  c16Ctx = genSelect.adapters.registry.mkContext {
    nodes = c16Facts.nodes;
    data = id: c16Facts.nodeData.${id};
    parent = id: c16Facts.parentOf.${id};
    entryFor = id: c16Facts.nodeData.${id};
  };

  # ── oracle 5's instance — the structural-helper substitution, armed two ways ──
  #
  # C16's OWN non-flat assembly: the hand-written `children` (C1's own shape, nothing
  # contained) against the toolkit's `structuralDecls`. The node set cannot move (identity is
  # free by construction); `get`/`subtreeOf` DO move, which is the arming.
  c16ArmHand = genScope.eval {
    scope = c16Assembled;
    attributes.children = _: _: { };
  };
  c16ArmToolkit = genScope.eval {
    scope = c16Assembled;
    attributes = c16Structural;
  };

  # C1's OWN flat assembly, read as `ev`/`scope` are already bound above — never rebuilt here.
  # `structuralDecls` over C1's flat `scope.nodes` gives every node `parent == null` already,
  # so `filterAttrs (_: n: n.parent == id) nodes` is `{ }` for every id — the same answer
  # `ev`'s own hand-written `_: _: { }` gives. The node-set identity is the claim; the arming
  # pair above is what makes it non-vacuous.
  c16O5Toolkit = genScope.eval {
    inherit scope;
    attributes = genAssemble.structuralDecls scope.nodes;
  };
in
{
  inherit
    c16Cnf
    c16Facts
    c16ParentGraph
    c16IncludesGraph
    c16AspectGraph
    c16RegNodes
    c16Registry
    c16Contributions
    c16Union
    c16Assembled
    c16Structural
    c16LabelGraph
    c16Out
    c16Lg
    c16Ctx
    c16ArmHand
    c16ArmToolkit
    c16O5Toolkit
    ;
}
