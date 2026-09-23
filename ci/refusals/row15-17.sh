# shellcheck shell=bash
# ── rows 15/16 -- a kind registry that never passed `mkKinds` (mirrors C18's kinded node set) ──
#
# The plant is a registry whose `below` relation is CYCLIC -- `bolt` ranks below itself -- which
# `mkKinds` refuses at construction and `mkKind` does not, because acyclicity is a property of
# the SET and no single kind record can see the set. Handed such a registry the evaluator's spawn
# channel expands without bound, so what these rows hold is not a nicer message: it is that a
# BOUNDED refusal replaced an UNCATCHABLE `stack overflow`, which `builtins.tryEval` cannot
# contain and from which a caller receives no value at all. Row 17 is that half.
#
# The unplanted arms run the SAME shape through a registry that DID pass `mkKinds`, descending
# `bolt -> thread`, so the one spawn fires and the node list carries its product. Without them a
# library refusing every registry there is would pass both planted arms.
registry='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  spawnOf = _self: id: { "${id}-thread" = { id = "${id}-thread"; parent = id; decls = { }; }; };
  minted = genScope.mkKinds [
    (genScope.mkKind { name = "bolt"; below = [ "thread" ]; spawns.thread = spawnOf; })
    (genScope.mkKind { name = "thread"; })
  ];
  forged = { kinds = { bolt = genScope.mkKind { name = "bolt"; below = [ "bolt" ]; spawns.bolt = spawnOf; }; }; };
in '

# ── row 15 -- the DIRECT path: the substrate constructor and then its evaluator ──
row15="$registry"'builtins.toJSON (genScope.eval {
  scope = genScope.buildRoots { parentGraph = genScope.vertex "selvage"; types.selvage = "bolt"; decls.selvage = { }; kinds = REGISTRY; };
  attributes.children = _self: _id: { };
}).allNodeIds'
check "T5 row15 unplanted (a registry mkKinds built, bolt above thread)" "${row15/REGISTRY/minted}" 0 "" \
  "$tmpdir/row15-green.err" '["selvage","selvage-thread"]'
check "T5 row15 planted   (a registry mkKinds never saw, bolt below itself)" "${row15/REGISTRY/forged}" 1 \
  "gen-scope.buildRoots: \`scope.kinds\` must be the registry \`mkKinds\` returns; received an attrset that \`mkKinds\` did not build" \
  "$tmpdir/row15-red.err"

# ── row 16 -- the PROTOCOL path: the same registry as a call parameter to the framework
# toolkit, which is how C18 routes it. The refusal reaches `assemble`'s caller from the
# substrate, with no guard of gen-assemble's own -- which is what makes one door enough. ──
row16="$registry"'builtins.toJSON (builtins.attrNames (gen.lib.framework.assemble.assemble {
  contributions = [ { name = "selvedge"; vertices = [ "selvage" ]; decls.selvage = { }; types.selvage = "bolt"; } ];
  kinds = REGISTRY;
}).nodes)'
check "T5 row16 unplanted (the minted registry through the contribution protocol)" "${row16/REGISTRY/minted}" 0 "" \
  "$tmpdir/row16-green.err" '["selvage"]'
check "T5 row16 planted   (the forged registry through the contribution protocol)" "${row16/REGISTRY/forged}" 1 \
  "gen-scope.buildRoots: \`scope.kinds\` must be the registry \`mkKinds\` returns; received an attrset that \`mkKinds\` did not build" \
  "$tmpdir/row16-red.err"

# ── row 17 -- CATCHABILITY, and it is a THIRD PLANTED ARM rather than an unplanted one: it runs
# on the forged registry too, so it discharges neither pairing above. A stderr substring alone
# cannot tell a caught refusal from an uncatchable abort that happens to print the right words --
# before this guard the same call exited 1 with `stack overflow; max-call-depth exceeded` THROUGH
# this very `tryEval`, and `want_stdout CAUGHT` at exit 0 is the only arm that separates them. ──
row17="$registry"'if (builtins.tryEval (builtins.deepSeq (genScope.buildRoots {
  parentGraph = genScope.vertex "selvage"; types.selvage = "bolt"; decls.selvage = { }; kinds = forged;
}) "ADMITTED")).success then "ADMITTED" else "CAUGHT"'
check "T5 row17 planted   (the forged registry refuses CATCHABLY, not by overflowing)" "$row17" 0 "" \
  "$tmpdir/row17.err" 'CAUGHT'
