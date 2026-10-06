# shellcheck shell=bash
# ── row 151 -- two spawns on ONE host producing the same key are refused by name (gen-scope 3bc03e52,
#    den-hoag-n03z flavor C; ADR-0025 item 1) ──
# Row 24 declares flavor B alone (a spawned key colliding with a registered node's id). The landing's
# other limb is the sibling collision: a host kind with two spawn channels whose builders return the
# same key silently overwrote one another, last occurrence winning by fold order. The unplanted arm
# gives the two spawns distinct keys and both mint.
row_two_spawns_on_one_host_producing_the_same_key='let
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
row_two_spawns_on_one_host_producing_the_same_keyids='builtins.toJSON (builtins.sort builtins.lessThan ids)'
row_two_spawns_on_one_host_producing_the_same_keycatch='if (builtins.tryEval (builtins.deepSeq ids true)).success then "ADMITTED" else "CAUGHT"'
row_two_spawns_on_one_host_producing_the_same_keyok="${row_two_spawns_on_one_host_producing_the_same_key/SECOND/weft}"
row_two_spawns_on_one_host_producing_the_same_keybad="${row_two_spawns_on_one_host_producing_the_same_key/SECOND/warp}"
check "T5 two-spawns-on-one-host-producing-the-same-key unplanted (two spawns on one host with distinct keys both mint)" \
  "${row_two_spawns_on_one_host_producing_the_same_keyok/BODY/$row_two_spawns_on_one_host_producing_the_same_keyids}" 0 "" "$tmpdir/two-spawns-on-one-host-producing-the-same-key-green.err" '["a","warp","weft"]'
check "T5 two-spawns-on-one-host-producing-the-same-key planted   (two spawns on one host producing one key are refused by name)" \
  "${row_two_spawns_on_one_host_producing_the_same_keybad/BODY/$row_two_spawns_on_one_host_producing_the_same_keyids}" 1 \
  "which an earlier spawn on this same host already produced" \
  "$tmpdir/two-spawns-on-one-host-producing-the-same-key-red.err"
check "T5 two-spawns-on-one-host-producing-the-same-key catchable  (the sibling collision refuses CATCHABLY, not by overflowing)" \
  "${row_two_spawns_on_one_host_producing_the_same_keybad/BODY/$row_two_spawns_on_one_host_producing_the_same_keycatch}" 0 "" "$tmpdir/two-spawns-on-one-host-producing-the-same-key-catch.err" 'CAUGHT'
