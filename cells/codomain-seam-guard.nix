# `codomain-seam-guard` — C81, den-hoag-vznda. A body may not acquire a node record through
# `self.node` across an edge its node did not declare (gen-scope's codomain contract, R§2.6.3). Two
# sibling bolts under one `loom` read each other's `ply`, once through an ordinary synthesized body
# and once through a circular attribute's step, which reaches the substrate by a different path. On
# both paths the acquisition is admitted under a declared relation carrying the edge and refused under
# the empty one, and the refusal names the reader, the target and the relation. The circular step
# reads the peer's value outright, so it converges in one step when admitted: the only throw left to
# it is the guard's. Live controls: the admitted arms answer `2`, and a bolt's read of its own record
# is not refused under the empty relation, so a guard refusing everything cannot pass.
{
  asserts,
  lib,
  genScope,
  genGraph,
}:
let
  scope = genScope.buildRoots {
    parentGraph = genScope.overlays [
      (genScope.edge "damask" "loom")
      (genScope.edge "faille" "loom")
    ];
    decls = {
      loom.ply = 0;
      damask.ply = 1;
      faille.ply = 2;
    };
    types = { };
  };
  peerOf = id: if id == "damask" then "faille" else "damask";
  contracted =
    rel:
    genGraph.mkDeclaredEdges (
      builtins.mapAttrs (
        _: ids: map (genGraph.mkNodeRef { isRegistered = id: scope.nodes ? ${id}; }) ids
      ) rel
    );
  # a shared round ranges over every eligible instance, so `loom`'s own step acquires too
  declared = contracted {
    loom = [ "damask" ];
    damask = [ "faille" ];
    faille = [ "damask" ];
  };
  empty = contracted { };

  peerPly = self: id: (self.node (peerOf id)).decls.ply;
  carrier = {
    bottom = 0;
    leq = x: y: x <= y;
    height = 2;
    quotient = false;
  };

  attributes = {
    children =
      _self: id:
      builtins.listToAttrs (
        map (cid: {
          name = cid;
          value = scope.nodes.${cid};
        }) (builtins.filter (cid: scope.nodes.${cid}.parent == id) (builtins.attrNames scope.nodes))
      );
    imports = _self: _id: [ ];
    peer-ply = peerPly;
    own-ply = self: id: (self.node id).decls.ply;
    circular-peer-ply = genScope.circular { inherit carrier; } (
      self: id: _prev:
      peerPly self id
    );
  };

  foldWith =
    declaredDependencies:
    (genScope.foldEquations {
      inherit scope declaredDependencies;
      parseParent = id: scope.nodes.${id}.parent or null;
      schedule.equations = builtins.mapAttrs (name: compute: {
        inherit name compute;
        kind =
          if name == "children" then
            "nta"
          else if name == "circular-peer-ply" then
            "circular"
          else
            "synthesized";
        readsAttrs = [ ];
        stratum = if name == "children" then "structural" else "resolution";
      }) attributes;
    }).eval;

  admitted = foldWith declared;
  refused = foldWith empty;
  refuses = attr: !(builtins.tryEval (builtins.deepSeq (refused.get "damask" attr) true)).success;
  reason = genScope.seamAcquisitionDefect {
    reader = "damask";
    target = "faille";
    declared = [ ];
  };
in
{
  construct = [ "C81" ];
  check = asserts (
    admitted.get "damask" "peer-ply" == 2
    && admitted.get "damask" "circular-peer-ply" == 2
    && refuses "peer-ply"
    && refuses "circular-peer-ply"
    && refused.get "damask" "own-ply" == 1
    && lib.hasPrefix "gen-scope: node 'damask' acquired the record of node 'faille'" reason
    && lib.hasInfix "'damask' declared: []" reason
  );
}
