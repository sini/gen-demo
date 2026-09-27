# shellcheck shell=bash
# ── row 102 -- two minted registries merged with `//`, row 15's merge path (mirrors C18's kinded
# node set) ──
#
# Two registries `mkKinds` minted from declarations that disagree -- `bolt` above `thread` in one,
# `thread` above `bolt` in the other -- merged with `//`. The merge files under `thread` a kind that
# differs from the `thread` the `bolt` kind resolved when it was minted, and the registry door
# refuses it by name. Before the fold the merge kept the registry's provenance tag, passed the door,
# and the spawn chain re-routed through the other registry's `thread` and diverged UNCATCHABLY.
# Termination no longer rests on this refusal: the evaluator follows the kind records each kind
# resolved, so what the door refuses is the name map disagreeing with them.
#
# The unplanted arm merges two registries that share an IDENTICAL `thread`, which is coherent and
# admitted, its one spawn firing.
row102Registry='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  spawnOf = _self: id: { "${id}-thread" = { id = "${id}-thread"; parent = id; decls = { }; }; };
  thread = genScope.mkKind { name = "thread"; };
  minted = genScope.mkKinds [
    thread
    (genScope.mkKind { name = "bolt"; below = [ "thread" ]; spawns.thread = spawnOf; })
  ];
  upside = genScope.mkKinds [
    (genScope.mkKind { name = "bolt"; })
    (genScope.mkKind { name = "thread"; below = [ "bolt" ]; spawns.bolt = spawnOf; })
  ];
  spool = genScope.mkKinds [
    thread
    (genScope.mkKind { name = "spool"; below = [ "thread" ]; spawns.thread = spawnOf; })
  ];
  merged = minted // { kinds = minted.kinds // { inherit (upside.kinds) thread; }; };
  coherent = minted // { kinds = minted.kinds // spool.kinds; };
  scopeWith = kinds: genScope.buildRoots { parentGraph = genScope.vertex "selvage"; types.selvage = "bolt"; decls.selvage = { }; inherit kinds; };
in '
row102="$row102Registry"'builtins.toJSON (genScope.eval { scope = scopeWith REGISTRY; attributes.children = _self: _id: { }; }).allNodeIds'
row102Catch="$row102Registry"'if (builtins.tryEval (builtins.deepSeq (scopeWith merged) "ADMITTED")).success then "ADMITTED" else "CAUGHT"'

check "T5 row102 unplanted (two registries sharing one thread, merged)" "${row102/REGISTRY/coherent}" 0 "" \
  "$tmpdir/row102-green.err" '["selvage","selvage-thread"]'
check "T5 row102 planted   (two registries filing two different threads, merged)" "${row102/REGISTRY/merged}" 1 \
  "files under 'thread' a kind that differs from the kind 'thread' that entry 'bolt' resolved" \
  "$tmpdir/row102-red.err"
check "T5 row102 catchable (the merge refuses CATCHABLY, not by diverging)" "$row102Catch" 0 "" \
  "$tmpdir/row102-catch.err" 'CAUGHT'
