# `inbound-walks-the-converse-of-containment` — den-hoag-gayc U2e. A view whose alphabet carries the
# containment letter `parent` walks inbound through the one calculus: from a scope, the converse of
# `parent` steps to every scope whose parent it is (the scopes it contains).
#
# `bobbin` and `spindle` sit in `creel`; `quill` sits in `bobbin`. Inbound `parent*` from `creel`
# reaches all four, in walk order: the converse's sources are enumerated in the scope's declared
# order, so the order is the calculus's by construction. Outbound `parent*` from `quill` climbs to
# `creel`. A scope with two `parent` targets is refused at the lift in either direction. The converse
# of containment is not itself a containment (`creel` would have two `parent` targets), so it cannot
# be written by hand as a `parent` graph: the inbound answer is pinned by value instead.

{
  asserts,
  genScope,
  genView,
  identityMark,
}:

let
  labels = genView.edgeLabels { letters = [ "parent" ]; };
  admission = genScope.wellFormed {
    alphabet = labels.letters;
    expression = "parent*";
  };
  order = genScope.labelOrder {
    alphabet = labels.letters;
    layers = [ [ "parent" ] ];
    endOfPath = -1;
  };
  carrier = genView.carrier {
    inherit labels;
    relations = genView.relations { names = [ "holds" ]; };
    relatumLabels = genView.relatumLabels { names = [ "relatum" ]; };
    labelWellFormedness = admission;
    labelOrder = order;
    dataOrder = genView.dataOrder {
      channel = "contents";
      keyOf = c: c.scope;
    };
  };
  scopes = [
    "creel"
    "bobbin"
    "spindle"
    "quill"
  ];
  graphOf =
    parentOf:
    genView.scopeGraph {
      inherit carrier scopes;
      edges.parent = id: parentOf.${id} or [ ];
      data = map (s: {
        scope = s;
        relation = "holds";
        datum = [ s ];
      }) scopes;
    };
  contained = {
    bobbin = [ "creel" ];
    spindle = [ "creel" ];
    quill = [ "bobbin" ];
  };
  walk =
    direction: root: parentOf:
    (genView.viewRelation {
      engine = genScope;
      definition = genView.compositions.topology {
        channel = "contents";
        relation = "holds";
        inherit
          root
          direction
          admission
          order
          ;
        wellFormed = _: true;
        tieSet = genView.tieSets.union;
        empty = [ ];
        combine = genView.combines.listAppend;
        dedup = genView.dedups.none;
      };
      graph = graphOf parentOf;
      marks = _: [ ];
      orderMark = identityMark labels;
    }).value;
  refused = e: !(builtins.tryEval (builtins.deepSeq e e)).success;
in

{
  construct = [ "inbound-movement-under-a-mark-against-neededby" ];
  check = asserts (
    walk "inbound" "creel" contained == [
      "creel"
      "bobbin"
      "quill"
      "spindle"
    ]
    &&
      walk "outbound" "quill" contained == [
        "quill"
        "bobbin"
        "creel"
      ]
    && refused (
      walk "inbound" "creel" (
        contained
        // {
          quill = [
            "bobbin"
            "spindle"
          ];
        }
      )
    )
  );
}
