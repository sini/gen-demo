# ── C15 — the cyclic stratum, solved (ADR-0008 §2, ADR-0033). Deliberately OUTSIDE
# `config.declaredEdges`: C7 gates that relation and it must stay acyclic, so this
# component gets its own node names and its own accessor.
{
  genMemo,
  genScope,
  lib,
}:
let
  cyclicAccessor = {
    dependencies =
      id:
      {
        chintz = [ "tulle" ];
        tulle = [
          "chintz"
          "organdy"
        ];
      }
      .${id} or [ ];
    nodeData = id: { inherit id; };
  };
  cyclicReach =
    acc: view: id:
    lib.sort (a: b: a < b) (
      lib.unique ([ id ] ++ lib.concatLists (map (d: view.${d} or [ ]) (acc.dependencies id)))
    );
  cyclicLattice = {
    bottom = [ ];
    join = a: b: lib.sort (x: y: x < y) (lib.unique (a ++ b));
    maxIter = 8;
  };
  solvedScc = genMemo.runScc genScope.ascend {
    accessor = cyclicAccessor;
    recompute = cyclicReach;
    store = { };
    scc = [
      "chintz"
      "tulle"
    ];
    higherStrata.organdy = [ "organdy" ];
    lattices = {
      chintz = cyclicLattice;
      tulle = cyclicLattice;
    };
  };
in
{
  inherit
    cyclicAccessor
    cyclicReach
    cyclicLattice
    solvedScc
    ;
}
