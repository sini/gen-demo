# shellcheck shell=bash
# ── rows 15/16 -- a kind that names itself, and a registry of declarations (mirrors C18's kinded
# node set) ──
#
# `mkKind` returns a DECLARATION, and `mkKinds` is the only producer of a kind: a fold over an
# ordered list that resolves each `below` name against the kinds minted before it. So `bolt`
# ranking below itself is a declaration nothing can mint -- row 15's first planted arm -- and a
# registry assembled by hand out of that declaration is a TYPE error at the door, refused by name
# as a declaration rather than a kind. Before the fold, such a registry reached the evaluator's
# spawn channel and expanded without bound, an UNCATCHABLE `stack overflow` from which a caller
# received no value at all. Row 17 is the catchability half.
#
# The unplanted arms run the SAME shape through a registry `mkKinds` minted, `thread` declared
# before the `bolt` whose `below` names it, so the one spawn fires and the node list carries its
# product. Without them a library refusing every registry there is would pass the planted arms.
registry='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  spawnOf = _self: id: { "${id}-thread" = { id = "${id}-thread"; parent = id; decls = { }; }; };
  minted = genScope.mkKinds [
    (genScope.mkKind { name = "thread"; })
    (genScope.mkKind { name = "bolt"; below = [ "thread" ]; spawns.thread = spawnOf; })
  ];
  selfNaming = genScope.mkKind { name = "bolt"; below = [ "bolt" ]; spawns.bolt = spawnOf; };
  forged = { kinds = { bolt = selfNaming; }; };
in '

# ── row 15 -- the DIRECT path: the substrate constructor and then its evaluator ──
row15="$registry"'builtins.toJSON (genScope.eval {
  scope = genScope.buildRoots { parentGraph = genScope.vertex "selvage"; types.selvage = "bolt"; decls.selvage = { }; kinds = REGISTRY; };
  attributes.children = _self: _id: { };
}).allNodeIds'
check "T5 row15 unplanted (a registry mkKinds minted, bolt above thread)" "${row15/REGISTRY/minted}" 0 "" \
  "$tmpdir/row15-green.err" '["selvage","selvage-thread"]'
check "T5 row15 planted   (mkKinds cannot mint bolt below itself)" "$registry"'builtins.toJSON (builtins.attrNames (genScope.mkKinds [ selfNaming ]).kinds)' 1 \
  "gen-scope.mkKinds: kind 'bolt' names 'bolt' in \`below\`, which no kind registered before it carries" \
  "$tmpdir/row15-mint.err"
check "T5 row15 planted   (a registry of declarations, bolt below itself)" "${row15/REGISTRY/forged}" 1 \
  "gen-scope.buildRoots: \`scope.kinds\` must be a kind registry, whose \`kinds\` maps each name to the kind \`mkKinds\` minted under it; holds entries that are not minted kinds" \
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
  "gen-scope.buildRoots: \`scope.kinds\` must be a kind registry, whose \`kinds\` maps each name to the kind \`mkKinds\` minted under it; holds entries that are not minted kinds" \
  "$tmpdir/row16-red.err"

# ── row 17 -- CATCHABILITY, and it is a THIRD PLANTED ARM rather than an unplanted one: it runs
# on the forged registry too, so it discharges neither pairing above. A stderr substring alone
# cannot tell a caught refusal from an uncatchable abort that happens to print the right words --
# before the registry door the same call exited 1 with `stack overflow; max-call-depth exceeded`
# THROUGH this very `tryEval`, and `want_stdout CAUGHT` at exit 0 is the only arm that separates
# them. ──
row17="$registry"'if (builtins.tryEval (builtins.deepSeq (genScope.buildRoots {
  parentGraph = genScope.vertex "selvage"; types.selvage = "bolt"; decls.selvage = { }; kinds = forged;
}) "ADMITTED")).success then "ADMITTED" else "CAUGHT"'
check "T5 row17 planted   (the forged registry refuses CATCHABLY, not by overflowing)" "$row17" 0 "" \
  "$tmpdir/row17.err" 'CAUGHT'
