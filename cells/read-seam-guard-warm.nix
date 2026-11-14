# `read-seam-guard-warm`. A body may not read another node's attribute through `self.get` across
# an edge its node did not declare, and the warm pass refuses what the cold fold refuses (gen-scope's
# codomain contract, R§2.4; ADR-0008 item 2). Two hosts: `kiln` reads `quarry`'s `clay` through
# `self.get`. The scope is folded through `genScope.foldEquations` and warmed through
# `genMemo.warmOverride`, whose engine is gen-scope's own `evalWarm`. Under a relation declaring the
# edge, the cold read is `101` and the warm read after an edit to `quarry` is `109`, what a fresh cold
# fold of the edited scope answers. Under the empty relation the cold read is refused, and so is the
# warm read, with `kiln` edited and with `quarry` edited: an undeclared reader is not left outside the
# cone to be served its stale prior. The reason names the reader, the attribute, the target and the
# relation `[]`. Live control: the edit moves the declared read, so the parity is not two stale reads
# agreeing.
{
  asserts,
  lib,
  genScope,
  genGraph,
  genMemo,
}:
let
  engine = { inherit (genScope) evalWarm; };
  scopeAt =
    clay:
    genScope.buildRoots {
      kinds = genScope.mkKinds [ (genScope.mkKind { } "host") ];
      decls = {
        quarry = { inherit clay; };
        kiln = { };
      };
      types = {
        quarry = "host";
        kiln = "host";
      };
    };
  equation = name: stratum: kind: compute: {
    inherit
      name
      compute
      stratum
      kind
      ;
    readsAttrs = [ ];
  };
  equations = {
    children = equation "children" "structural" "nta" (_: _: { });
    imports = equation "imports" "structural" "synthesized" (_: _: [ ]);
    clay = equation "clay" "resolution" "synthesized" (self: id: (self.node id).decls.clay or 0);
    fired = equation "fired" "resolution" "synthesized" (
      self: id: if id == "kiln" then self.get "quarry" "clay" + 100 else 0
    );
  };
  fold =
    clay: rel:
    let
      scope = scopeAt clay;
    in
    genScope.foldEquations { } {
      inherit scope;
      schedule = { inherit equations; };
      declaredDependencies = genGraph.mkDeclaredEdges (
        builtins.mapAttrs (_: map (genGraph.mkNodeRef (id: scope.nodes ? ${id}))) rel
      );
      parseParent = _: null;
    };
  fired = ctx: ctx.eval.get "kiln" "fired";
  refuses = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
  declared = {
    kiln = [ "quarry" ];
  };
  warm =
    ctx: id: decls:
    genMemo.warmOverride engine ctx id decls;
  reason = genScope.seamAcquisitionDefect {
    reader = "kiln";
    target = "quarry";
    attrName = "clay";
    through = "self.get";
    declared = [ ];
  };
in
{
  construct = [ "self-get-read-seam-guard-cold-and-warm" ];
  check = asserts (
    fired (fold 1 declared) == 101
    && fired (warm (fold 1 declared) "quarry" { clay = 9; }) == 109
    && fired (fold 9 declared) == 109
    && fired (fold 1 declared) != fired (fold 9 declared)
    && refuses (fired (fold 1 { }))
    && refuses (fired (warm (fold 1 { }) "kiln" { lit = true; }))
    && refuses (fired (warm (fold 1 { }) "quarry" { clay = 9; }))
    && lib.hasPrefix "gen-scope: node 'kiln' read attribute 'clay' of node 'quarry' through `self.get`" reason
    && lib.hasInfix "'kiln' declared: []" reason
  );
}
