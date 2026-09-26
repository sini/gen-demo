# `pkgs-bearing-node-value` — C72, den-hoag-tssb2. A node value that carries the package set
# flows through the memo plane and evaluates. `genMemo`'s hash walk forces every position of a value
# and nixpkgs holds lazy throws no cold read reaches (its first attribute in name order is one), so
# the walk used to throw where a cold read of the same node succeeded. A walk that throws now hashes
# to `null`, which the plane reads as always-dirty: the node is recomputed rather than reused and the
# answer is the cold one.
#
# The corpus brings the reference scheduler's five lines, as C66 does.
#
# C72 -- den-hoag-tssb2. Live control: the same chain over plain values carries a real hash, so
# the null is the fallback firing and not a hash the plane never took.
{
  asserts,
  genMemo,
  lib,
  pkgs,
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
  pkgsBearing = w: {
    inherit w pkgs;
  };
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
      recompute = recompute pkgsBearing;
    }).store;
  read = store: [
    store.bobbin.w
    store.reel.pkgs.hello.pname
  ];
in
{
  construct = [ "C72" ];
  check = asserts (
    read (warm pkgsBearing).store == [
      211
      "hello"
    ]
    && read (warm pkgsBearing).store == read cold
    && (warm pkgsBearing).trace.reel.hash == null
    && builtins.isString (warm plain).trace.reel.hash
  );
}
