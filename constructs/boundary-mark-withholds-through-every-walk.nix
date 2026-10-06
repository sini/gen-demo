# ── C190 — a boundary mark withholds through every walk (den-hoag-4or0a U1). gen-scope's collection
# walks are resolutions of the one calculus, so a mark at a scope withholds the edges leaving it
# through each of them exactly as it does through `resolve` and `inherit'` (ADR-0026, the node's
# fail-closed floor). `selvage` is sealed by a mark admitting no label; `weft`, its unsealed sibling
# under the same `bolt`, importing the same `warp`, is the live control.

{
  genScope,
}:

let
  boundaryNodes = {
    bolt = {
      id = "bolt";
      type = "fabric";
      parent = null;
      decls.nap = "napped";
    };
    selvage = {
      id = "selvage";
      type = "fabric";
      parent = "bolt";
      decls = { };
    };
    weft = {
      id = "weft";
      type = "fabric";
      parent = "bolt";
      decls = { };
    };
    warp = {
      id = "warp";
      type = "fabric";
      parent = null;
      decls.nap = "combed";
    };
  };
  selvageSeal = {
    name = "selvageSeal";
    admits = _: false;
  };
  boundaryScope =
    genScope.eval

      {
        parseParent = id: boundaryNodes.${id}.parent;
      }

      {
        children = _: _: { };
        imports = _: id: if id == "selvage" || id == "weft" then [ "warp" ] else [ ];
        marks = _: id: if id == "selvage" then [ selvageSeal ] else [ ];
      }

      {
        nodes = boundaryNodes;
        nodeOrder = [
          "bolt"
          "selvage"
          "weft"
          "warp"
        ];
      };

  napOf = n: n.decls.nap or null;
  napAt = self: id: napOf (self.node id);
in

{
  boundaryWalks = id: {
    inherited = genScope."inherit'" { } napOf boundaryScope id;
    all = genScope.inheritAll { } napOf boundaryScope id;
    set = genScope.inheritSet { } napOf boundaryScope id;
    ancestors = genScope.collectionAttr { } "ancestors" napAt boundaryScope id;
    neron = genScope.collectionAttr { } "neron" napAt boundaryScope id;
  };
}
