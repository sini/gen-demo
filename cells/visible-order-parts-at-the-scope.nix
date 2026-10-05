# `visible-order-parts-at-the-scope` — C2 and C4, den-hoag-vvu9r. C2's graph with `faille` UNMARKED:
# `hem —tacks→ pewter` and `hem —tacks→ faille —tacks→ grosgrain` take one label into different
# scopes and part there, so van Antwerpen 2018 Fig. 1's visibility order leaves them unordered and
# `pewter` and `grosgrain` are BOTH visible; `damask`, over the higher-ranked `gathers`, is the one
# shadowed answer. A reading that compares label words alone would have `tacks·$` shadow
# `tacks·tacks·$` and answer `pewter` only. Two arms over one graph: gen-scope's `resolve`, under the
# declared key `group` and under `groupBy`, where `single` refuses the two answers as an ambiguity;
# and gen-view's `viewRelation` (a movement over the same graph held as a scope graph), whose step 6
# keeps both. `resolve-over-an-evaluated-scope` is the marked control, unmoved under either reading.
{
  asserts,
  genScope,
  genView,
  bastingRelata,
  identityMark,
}:
let
  tacks = {
    hem = [
      "pewter"
      "faille"
    ];
    faille = [ "grosgrain" ];
  };
  gathers.hem = [ "damask" ];
  shirring = {
    pewter = "pleated";
    damask = "smocked";
    grosgrain = "ruched";
  };
  scopes = [
    "hem"
    "pewter"
    "damask"
    "faille"
    "grosgrain"
  ];
  alphabet = [
    "tacks"
    "gathers"
  ];
  r = genScope.wfl;
  wf = genScope.wellFormed {
    inherit alphabet;
    expression = r.seq [
      (r.alt [
        (r.lit "tacks")
        (r.lit "gathers")
      ])
      (r.star (r.lit "tacks"))
    ];
  };
  order = genScope.labelOrder {
    inherit alphabet;
    layers = [
      [ "tacks" ]
      [ "gathers" ]
    ];
    endOfPath = -1;
  };

  scope = genScope.eval { parseParent = _: null; } {
    children = _: _: { };
    marks = _: _: [ ];
    edges-tacks = _: id: tacks.${id} or [ ];
    edges-gathers = _: id: gathers.${id} or [ ];
  } (genScope.buildRoots { parentGraph = genScope.vertices scopes; });
  resolved =
    key:
    genScope.resolve (
      {
        inherit wf order;
        mode = "visible";
        dataFilter = n: shirring.${n.id} or null;
      }
      // key
    ) scope "hem";
  resolveArm =
    key:
    let
      res = resolved key;
    in
    map (a: a.node) res.answers == [
      "pewter"
      "grosgrain"
    ]
    && map (a: a.node) res.shadowed == [ "damask" ]
    && !(builtins.tryEval (res.single "shirring")).success;

  labels = genView.edgeLabels { letters = alphabet; };
  carrier = genView.carrier {
    inherit labels;
    relations = genView.relations { names = [ "gimp" ]; };
    relatumLabels = genView.relatumLabels { names = builtins.attrNames bastingRelata; };
    labelWellFormedness = wf;
    labelOrder = order;
    dataOrder = genView.dataOrder {
      channel = "shirring";
      keyOf = _: "shirring";
    };
  };
  moved = genView.viewRelation {
    engine = genScope;
    definition = genView.compositions.movement {
      channel = "shirring";
      relation = "gimp";
      root = "hem";
      direction = "outbound";
      admission = wf;
      inherit order;
      wellFormed = _: true;
      empty = [ ];
      tieSet = genView.tieSets.union;
      combine = genView.combines.listAppend;
      dedup = genView.dedups.byDatum;
    };
    marks = _: [ ];
    orderMark = identityMark labels;
    graph = genView.scopeGraph {
      inherit carrier scopes;
      edges = {
        tacks = id: tacks.${id} or [ ];
        gathers = id: gathers.${id} or [ ];
      };
      data = map (s: {
        scope = s;
        relation = "gimp";
        datum = [ shirring.${s} ];
      }) (builtins.attrNames shirring);
    };
  };
in
{
  construct = [
    "C2"
    "C4"
  ];
  check = asserts (
    resolveArm { group = "shirring"; }
    && resolveArm { groupBy = _: "shirring"; }
    &&
      map (c: c.scope) moved.contributions == [
        "pewter"
        "grosgrain"
      ]
    && map (c: c.scope) moved.shadowed == [ "damask" ]
  );
}
