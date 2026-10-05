# shellcheck shell=bash
# ── row 154 -- an over-listed instance relation meets the projection-parity door, BY NAME
#    (mirrors C181's `parametric-delivery`; den-hoag-htfv3-stage-c-graph-query-xm29n) ──
# `project` walks the declared include sites for membership and order, and the receiver-rooted query
# over the same relation certifies that membership by refusal. The plant hands `warp` an edge to
# `twill`'s `nap` instance, which `warp`'s include sites never reach: the walk alone ignores it and
# delivers `warp` unchanged at rc 0, so only the query's first arm refuses it. The unplanted arm reads
# the true relation, so a door that refused every relation cannot pass it.
row154='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genDelivery = gen.lib.framework.delivery;
  genMerge = gen.lib.modules.merge;
  hashIdentity = gen.lib.substrate.identity.hashIdentity;
  cnf = import ./aspect-cnf.nix // { entityKinds = { loom = true; shuttle = true; }; };
  t = (gen.lib.substrate.algebra.term hashIdentity).term;
  inherit (genAspects) guard pred;
  aspects = (genMerge.evalModuleTree { } [
    { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
    { aspects = {
        frame.nixos.marks = [ "frame" ];
        frame.includes = [ "selvage" ];
        bobbin.nixos.marks = [ "bobbin" ];
        bobbin.includes = [ "nap" ];
        selvage = guard (pred.has "loom") { nixos.marks = [ "selvage" ]; includes = [ "pick" (t.readCtx "loom" [ ]) ]; };
        pick = guard (pred.has "loom") { nixos.marks = [ "pick" ]; };
        nap = guard (pred.has "shuttle") { nixos.marks = [ "nap" ]; };
        jacquard.nixos.marks = [ "jacquard" ];
      }; }
  ]).config.aspects;
  entity = n: hashIdentity "entity" [ "name" ] (_: n);
  r = genAspects.instancesFor cnf aspects {
    suppliers = { ${entity "warp"}.loom = "jacquard"; ${entity "twill"}.loom = "jacquard"; ${entity "boat"}.shuttle = "boat"; };
    scopes = {
      warp = { members = [ "frame" ]; sources.loom = entity "warp"; };
      twill = { members = [ "bobbin" ]; sources.loom = entity "twill"; descendants = [ { sources.shuttle = entity "boat"; } ]; };
    };
  };
  marksOf = instances: (genMerge.evalModuleTree { } (
    [ { freeformType = genMerge.types.lazyAttrsOf genMerge.types.anything; } ]
    ++ (genDelivery.project {
      values = { inherit aspects; hosts = { warp.aspects = [ "frame" ]; twill.aspects = [ "bobbin" ]; }; };
      inherit cnf instances;
      selectNodes = v: v.hosts;
    }).nodes.warp.classes.nixos
  )).config.marks;
  overlisted = r // { reaches = r.reaches // { warp = r.reaches.warp // { inherit (r.reaches.twill) nap; }; }; };
  green = builtins.toJSON (builtins.sort builtins.lessThan (marksOf r));
  planted = builtins.toJSON (marksOf overlisted);
in BODY'
check "T5 row154 unplanted (the true relation delivers warp its reach)" \
  "${row154/BODY/green}" 0 "" "$tmpdir/row154-green.err" '["frame","jacquard","pick","selvage"]'
check "T5 row154 planted   (an edge warp never reaches names warp at the parity door's first arm)" \
  "${row154/BODY/planted}" 1 \
  "gen-delivery: project: node 'warp' reaches '" \
  "$tmpdir/row154-node.err"
check "T5 row154 planted   (the refusal is the parity door's over-listed arm)" \
  "${row154/BODY/planted}" 1 \
  "through the instance relation's edges, and its declared include sites never reach it: the relation was minted over other members or another tree than project reads" \
  "$tmpdir/row154-door.err"
