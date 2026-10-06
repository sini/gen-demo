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
    (genScope.mkKind { } "thread")
    (genScope.mkKind {
      below = [ "thread" ];
      spawns.thread = spawnOf;
    } "bolt")
  ];
  selfNaming = genScope.mkKind {
    below = [ "bolt" ];
    spawns.bolt = spawnOf;
  } "bolt";
  forged = { kinds = { bolt = selfNaming; }; };
in '

# ── row 15 -- the DIRECT path: the substrate constructor and then its evaluator ──
row_kind_that_names_itself="$registry"'builtins.toJSON (genScope.eval { } {
  children = _self: _id: { };
} (genScope.buildRoots { parentGraph = genScope.vertex "selvage"; types.selvage = "bolt"; decls.selvage = { }; kinds = REGISTRY; })).allNodeIds'
check "T5 kind-that-names-itself unplanted (a registry mkKinds minted, bolt above thread)" "${row_kind_that_names_itself/REGISTRY/minted}" 0 "" \
  "$tmpdir/kind-that-names-itself-green.err" '["selvage","selvage-thread"]'
check "T5 kind-that-names-itself planted   (mkKinds cannot mint bolt below itself)" "$registry"'builtins.toJSON (builtins.attrNames (genScope.mkKinds [ selfNaming ]).kinds)' 1 \
  "gen-scope.mkKinds: kind 'bolt' names 'bolt' in \`below\`, which no kind registered before it carries" \
  "$tmpdir/kind-that-names-itself-mint.err"
check "T5 kind-that-names-itself planted   (a registry of declarations, bolt below itself)" "${row_kind_that_names_itself/REGISTRY/forged}" 1 \
  "gen-scope.buildRoots: \`scope.kinds\` must be a kind registry, whose \`kinds\` maps each name to the kind \`mkKinds\` minted under it; holds entries that are not minted kinds" \
  "$tmpdir/kind-that-names-itself-red.err"

# ── row 16 -- the PROTOCOL path: the same registry as a call parameter to the framework
# toolkit, which is how C18 routes it. The refusal reaches `assemble`'s caller from the
# substrate, with no guard of gen-assemble's own -- which is what makes one door enough. ──
row_minted_registry_through_the_contribution_protocol="$registry"'builtins.toJSON (builtins.attrNames (gen.lib.framework.assemble.assemble { kinds = REGISTRY; } [ { name = "selvedge"; vertices = [ "selvage" ]; decls.selvage = { }; types.selvage = "bolt"; } ]).nodes)'
check "T5 minted-registry-through-the-contribution-protocol unplanted (the minted registry through the contribution protocol)" "${row_minted_registry_through_the_contribution_protocol/REGISTRY/minted}" 0 "" \
  "$tmpdir/minted-registry-through-the-contribution-protocol-green.err" '["selvage"]'
check "T5 minted-registry-through-the-contribution-protocol planted   (the forged registry through the contribution protocol)" "${row_minted_registry_through_the_contribution_protocol/REGISTRY/forged}" 1 \
  "gen-scope.buildRoots: \`scope.kinds\` must be a kind registry, whose \`kinds\` maps each name to the kind \`mkKinds\` minted under it; holds entries that are not minted kinds" \
  "$tmpdir/minted-registry-through-the-contribution-protocol-red.err"

# ── row 17 -- CATCHABILITY, and it is a THIRD PLANTED ARM rather than an unplanted one: it runs
# on the forged registry too, so it discharges neither pairing above. A stderr substring alone
# cannot tell a caught refusal from an uncatchable abort that happens to print the right words --
# before the registry door the same call exited 1 with `stack overflow; max-call-depth exceeded`
# THROUGH this very `tryEval`, and `want_stdout CAUGHT` at exit 0 is the only arm that separates
# them. ──
row_forged_registry_refuses_catchably="$registry"'if (builtins.tryEval (builtins.deepSeq (genScope.buildRoots {
  parentGraph = genScope.vertex "selvage"; types.selvage = "bolt"; decls.selvage = { }; kinds = forged;
}) "ADMITTED")).success then "ADMITTED" else "CAUGHT"'
check "T5 forged-registry-refuses-catchably planted   (the forged registry refuses CATCHABLY, not by overflowing)" "$row_forged_registry_refuses_catchably" 0 "" \
  "$tmpdir/forged-registry-refuses-catchably.err" 'CAUGHT'
