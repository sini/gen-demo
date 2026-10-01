# `drv-bearing-node-value` — C124, den-hoag-c5cj. A node value that IS a package, overlaid with `//`,
# flows through the memo plane, hashes, and an edit to the overlay reaches its dependent. A `//`
# overlay keeps the package's drvPath, and the plane used to hash a derivation on its drvPath alone,
# so the edited producer read UNCHANGED and its dependent kept the stale overlay: the warm answer
# differed from the cold one. A derivation's image now carries its own attributes beside the
# drvPath, so the producer moves and the dependent recomputes.
#
# The corpus brings the reference scheduler's five lines, as C66 does.
#
# C124 -- den-hoag-c5cj. Live control: the producer's trace hash is a string, so the package was
# hashed and not sent always-dirty; a null hash would also reach the cold answer and decide nothing.
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

  # bobbin -> reel: `reel` is `hello` overlaid with a description; `bobbin` reads it.
  accessor = {
    nodes = [
      "bobbin"
      "reel"
    ];
    dependencies = id: { bobbin = [ "reel" ]; }.${id} or [ ];
    nodeData = id: { reel.description = "spun"; }.${id} or { };
  };
  recompute =
    acc: store: id:
    if id == "reel" then
      pkgs.hello // { meta.description = (acc.nodeData id).description; }
    else
      { description = store.reel.meta.description; };
  hashOf = v: builtins.hashString "sha256" (builtins.toJSON v);

  warm = genMemo.propagateEager engine (genMemo.build { } engine {
    inherit accessor hashOf recompute;
  }) { reel.description = "woven"; };
  cold =
    (genMemo.build { } engine {
      accessor = accessor // {
        nodeData = id: if id == "reel" then { description = "woven"; } else accessor.nodeData id;
      };
      inherit hashOf recompute;
    }).store;
in
{
  construct = [ "C124" ];
  check = asserts (
    warm.store.bobbin.description == "woven"
    && warm.store.bobbin == cold.bobbin
    && builtins.isString warm.trace.reel.hash
  );
}
