# shellcheck shell=bash
# ── row 24 -- a spawned key colliding with an already-registered node's id (gen-scope, flavor B,
# den-hoag-n03z). Exercises flavor (B) alone (spec §2.3): neither (A) (§4.1, open), nor (C) same-host,
# nor (D) cross-host (§4.2, open) are discharged by it. ──
row24Base='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  spawnOf = _self: id: { "KEYNAME" = { id = "KEYNAME"; parent = id; decls = { }; }; };
  kinds = genScope.mkKinds [
    (genScope.mkKind { name = "bolt"; below = [ "thread" ]; spawns.thread = spawnOf; })
    (genScope.mkKind { name = "thread"; })
  ];
in builtins.toJSON (genScope.eval {
  scope = genScope.buildRoots {
    parentGraph = genScope.overlay (genScope.vertex "selvage") (genScope.vertex "bobbin");
    types.selvage = "bolt"; types.bobbin = "thread";
    decls.selvage = { }; decls.bobbin = { };
    kinds = kinds;
  };
  attributes.children = _self: _id: { };
}).allNodeIds'
row24="${row24Base//KEYNAME/warp}"
row24planted="${row24Base//KEYNAME/bobbin}"

# Mirrors row17's own idiom exactly: a standalone literal wrapping the PLANTED construction's
# `.allNodeIds` in `tryEval`+`deepSeq`, so `want_stdout CAUGHT` at exit 0 is the only arm that tells a
# caught refusal apart from an uncatchable abort that happens to print similar words.
row24catch='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  spawnOf = _self: id: { "bobbin" = { id = "bobbin"; parent = id; decls = { }; }; };
  kinds = genScope.mkKinds [
    (genScope.mkKind { name = "bolt"; below = [ "thread" ]; spawns.thread = spawnOf; })
    (genScope.mkKind { name = "thread"; })
  ];
in if (builtins.tryEval (builtins.deepSeq (genScope.eval {
  scope = genScope.buildRoots {
    parentGraph = genScope.overlay (genScope.vertex "selvage") (genScope.vertex "bobbin");
    types.selvage = "bolt"; types.bobbin = "thread";
    decls.selvage = { }; decls.bobbin = { };
    kinds = kinds;
  };
  attributes.children = _self: _id: { };
}).allNodeIds "ADMITTED")).success then "ADMITTED" else "CAUGHT"'

check "T5 row24 unplanted (a fresh spawn key, colliding with nothing)" "$row24" 0 "" \
  "$tmpdir/row24-green.err" '["selvage","warp","bobbin"]'
check "T5 row24 planted   (the spawn key collides with a second registered root's id)" "$row24planted" 1 \
  "already a registered node's id" \
  "$tmpdir/row24-red.err"
check "T5 row24 catchable  (the collision refuses CATCHABLY, not by overflowing)" "$row24catch" 0 "" \
  "$tmpdir/row24-catch.err" 'CAUGHT'
