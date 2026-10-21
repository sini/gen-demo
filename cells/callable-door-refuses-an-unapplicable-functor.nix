# `callable-door-refuses-an-unapplicable-functor` — den-hoag-b6nyh. One definition of callability:
# every door that applies a caller's value asks gen-prelude's `isApplicable` (the fuelled
# `__functor` walk), and a door that reads the value's pattern reads it on the function the
# argument meets (`applicablePatternOf`). Driven at an apply-only door, gen-graph `reachableWhere`'s
# `pred`, and at a pattern-reading one, gen-view `viewRelation`'s mark `admits`. A nested functor
# is served as its lambda twin at both; `{ __functor = _: 5; }` and a self-returning functor are
# refused catchably at both (each aborted uncatchably before, which would red this check by killing
# its evaluation); at `admits`, a nested functor whose innermost lambda destructures is refused
# catchably.
{
  asserts,
  genGraph,
  genScope,
  genView,
  identityMark,
}:
let
  nested = leaf: { __functor = _: { __functor = _: leaf; }; };
  five = {
    __functor = _: 5;
  };
  self =
    let
      s = {
        __functor = self: self;
      };
    in
    s;
  refused = v: !(builtins.tryEval (builtins.deepSeq v true)).success;

  # the apply-only door
  pred = genGraph.reachableWhere { edges = id: if id == "a" then [ "b" ] else [ ]; } "a";

  # the pattern-reading door: a mark at "a" over a two-scope `imports` graph
  labels = genView.edgeLabels { letters = [ "imports" ]; };
  admission = genScope.wellFormed {
    alphabet = labels.letters;
    expression = "imports*";
  };
  order = genScope.labelOrder {
    alphabet = labels.letters;
    layers = [ [ "imports" ] ];
    endOfPath = -1;
  };
  graph = genView.scopeGraph {
    carrier = genView.carrier {
      inherit labels;
      relations = genView.relations { names = [ "needs" ]; };
      relatumLabels = genView.relatumLabels { names = [ "relatum" ]; };
      labelWellFormedness = admission;
      labelOrder = order;
      dataOrder = genView.dataOrder {
        channel = "needs";
        keyOf = c: c.scope;
      };
    };
    scopes = [
      "a"
      "b"
    ];
    edges.imports = id: if id == "a" then [ "b" ] else [ ];
    data =
      map
        (s: {
          scope = s;
          relation = "needs";
          datum = [ s ];
        })
        [
          "a"
          "b"
        ];
  };
  admits =
    v:
    (genView.viewRelation {
      engine = genScope;
      definition = genView.compositions.topology {
        channel = "needs";
        relation = "needs";
        root = "a";
        direction = "outbound";
        inherit admission order;
        wellFormed = _: true;
        tieSet = genView.tieSets.union;
        empty = [ ];
        combine = genView.combines.listAppend;
        dedup = genView.dedups.none;
      };
      inherit graph;
      marks =
        id:
        if id == "a" then
          [
            {
              name = "m";
              admits = v;
            }
          ]
        else
          [ ];
      orderMark = identityMark labels;
    }).value;
in
{
  construct = [ "callable-door-refuses-an-unapplicable-functor" ];
  check = asserts (
    pred (nested (_: true)) == pred (_: true)
    && refused (pred five)
    && refused (pred self)
    && admits (nested (_: true)) == admits (_: true)
    && admits (nested (_: false)) == admits (_: false)
    && admits (nested (_: true)) != admits (_: false)
    && refused (admits five)
    && refused (admits self)
    && refused (admits (nested ({ x }: true)))
  );
}
