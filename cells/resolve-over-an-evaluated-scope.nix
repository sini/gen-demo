# `resolve-over-an-evaluated-scope` — C2, den-hoag-gayc (U1b's declaration; ADR-0008 as amended,
# ADR-0024, ADR-0026). gen-scope's one resolution calculus, `resolve`, read over an EVALUATED scope
# the corpus builds itself: every node declares its boundary marks (`marks`), and one node, `faille`,
# carries `batting`, which admits no label. The path expression is the user's own, built with the
# published constructors (`genScope.wfl`): one `tacks` or `gathers` step, then any number of
# `tacks`. Under mode `visible`, with the label order `tacks < gathers` and a competition key read off
# the answer (`groupBy`), `hem` sees `pewter`'s `shirring` over the `tacks` edge, and `damask`'s,
# reached over `gathers`, is the one shadowed answer. `grosgrain` declares `shirring` too, but the
# only edge to it leaves `faille`, whose mark withholds it: it is neither visible nor shadowed, and
# `withheld faille` names the edge and the mark.
{ asserts, genScope }:
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
  batting = {
    name = "batting";
    admits = _: false;
  };
  scope =
    genScope.eval { parseParent = _: null; }
      {
        children = _: _: { };
        marks = _: id: if id == "faille" then [ batting ] else [ ];
        edges-tacks = _: id: tacks.${id} or [ ];
        edges-gathers = _: id: gathers.${id} or [ ];
      }
      (
        genScope.buildRoots {
          parentGraph = genScope.vertices [
            "hem"
            "pewter"
            "damask"
            "faille"
            "grosgrain"
          ];
        }
      );
  alphabet = [
    "tacks"
    "gathers"
  ];
  r = genScope.wfl;
  resolution = genScope.resolve {
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
    mode = "visible";
    dataFilter = n: shirring.${n.id} or null;
    groupBy = _: "shirring";
  } scope "hem";
in
{
  construct = [ "edges-queried" ];
  check = asserts (
    map (a: {
      inherit (a) node value;
    }) resolution.answers == [
      {
        node = "pewter";
        value = "pleated";
      }
    ]
    && resolution.single "shirring" == "pleated"
    && map (a: a.node) resolution.shadowed == [ "damask" ]
    &&
      resolution.withheld "faille" == [
        {
          label = "tacks";
          target = "grosgrain";
          marks = [ "batting" ];
        }
      ]
    && resolution.withheld "hem" == [ ]
  );
}
