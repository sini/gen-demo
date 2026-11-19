# `warm-returned-relation`. The ctx a warm pass returns is a plane output, so the relation it
# publishes, its node list and each node's dependencies, is what a fresh cold fold of the edited
# scope publishes (ADR-0008 item 2). Two hosts: `wheel` is a `spawns` host that spawns one
# `wheel-<k>` per entry of its `kids`, and `rack` selects its registered children `peg1` and `peg2`
# by its own `kids`. The scope is folded through `genScope.foldEquations` and warmed through
# `genMemo.warmOverride`, whose engine is gen-scope's own `foldEquations`, the entry that seals the
# cold fold, so the warm pass is sealed by the same entry. After an edit growing `wheel`'s `kids`,
# the returned node list carries `wheel-b` and `wheel-b`'s dependencies are `[ "wheel" ]`, as a fresh
# fold's are; after an edit moving `rack`'s selection, the node set is held and `rack`'s
# dependencies are `[ "peg1" "peg2" ]`, as a fresh fold's are. Live control: each edit moves the
# fresh relation off the cold one, so the agreement is not two stale relations agreeing.
{
  genScope,
  genGraph,
  genMemo,
  asserts,
}:
let
  engine = { inherit (genScope) foldEquations; };
  kinds = genScope.mkKinds [
    (genScope.mkKind { } "peg")
    (genScope.mkKind {
      below = [ "peg" ];
      spawns.peg =
        h: id:
        builtins.listToAttrs (
          map (k: {
            name = "${id}-${k}";
            value.decls = { };
          }) (h.node id).decls.kids
        );
    } "wheel")
  ];
  scopeAt =
    edit:
    genScope.buildRoots {
      inherit kinds;
      decls = {
        wheel.kids = [ "a" ];
        rack.kids = [ "peg1" ];
        peg1 = { };
        peg2 = { };
      }
      // edit;
      types = {
        wheel = "wheel";
        rack = "peg";
        peg1 = "peg";
        peg2 = "peg";
      };
      parentGraph = genScope.overlays (
        map genScope.edge [
          {
            from = "peg1";
            to = "rack";
          }
          {
            from = "peg2";
            to = "rack";
          }
        ]
      );
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
    children = equation "children" "structural" "nta" (
      self: id:
      if id == "rack" then
        builtins.listToAttrs (
          map (k: {
            name = k;
            value.id = k;
          }) (self.node id).decls.kids
        )
      else
        { }
    );
    imports = equation "imports" "structural" "synthesized" (_: _: [ ]);
  };
  parseParent =
    id:
    if id == "peg1" || id == "peg2" then
      "rack"
    else if builtins.match "wheel-(.*)" id != null then
      "wheel"
    else
      null;
  fold =
    edit:
    genScope.foldEquations { } {
      scope = scopeAt edit;
      schedule = { inherit equations; };
      declaredDependencies = genGraph.mkDeclaredEdges { };
      inherit parseParent;
    };
  relation = ctx: {
    nodes = ctx.accessor.nodes;
    wheelB =
      if builtins.elem "wheel-b" ctx.accessor.nodes then ctx.accessor.dependencies "wheel-b" else null;
    rack = ctx.accessor.dependencies "rack";
  };
  cold = fold { };
  warm = id: decls: relation (genMemo.warmOverride engine cold id decls);
  fresh = edit: relation (fold edit);
  grow.wheel.kids = [
    "a"
    "b"
  ];
  select.rack.kids = [
    "peg1"
    "peg2"
  ];
in
{
  construct = [ "a-warm-pass-returns-the-relation-a-fresh-fold-returns" ];
  check = asserts (
    warm "wheel" grow.wheel == fresh grow
    && (fresh grow).wheelB == [ "wheel" ]
    && (relation cold).wheelB == null
    && warm "rack" select.rack == fresh select
    &&
      (fresh select).rack == [
        "peg1"
        "peg2"
      ]
    && (relation cold).rack == [ "peg1" ]
    && (fresh select).nodes == (relation cold).nodes
  );
}
