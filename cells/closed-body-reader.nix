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
#
# The delegated arm (producer-bounded delegation): a reader is a value, bound to the node whose body
# it was handed to. `kiln`, declaring `quarry`, returns its own reader as `tongs`; `ladle` forwards
# it as `pour`. `mould`, declaring only `kiln`, and `cast`, declaring only `ladle`, each read
# `quarry`'s `clay` through it: `1` cold, and `9` warm after an edit to `quarry`, what a fresh cold
# fold answers, because the warm cone dirties `kiln` and `ladle` on the declared path. `pit`, which
# `kiln` did not declare, is refused through the handed reader, cold and warm; live control: `pit`
# answers `5`. Under the empty relation both reads are refused.
#
# The marker arm (the armed-reader marker): the body that reads `self.allNodeIds` also reads
# `self ? reader`, `true` on its armed reader and `false` on an unarmed twin of the same scope
# evaluated through `genScope.eval` with no relation. gen-scope's `children` and `nodesByType` branch
# on that marker: armed, `kiln`'s children and the `kiln`-kind nodes answer through the guarded
# `node` reads, each a declared read, and under the empty relation they are refused; unarmed, the
# same helpers answer the same ids through the substrate walk.
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
  # the delegated arm: `kiln` hands out its own reader as `tongs`, and `ladle` forwards it as `pour`
  hosts = [
    "quarry"
    "pit"
    "kiln"
    "ladle"
    "mould"
    "cast"
  ];
  handScopeAt =
    clay:
    genScope.buildRoots {
      kinds = genScope.mkKinds [ (genScope.mkKind { } "host") ];
      decls = lib.genAttrs hosts (_: { }) // {
        quarry = { inherit clay; };
        pit.clay = 5;
      };
      types = lib.genAttrs hosts (_: "host");
    };
  # `mould` holds the producer's reader directly, `cast` through the forwarder
  held =
    self: id:
    if id == "mould" then
      self.get "kiln" "tongs"
    else if id == "cast" then
      self.get "ladle" "pour"
    else
      null;
  handEquations = {
    children = equation "children" "structural" "nta" (_: _: { });
    imports = equation "imports" "structural" "synthesized" (_: _: [ ]);
    clay = equation "clay" "resolution" "synthesized" (self: id: (self.node id).decls.clay or 0);
    tongs = equation "tongs" "resolution" "synthesized" (self: id: if id == "kiln" then self else null);
    pour = equation "pour" "resolution" "synthesized" (
      self: id: if id == "ladle" then self.get "kiln" "tongs" else null
    );
    read = equation "read" "resolution" "synthesized" (
      self: id: if held self id == null then 0 else (held self id).get "quarry" "clay"
    );
    stray = equation "stray" "resolution" "synthesized" (
      self: id: if id == "mould" then (self.get "kiln" "tongs").get "pit" "clay" else 0
    );
  };
  handFold =
    clay: rel:
    let
      scope = handScopeAt clay;
    in
    genScope.foldEquations { } {
      inherit scope;
      schedule.equations = handEquations;
      declaredDependencies = genGraph.mkDeclaredEdges (
        builtins.mapAttrs (_: map (genGraph.mkNodeRef (id: scope.nodes ? ${id}))) rel
      );
      parseParent = _: null;
    };
  # neither consumer declares `quarry`, and `cast` does not declare `kiln`
  handed = {
    kiln = [ "quarry" ];
    ladle = [ "kiln" ];
    mould = [ "kiln" ];
    cast = [ "ladle" ];
  };
  reads = ev: {
    mould = ev.get "mould" "read";
    cast = ev.get "cast" "read";
  };
  handCold = handFold 1 handed;
  handWarm = (genMemo.warmOverride engine handCold "quarry" { clay = 9; }).eval;
  # the marker arm: one body reads the marker beside the enumeration, two call the query helpers
  markEquations = equations // {
    marked = equation "marked" "resolution" "synthesized" (
      self: id:
      if id == "quarry" then
        {
          reader = self ? reader;
          count = builtins.length self.allNodeIds;
        }
      else
        { }
    );
    kids = equation "kids" "resolution" "synthesized" (
      self: id: if id == "quarry" then builtins.attrNames (genScope.children self "kiln") else [ ]
    );
    kin = equation "kin" "resolution" "synthesized" (
      self: id: if id == "quarry" then builtins.attrNames (genScope.nodesByType self "kiln") else [ ]
    );
  };
  markFold =
    rel:
    (genScope.foldEquations { } {
      scope = scopeAt 1;
      schedule.equations = markEquations;
      declaredDependencies = genGraph.mkDeclaredEdges (
        builtins.mapAttrs (_: map (genGraph.mkNodeRef (_: true))) rel
      );
      parseParent = _: null;
    }).eval;
  marking.quarry = [
    "kiln"
    pot
  ];
  unarmed = genScope.eval { parseParent = _: null; } (builtins.mapAttrs (
    _: e: e.compute
  ) markEquations) (scopeAt 1);
  marks = ev: {
    marked = ev.get "quarry" "marked";
    kids = ev.get "quarry" "kids";
    kin = ev.get "quarry" "kin";
  };
  marksAs = reader: {
    marked = {
      inherit reader;
      count = 3;
    };
    kids = [ pot ];
    kin = lib.sort (a: b: a < b) [
      "kiln"
      pot
    ];
  };
in
{
  construct = [
    "closed-body-reader-cold-and-warm"
    "a-handed-reader-reads-through-its-producers-relation"
    "an-armed-reader-carries-its-marker-and-the-queries-branch-on-it"
  ];
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
    &&
      reads handCold.eval == {
        mould = 1;
        cast = 1;
      }
    &&
      reads handWarm == {
        mould = 9;
        cast = 9;
      }
    && reads handWarm == reads (handFold 9 handed).eval
    && refuses (handCold.eval.get "mould" "stray")
    && refuses (handWarm.get "mould" "stray")
    && handCold.eval.get "pit" "clay" == 5
    && refuses (reads (handFold 1 { }).eval)
    && marks (markFold marking) == marksAs true
    && marks unarmed == marksAs false
    && (markFold { }).get "quarry" "marked" == (marksAs true).marked
    && refuses ((markFold { }).get "quarry" "kids")
    && refuses ((markFold { }).get "quarry" "kin")
  );
}
