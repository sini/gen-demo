# `inbound-marks-agree-with-needed-by` — C88, den-hoag-nq9p. `viewRelation`'s inbound arm and
# `neededBy` are two inverse reads of one bounded relation, so a boundary mark withholds the same
# authored edge in both.
# The graph is C11's federation: its `imports` edges become the L letter of a gen-view carrier
# (`imports` is the only structural letter, `needs` the relation holding one datum per scope), and
# `neededBy` reads the same edges through the gen-scope authority, as `federated-reference-bounded`
# does.
#
# The two diagnostics have different shapes, so the comparison states its projection:
# `viewRelation`'s `withheld` is `{ scope; label; target; marks; }` over every node, and
# `neededBy`'s is `{ label; target; marks; from; }` over the direct importers of `t`. Keep the
# viewRelation entries whose target is `t` on the `imports` label, rename `scope` to `from`, and
# compare as sets. The answers correspond the same way: the inbound value past its root is
# `neededBy`'s gather.
#
# A mark at the requirer refusing `imports` withholds its edge to the provider in both reads. With
# the mark at the provider (a mark governs the edges LEAVING its node), and unmarked, both read
# whole.
{
  asserts,
  federated,
  genScope,
  genView,
  identityMark,
  selvageProvides,
}:
let
  requirer = "loom/braid";
  provider = "mill/stitch";
  inherit (federated.graph) edges;
  importIndex = builtins.foldl' (
    acc: e: acc // { ${e.from} = (acc.${e.from} or [ ]) ++ [ e.to ]; }
  ) { } edges;
  scopes = builtins.attrNames (
    builtins.listToAttrs (
      builtins.concatMap (e: [
        {
          name = e.from;
          value = null;
        }
        {
          name = e.to;
          value = null;
        }
      ]) edges
    )
  );

  self =
    genScope.eval
      {
        parseParent = _id: null;
      }
      {
        children = _self: _id: { };
        imports = _self: id: importIndex.${id} or [ ];
      }
      (
        genScope.buildRoots {
          importGraph = genScope.overlays (
            map (
              e:
              genScope.edge {
                from = e.from;
                to = e.to;
              }
            ) edges
          );
          decls = {
            ${requirer}.provided = [ ];
            ${provider}.provided = selvageProvides;
          };
        }
      );

  # The carrier that puts `imports` in L over the federated shape.
  labels = genView.edgeLabels { letters = [ "imports" ]; };
  admission = genView.labelWellFormedness {
    alphabet = labels;
    expression = "imports*";
  };
  order = genView.labelOrder {
    alphabet = labels;
    layers = [ [ "imports" ] ];
    endOfPath = -1;
  };
  carrier = genView.carrier {
    inherit labels;
    relations = genView.relations { names = [ "needs" ]; };
    relatumLabels = genView.relatumLabels { names = [ "relatum" ]; };
    labelWellFormedness = admission;
    labelOrder = order;
    dataOrder = genView.dataOrder {
      channel = "requirers";
      keyOf = c: c.scope;
    };
  };
  graph = genView.scopeGraph {
    inherit carrier scopes;
    edges.imports = id: importIndex.${id} or [ ];
    data = map (s: {
      scope = s;
      relation = "needs";
      datum = [ s ];
    }) scopes;
  };

  selvageBoundary = {
    name = "selvageBoundary";
    admits = label: label != "imports";
  };
  sealAt = who: id: if id == who then [ selvageBoundary ] else [ ];
  noMarks = _: [ ];

  inbound =
    marks:
    genView.viewRelation {
      definition = genView.compositions.topology {
        channel = "requirers";
        relation = "needs";
        root = provider;
        direction = "inbound";
        inherit admission order;
        wellFormed = _: true;
        tieSet = genView.tieSets.union;
        empty = [ ];
        combine = genView.combines.listAppend;
        dedup = genView.dedups.none;
      };
      inherit graph marks;
      orderMark = identityMark labels;
    };
  neededBy =
    marks:
    genView.neededBy {
      engine = genScope;
      name = "requirers";
      wellFormed = _: true;
      project = n: n.id;
      inherit marks;
      transitive = false;
    };

  # The stated projection of viewRelation's `withheld` onto neededBy's shape at `t`.
  projected =
    t: r:
    map (w: {
      inherit (w) label target marks;
      from = w.scope;
    }) (builtins.filter (w: w.target == t && w.label == "imports") r.withheld);
  sameSet = a: b: builtins.all (x: builtins.elem x b) a && builtins.all (x: builtins.elem x a) b;
  agree =
    marks:
    sameSet (projected provider (inbound marks)) ((neededBy marks).withheld self provider)
    && builtins.tail (inbound marks).value == (neededBy marks).compute self provider;
in
{
  construct = [ "C88" ];
  check = asserts (
    agree (sealAt requirer)
    &&
      (neededBy (sealAt requirer)).withheld self provider == [
        {
          label = "imports";
          target = provider;
          marks = [ "selvageBoundary" ];
          from = requirer;
        }
      ]
    && (inbound (sealAt requirer)).value == [ provider ]
    && agree (sealAt provider)
    &&
      (inbound (sealAt provider)).value == [
        provider
        requirer
      ]
    && agree noMarks
  );
}
