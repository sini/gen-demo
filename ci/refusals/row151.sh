# shellcheck shell=bash
# ── row 151 -- two spawns on ONE host producing the same key are refused by name (gen-scope 3bc03e52,
#    den-hoag-n03z flavor C; ADR-0025 item 1) ──
# Row 24 declares flavor B alone (a spawned key colliding with a registered node's id). The landing's
# other limb is the sibling collision: a host kind with two spawn channels whose builders return the
# same key silently overwrote one another, last occurrence winning by fold order. The unplanted arm
# gives the two spawns distinct keys and both mint.
row151='let
  genScope = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  spawnOf = key: _self: id: builtins.listToAttrs [ { name = key; value = { id = key; parent = id; decls = { }; }; } ];
  ids = (genScope.eval { } {
    children = _self: _id: { };
  } (genScope.buildRoots {
    parentGraph = genScope.vertex "a";
    types.a = "host";
    decls.a = { };
    kinds = genScope.mkKinds [
      (genScope.mkKind { } "leafOne")
      (genScope.mkKind { } "leafTwo")
      (genScope.mkKind {
        below = [ "leafOne" "leafTwo" ];
        spawns.leafOne = spawnOf "warp";
        spawns.leafTwo = spawnOf "SECOND";
      } "host")
    ];
  })).allNodeIds;
in BODY'
row151ids='builtins.toJSON (builtins.sort builtins.lessThan ids)'
row151catch='if (builtins.tryEval (builtins.deepSeq ids true)).success then "ADMITTED" else "CAUGHT"'
row151ok="${row151/SECOND/weft}"
row151bad="${row151/SECOND/warp}"
check "T5 row151 unplanted (two spawns on one host with distinct keys both mint)" \
  "${row151ok/BODY/$row151ids}" 0 "" "$tmpdir/row151-green.err" '["a","warp","weft"]'
check "T5 row151 planted   (two spawns on one host producing one key are refused by name)" \
  "${row151bad/BODY/$row151ids}" 1 \
  "which an earlier spawn on this same host already produced" \
  "$tmpdir/row151-red.err"
check "T5 row151 catchable  (the sibling collision refuses CATCHABLY, not by overflowing)" \
  "${row151bad/BODY/$row151catch}" 0 "" "$tmpdir/row151-catch.err" 'CAUGHT'
