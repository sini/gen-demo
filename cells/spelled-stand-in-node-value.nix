# `spelled-stand-in-node-value` — C124, den-hoag-x67vn. A node value whose data spells the stand-in
# the memo plane writes for `outPath` flows through the plane, and an edit between the two spellings
# reaches its dependent. The plane blinds `outPath` to `__outPath` so that `toJSON` does not read the
# record as that string alone, and before its keys were escaped a literal `__outPath` hashed the
# same: the edited producer read UNCHANGED and its dependent kept the stale answer, so the warm
# answer differed from the cold one. Every key now enters the image through one injective escape,
# so no user data can spell a stand-in, and the producer moves.
#
# The corpus brings the reference scheduler's five lines, as C66 does.
#
# C124 -- den-hoag-x67vn. Live control: the producer's trace hash is a string, so the record was
# hashed and not sent always-dirty; a null hash would also reach the cold answer and decide nothing.
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

  # bobbin -> reel: `reel` is a record keyed by the spelling `nodeData` names; `bobbin` reads which.
  accessor = {
    nodes = [
      "bobbin"
      "reel"
    ];
    dependencies = id: { bobbin = [ "reel" ]; }.${id} or [ ];
    nodeData = id: { reel.key = "outPath"; }.${id} or { };
  };
  recompute =
    acc: store: id:
    if id == "reel" then
      { ${(acc.nodeData id).key} = "/nix/store/selvage"; }
    else
      { spelled = store.reel ? __outPath; };
  hashOf = v: builtins.hashString "sha256" (builtins.toJSON v);

  warm = genMemo.propagateEager engine (genMemo.build { } engine {
    inherit accessor hashOf recompute;
  }) { reel.key = "__outPath"; };
  cold =
    (genMemo.build { } engine {
      accessor = accessor // {
        nodeData = id: if id == "reel" then { key = "__outPath"; } else accessor.nodeData id;
      };
      inherit hashOf recompute;
    }).store;
in
{
  construct = [ "C124" ];
  check = asserts (
    warm.store.bobbin.spelled
    && warm.store.bobbin == cold.bobbin
    && builtins.isString warm.trace.reel.hash
  );
}
