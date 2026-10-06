# ── C191 — a boundary mark withholds at every one-hop edge read (den-hoag-4or0a U2). gen-scope's
# one-hop reads (`collectionAttr`'s `"imports"` and `"label:"`, `collectImports`, `collectByLabel`,
# `followEdge`) are each the resolution `wf = l`, so a mark at a scope withholds the edge it does not
# admit through them exactly as through `resolve` (ADR-0026, the node's fail-closed floor). `shed`
# is sealed by a mark admitting no label; `batten` by one admitting `imports` alone; `reed`, unsealed,
# importing the same `heddle` and threading the same `pick`, is the live control.

{
  genScope,
}:

let
  oneHopNodes = {
    shed = {
      id = "shed";
      type = "fabric";
      parent = null;
      decls = { };
    };
    batten = {
      id = "batten";
      type = "fabric";
      parent = null;
      decls = { };
    };
    reed = {
      id = "reed";
      type = "fabric";
      parent = null;
      decls = { };
    };
    heddle = {
      id = "heddle";
      type = "fabric";
      parent = null;
      decls.nap = "combed";
    };
    pick = {
      id = "pick";
      type = "fabric";
      parent = null;
      decls.nap = "plain";
    };
  };
  shedSeal = {
    name = "shedSeal";
    admits = _: false;
  };
  battenSeal = {
    name = "battenSeal";
    admits = l: l == "imports";
  };
  readers = [
    "shed"
    "batten"
    "reed"
  ];
  oneHopScope =
    genScope.eval

      {
        parseParent = id: oneHopNodes.${id}.parent;
      }

      {
        children = _: _: { };
        imports = _: id: if builtins.elem id readers then [ "heddle" ] else [ ];
        edges-threads = _: id: if builtins.elem id readers then [ "pick" ] else [ ];
        marks =
          _: id:
          if id == "shed" then
            [ shedSeal ]
          else if id == "batten" then
            [ battenSeal ]
          else
            [ ];
      }

      {
        nodes = oneHopNodes;
        nodeOrder = [
          "shed"
          "batten"
          "reed"
          "heddle"
          "pick"
        ];
      };

  napAt = self: id: (self.node id).decls.nap or null;
  napsAt = self: id: [ (napAt self id) ];
in

{
  boundaryOneHop = id: {
    imports = genScope.collectionAttr { } "imports" napAt oneHopScope id;
    label = genScope.collectionAttr { } "label:threads" napAt oneHopScope id;
    collectImports = genScope.collectImports napsAt oneHopScope id;
    collectByLabel = genScope.collectByLabel "threads" napsAt oneHopScope id;
    followEdge = genScope.followEdge "threads" oneHopScope id;
  };
}
