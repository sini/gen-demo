# `closed-body-reader`. An armed body's reader is closed: it carries the guarded demand forms and the
# one enumeration `allNodeIds`, a named refusal at every other field the substrate accessor has, and
# the records it hands back are the records as authored (gen-scope's codomain contract, R§2.4;
# ADR-0008 item 2). Two hosts: `kiln` is an `nta` host whose child `pot` reads `kiln`'s `heat` at its
# own coordinates through `self.getHostAt`, and `quarry` is a plain root. The scope is folded through
# `genScope.foldEquations` and warmed through `genMemo.warmOverride`, whose engine is gen-scope's own
# `evalWarm`. Under a relation declaring `pot` → `kiln`, the cold read is `101`, and the warm read
# after an edit to `kiln` is `109`, what a fresh cold fold of the edited scope answers. Under the
# empty relation the read is refused cold and warm: before the reader closed, `getHostAt` answered
# undeclared and the warm pass served its stale prior. A body touching `self.facade` is refused
# catchably, and gen-scope's reason names `self.facade` and the repair. `pot` reading
# `self.getHostAt "nta-children"` receives its own authored record, with no `_eval` cache on it.
# Live control: a body reading `self.allNodeIds` answers under the empty relation, because the
# enumeration is kept.
{
  asserts,
  lib,
  genScope,
  genGraph,
  genMemo,
}:
let
  engine = { inherit (genScope) evalWarm; };
  pot = genScope.mintNtaId {
    host = "kiln";
    name = "batch";
    group = "g";
    key = "pot";
  };
  kilnKind = genScope.mkKind {
    nta.batch = _: id: {
      g =
        if id == "kiln" then
          {
            pot = [
              {
                attr = "defs";
                def = 0;
                at = [ "pot" ];
              }
            ];
          }
        else
          { };
    };
  } "kiln";
  scopeAt = heat: {
    kinds = genScope.mkKinds [
      kilnKind
      (genScope.mkKind { } "host")
    ];
    nodes = {
      kiln = {
        id = "kiln";
        type = "kiln";
        parent = null;
        decls = {
          inherit heat;
          defs = [ { pot.glaze = "ash"; } ];
        };
      };
      quarry = {
        id = "quarry";
        type = "host";
        parent = null;
        decls = { };
      };
    };
    nodeOrder = [
      "kiln"
      "quarry"
    ];
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
    defs = equation "defs" "resolution" "nta" (
      self: id:
      let
        d = (self.node id).decls;
      in
      if d ? seed then map (e: e.value) d.seed else d.defs or [ ]
    );
    # the host's equation for each of its children, at the child's coordinates
    temp = equation "temp" "resolution" "synthesized" (
      self: id: {
        batch.g = if id == "kiln" then { pot = (self.node id).decls.heat; } else { };
      }
    );
    fired = equation "fired" "resolution" "synthesized" (
      self: id: if id == pot then self.getHostAt "temp" + 100 else 0
    );
    own = equation "own" "resolution" "synthesized" (
      self: id:
      if id == pot then
        let
          r = self.getHostAt "nta-children";
        in
        {
          inherit (r) id;
          cache = r ? _eval;
        }
      else
        { }
    );
    facade = equation "facade" "resolution" "synthesized" (
      self: id: if id == "quarry" then (builtins.tryEval self.facade).success else true
    );
    facade-read = equation "facade-read" "resolution" "synthesized" (
      self: id: if id == "quarry" then self.facade.get "kiln" "temp" else { }
    );
    count = equation "count" "resolution" "synthesized" (
      self: id: if id == "quarry" then builtins.length self.allNodeIds else 0
    );
  };
  fold =
    heat: rel:
    genScope.foldEquations { } {
      scope = scopeAt heat;
      schedule = { inherit equations; };
      declaredDependencies = genGraph.mkDeclaredEdges (
        builtins.mapAttrs (_: map (genGraph.mkNodeRef (_: true))) rel
      );
      parseParent = _: null;
    };
  fired = ev: ev.get pot "fired";
  refuses = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
  declared.${pot} = [ "kiln" ];
  warm = ctx: (genMemo.warmOverride engine ctx "kiln" { heat = 9; }).eval;
  reason = genScope.seamAcquisitionDefect {
    reader = null;
    target = null;
    declared = [ ];
    through = "facade";
  };
in
{
  construct = [ "closed-body-reader-cold-and-warm" ];
  check = asserts (
    fired (fold 1 declared).eval == 101
    && fired (warm (fold 1 declared)) == 109
    && fired (fold 9 declared).eval == 109
    && fired (fold 1 declared).eval != fired (fold 9 declared).eval
    && refuses (fired (fold 1 { }).eval)
    && refuses (fired (warm (fold 1 { })))
    && (fold 1 { }).eval.get "quarry" "facade" == false
    && refuses ((fold 1 { }).eval.get "quarry" "facade-read")
    && lib.hasPrefix "gen-scope: an armed body's reader does not carry `self.facade`." reason
    && lib.hasInfix "a body reads through `self.get <id> <attr>`, with <id> declared." reason
    &&
      (fold 1 declared).eval.get pot "own" == {
        id = pot;
        cache = false;
      }
    && (fold 1 { }).eval.get "quarry" "count" == 3
  );
}
