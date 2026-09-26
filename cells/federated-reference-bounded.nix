# `federated-reference-bounded` — C11. A boundary mark on the federation's include edge (ADR-0026's
# fail-closed floor, compiled at the query authority's accessor). `genLink.link` declares no marks,
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
  self = genScope.eval {
    scope = genScope.buildRoots {
      importGraph = genScope.overlays (map (e: genScope.edge e.from e.to) edges);
      decls = {
        ${requirer}.provided = [ ];
        ${provider}.provided = selvageProvides;
      };
    };
    attributes = {
      children = _self: _id: { };
      imports = _self: id: importIndex.${id} or [ ];
    };
    parseParent = _id: null;
  };

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
      importShadowsParent = true;
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
  construct = [ "C11" ];
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
