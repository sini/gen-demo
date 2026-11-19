# `grown-child-warm-parity`. A node the substrate grows from a host is a function of that host's
# evaluation, so a warm read after the host's edit equals what a fresh cold fold of the edited scope
# answers (gen-scope's reuse relation over growth units; ADR-0008 item 2). Two hosts: `loom` is an
# `nta` host whose child `bolt` is seeded from `loom`'s own `defs`, and `loom` reads `bolt` back
# through `self.getNta`, declaring it; `wheel` is a `spawns` host whose child `wheel-skein` copies
# `wheel`'s `defs`. The scope is folded through `genScope.foldEquations` and warmed through
# `genMemo.warmOverride`, whose engine is gen-scope's own `foldEquations`. After an edit to `loom`, the
# child's `defs` and `loom`'s read of it are `[2]` warm, what a fresh cold fold answers; after an edit
# to `wheel`, the spawned child's `defs` is `[2]` warm, what a fresh cold fold answers. Before the
# reuse relation carried growth, no grown child was in its host's cone and the warm pass served the
# stale `[1]`. Live control: each edit moves the fresh read off the cold one, so the parity is not two
# stale reads agreeing.
{
  genScope,
  genGraph,
  genMemo,
  asserts,
}:
let
  engine = { inherit (genScope) foldEquations; };
  bolt = genScope.mintNtaId {
    host = "loom";
    name = "weave";
    group = "g";
    key = "bolt";
  };
  kinds = genScope.mkKinds [
    (genScope.mkKind { } "yarn")
    # grows one child, seeded from the host's first definition, only while that definition is a set
    (genScope.mkKind {
      nta.weave =
        self: id:
        let
          d = self.get id "defs";
        in
        if d != [ ] && builtins.isAttrs (builtins.head d) then
          {
            g.bolt = [
              {
                attr = "defs";
                def = 0;
                at = [ "warp" ];
              }
            ];
          }
        else
          { };
    } "loom")
    (genScope.mkKind {
      below = [ "yarn" ];
      spawns.yarn = h: id: { "${id}-skein".decls.defs = (h.node id).decls.defs; };
    } "wheel")
  ];
  scopeAt =
    edit:
    genScope.buildRoots {
      inherit kinds;
      decls = {
        loom.defs = [ { warp = 1; } ];
        wheel.defs = [ 1 ];
      }
      // edit;
      types = {
        loom = "loom";
        wheel = "wheel";
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
    defs = equation "defs" "resolution" "synthesized" (
      self: id:
      let
        d = (self.node id).decls;
      in
      if d ? seed then map (e: e.value) d.seed else d.defs or [ ]
    );
    woven = equation "woven" "resolution" "synthesized" (
      self: id: if id == "loom" then self.getNta "weave" "g" "bolt" "defs" else null
    );
  };
  parseParent =
    id:
    let
      d = genScope.decodeNta id;
      m = builtins.match "(.*)-skein" id;
    in
    if d != null then
      d.host
    else if m != null then
      builtins.head m
    else
      null;
  fold =
    edit:
    genScope.foldEquations { } {
      scope = scopeAt edit;
      schedule = { inherit equations; };
      declaredDependencies = genGraph.mkDeclaredEdges {
        loom = [ (genGraph.mkNodeRef (_: true) bolt) ];
      };
      inherit parseParent;
    };
  reads = ev: {
    bolt = ev.get bolt "defs";
    woven = ev.get "loom" "woven";
    skein = ev.get "wheel-skein" "defs";
  };
  cold = fold { };
  warm = id: decls: reads (genMemo.warmOverride engine cold id decls).eval;
  fresh = edit: reads (fold edit).eval;
  loomEdit.loom.defs = [ { warp = 2; } ];
  wheelEdit.wheel.defs = [ 2 ];
in
{
  construct = [ "a-grown-child-reads-warm-what-a-fresh-fold-reads-after-its-host-moves" ];
  check = asserts (
    reads cold.eval == {
      bolt = [ 1 ];
      woven = [ 1 ];
      skein = [ 1 ];
    }
    && warm "loom" loomEdit.loom == fresh loomEdit
    &&
      fresh loomEdit == {
        bolt = [ 2 ];
        woven = [ 2 ];
        skein = [ 1 ];
      }
    && warm "wheel" wheelEdit.wheel == fresh wheelEdit
    &&
      fresh wheelEdit == {
        bolt = [ 1 ];
        woven = [ 1 ];
        skein = [ 2 ];
      }
  );
}
