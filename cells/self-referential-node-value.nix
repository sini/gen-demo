# `self-referential-node-value` — C66, den-hoag-5ahw. A node value that carries itself flows
# through the memo plane and evaluates. `genMemo`'s hash walk is bounded: a value whose walk does
# not end hashes to `null`, which the plane reads as always-dirty, so the node is recomputed rather
# than reused and the answer is the cold one. The walk used to be unbounded, and this value ended
# the whole evaluation with an uncatchable stack overflow.
#
# The corpus has no evaluator of its own to hand the plane, so it brings the reference scheduler's
# five lines (gen-memo `reference/schedule.nix`): a call-by-need knot over the domain that serves a
# clean node from `base` and recomputes the rest.
#
# C66 -- den-hoag-5ahw. Live control: the same chain over plain values carries a real hash, so the
# null is the fallback firing and not a hash the plane never took.
{
  asserts,
  genMemo,
  lib,
}:
let
  engine.schedule =
    {
      accessor,
      domain,
      base,
      recompute,
      isClean,
    }:
    lib.fix (
      s:
      let
        view = base // s;
      in
      lib.genAttrs domain (id: if isClean id then base.${id} else recompute accessor view id)
    );

  # bobbin -> spool -> reel: each node's weight plus its dependencies' weights.
  accessor = {
    nodes = [
      "bobbin"
      "spool"
      "reel"
    ];
    dependencies =
      id:
      {
        bobbin = [ "spool" ];
        spool = [ "reel" ];
      }
      .${id} or [ ];
    nodeData =
      id:
      {
        bobbin.weight = 1;
        spool.weight = 10;
        reel.weight = 100;
      }
      .${id};
  };
  selfReferential =
    w:
    let
      v = {
        inherit w;
        spun = v;
      };
    in
    v;
  plain = w: { inherit w; };
  recompute =
    mk: acc: store: id:
    mk ((acc.nodeData id).weight + lib.foldl' (t: d: t + store.${d}.w) 0 (acc.dependencies id));
  hashOf = v: builtins.hashString "sha256" (builtins.toJSON v);

  warm =
    mk:
    genMemo.propagateEager engine (genMemo.build engine {
      inherit accessor hashOf;
      recompute = recompute mk;
    }) { reel.weight = 200; };
  cold =
    (genMemo.build engine {
      accessor = accessor // {
        nodeData = id: if id == "reel" then { weight = 200; } else accessor.nodeData id;
      };
      inherit hashOf;
      recompute = recompute selfReferential;
    }).store;
  read = store: [
    store.bobbin.spun.spun.w
    store.reel.spun.w
  ];
in
{
  construct = [ "C66" ];
  check = asserts (
    read (warm selfReferential).store == [
      211
      200
    ]
    && read (warm selfReferential).store == read cold
    && (warm selfReferential).trace.reel.hash == null
    && builtins.isString (warm plain).trace.reel.hash
  );
}
