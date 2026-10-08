# `federated-reference-bounded` — C11. A boundary mark on the federation's include edge (ADR-0026's
# fail-closed floor, read by the query authority as its `bound`). `genLink.link` declares no marks,
# so the bound is declared here directly: `genView.referenceResolution` and `genView.neededBy` over
# C11's own requirer→provider edge, with the same gen-scope authority gen-link injects.
#
# A mark at the requirer refusing `imports` withholds the edge in BOTH directions: the requirer
# resolves nothing and `withheld` names the mark, and the provider's gather loses the requirer.
# Unmarked, and with the mark at the provider (a mark governs the edges LEAVING its node), both
# read whole.
{
  asserts,
  federated,
  genScope,
  genView,
  selvageProvides,
}:
let
  requirer = "loom/braid";
  provider = "mill/stitch";
  inherit (federated.graph) edges;
  importIndex = builtins.foldl' (
    acc: e: acc // { ${e.from} = (acc.${e.from} or [ ]) ++ [ e.to ]; }
  ) { } edges;
  self =
    genScope.eval
      {
        parseParent = _id: null;
      }
      {
        children = _self: _id: { };
        imports = _self: id: importIndex.${id} or [ ];
        # The evaluation's boundary floor, read by the resolution authority in every resolution
        # (ADR-0026; den-hoag-gayc D1). The cell's marks ride the construct's `marks` (the query's
        # `bound`), so the floor states none.
        marks = _self: _id: [ ];
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

  selvageBoundary = {
    name = "selvageBoundary";
    admits = label: label != "imports";
  };
  sealAt = who: id: if id == who then [ selvageBoundary ] else [ ];
  noMarks = _: [ ];

  resolve =
    marks:
    genView.referenceResolution {
      engine = genScope;
      name = "resolvedProvides";
      wellFormed = n: (n.decls.provided or [ ]) != [ ];
      project = n: n.decls.provided;
      inherit marks;
      localShadowsImport = true;
      transitiveImports = false;
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
in
{
  construct = [ "federated-packaged-subgraph" ];
  check = asserts (
    (resolve (sealAt requirer)).compute self requirer == null
    &&
      (resolve (sealAt requirer)).withheld self requirer == [
        {
          label = "imports";
          target = provider;
          marks = [ "selvageBoundary" ];
        }
      ]
    && (resolve noMarks).compute self requirer == selvageProvides
    && (resolve (sealAt provider)).compute self requirer == selvageProvides
    && (neededBy (sealAt requirer)).compute self provider == [ ]
    && (neededBy noMarks).compute self provider == [ requirer ]
    && (neededBy (sealAt provider)).compute self provider == [ requirer ]
  );
}
