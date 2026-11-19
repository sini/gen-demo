# `batch-warm-decision-union-cone`. A warm pass over several edits decides its dirty set as the union
# of the edits' reverse cones, read through one held reverse-reachability application across every
# seed (gen-memo `dirtySet`'s `concatMap (graph.dependentsOf view) seeds`; gen-graph binds the
# reverse index at the accessor application, so the K seeds share one index). The relation is
# gen-merge's bipartite shape: entries `e0`..`e3`, and each location `l<j>` declares the entries
# `e<j-1>` and `e<j>` and reads their `clay` through `self.get`. The scope is folded through
# `genScope.foldEquations` and warmed by the batch form `genMemo.warmResolve`, two edits in one pass
# (`e0` and `e3`). The decision over both seeds marks `l0`, `l1`, `l3` and `l4` dirty and leaves `l2`
# clean, and agrees node by node with the union of the two single-seed decisions. Every location's
# warm read equals a fresh cold fold of the edited scope. Live control: the edits move `l0` and `l4`'s
# reads, so the parity is not two stale reads agreeing, and `l2`'s read does not move.
{
  asserts,
  lib,
  genScope,
  genGraph,
  genMemo,
}:
let
  engine = { inherit (genScope) evalWarm; };
  entries = map (i: "e${toString i}") (lib.range 0 3);
  locations = map (j: "l${toString j}") (lib.range 0 4);
  reads = j: lib.optional (j > 0) "e${toString (j - 1)}" ++ lib.optional (j < 4) "e${toString j}";
  declared = lib.listToAttrs (map (j: lib.nameValuePair "l${toString j}" (reads j)) (lib.range 0 4));
  scopeAt =
    clay:
    genScope.buildRoots {
      kinds = genScope.mkKinds [ (genScope.mkKind { } "host") ];
      decls =
        lib.genAttrs entries (e: {
          clay = clay.${e} or 1;
        })
        // lib.genAttrs locations (_: { });
      types = lib.genAttrs (entries ++ locations) (_: "host");
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
    sum = equation "sum" "resolution" "synthesized" (
      self: id: lib.foldl' (acc: e: acc + self.get e "clay") 100 (declared.${id} or [ ])
    );
  };
  fold =
    clay:
    let
      scope = scopeAt clay;
    in
    genScope.foldEquations { } {
      inherit scope;
      schedule = { inherit equations; };
      declaredDependencies = genGraph.mkDeclaredEdges (
        builtins.mapAttrs (_: map (genGraph.mkNodeRef (id: scope.nodes ? ${id}))) declared
      );
      parseParent = _: null;
    };
  sums = ctx: map (l: ctx.eval.get l "sum") locations;
  edited = {
    e0 = 7;
    e3 = 9;
  };
  cold = fold { };
  warm = genMemo.warmResolve engine cold (builtins.mapAttrs (_: clay: { inherit clay; }) edited);
  fresh = fold edited;
  decide = seeds: genMemo.warmDecision cold.accessor cold.eval.facade seeds;
  both = decide (builtins.attrNames edited);
  single = map (s: decide [ s ]) (builtins.attrNames edited);
in
{
  construct = [ "a-batch-warm-pass-dirties-the-union-of-its-edits-cones" ];
  check = asserts (
    map both.isClean locations == [
      false
      false
      true
      false
      false
    ]
    && builtins.all (l: both.isClean l == builtins.all (d: d.isClean l) single) (entries ++ locations)
    && sums warm == sums fresh
    &&
      sums cold == [
        101
        102
        102
        102
        101
      ]
    &&
      sums fresh == [
        107
        108
        102
        110
        109
      ]
  );
}
