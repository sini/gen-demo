#!/usr/bin/env bash
# T5 (ADR-0025) -- one plant per enforcer, refused BY NAME. `builtins.tryEval` cannot read a
# refusal's message (that is a property of the builtin, not of Nix -- `den-hoag-9mo`), so the
# by-name half runs here, out of band, rather than as a `checks` cell. Each plant mirrors the
# construction its own C-numbered construct in flake.nix uses -- never imports it, since a
# standalone plant must not perturb the corpus's own declarations -- and every probe below is run
# BOTH planted (must refuse, by name) and unplanted (must not refuse), because a construction that
# refused unconditionally would pass the planted arm for the wrong reason. Every exit is read
# UNPIPED: a piped `$?` reports the last stage of the pipe, not nix's.
#
# Reached as the devshell command `refusals` (`ci/flake.nix`), which is what makes the plane
# schedulable: the workflow runs it, and `ci/tests/refusals-pairing.nix` holds the pairing above
# to a cell so a row that loses an arm reds `nix flake check ./ci` rather than passing quietly.
set -u

# Run from the repository root. Every probe below evaluates `builtins.getFlake (toString ./.)`,
# which resolves against the CWD; `just` supplied that by running recipes from the justfile's
# directory, and as a devshell command the script supplies it itself.
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
fail=0

# A fresh dir per run -- two concurrent `refusals` runs no longer collide on a fixed /tmp name.
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# $1 label, $2 nix expr, $3 wanted exit code, $4 required stderr substring (empty = none checked),
# $5 file to capture this row's stderr into (for the cross-row control at the end),
# $6 wanted stdout, exact match (empty = none checked -- the planted arms, which refuse before
# producing a value; every unplanted arm passes one, so a construction that refused everything
# cannot pass this arm by exiting 0 with the wrong (or no) value).
check() {
  local label="$1" expr="$2" want_exit="$3" want_grep="$4" errfile="$5" want_stdout="${6:-}"
  local out
  out="$(nix eval --impure --raw --expr "$expr" 2>"$errfile")"
  local ec=$?
  if [ "$ec" != "$want_exit" ]; then
    echo "FAIL $label: exit $ec, wanted $want_exit"
    sed -n '1,5p' "$errfile"
    fail=1
    return
  fi
  if [ -n "$want_grep" ] && ! grep -qF "$want_grep" "$errfile"; then
    echo "FAIL $label: required substring not in stderr"
    echo "  wanted: $want_grep"
    fail=1
    return
  fi
  if [ -n "$want_stdout" ] && [ "$out" != "$want_stdout" ]; then
    echo "FAIL $label: stdout mismatch"
    echo "  wanted: $want_stdout"
    echo "  got:    $out"
    fail=1
    return
  fi
  echo "ok   $label (exit $ec)"
}

# ── row 1 -- a binding relatum minted in the SAME pass (mirrors C3's mintStrata) ──
row1='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  emitters = pass1: [
    { pass = 0; identifier = "pewter"; kind = "thimble"; relata = { }; content = { spool = "linen"; }; site = "c:pewter"; }
    { pass = 0; identifier = "grosgrain"; kind = "bobbin"; relata = { }; content = { gauge = "fine"; }; site = "c:gros"; }
    { pass = pass1; identifier = "basting:pewter:grosgrain"; kind = "basting"; content = { tension = "slack"; }; relata = { warp = "pewter"; weft = "grosgrain"; }; site = "c:basting"; }
  ];
in builtins.toJSON (builtins.attrNames (genScope.mintStrata { kinds = { }; emitters = emitters PASS; }).nodes)'
check "T5 row1 unplanted (basting minted strictly later)" "${row1/PASS/1}" 0 "" \
  "$tmpdir/row1-green.err" '["basting:pewter:grosgrain","grosgrain","pewter"]'
check "T5 row1 planted   (basting minted in the same pass)" "${row1/PASS/0}" 1 \
  "gen-scope.mintStrata: unresolved relatum 'pewter' (label 'warp', minting kind 'basting', pass 0)" \
  "$tmpdir/row1-red.err"

# ── row 2 -- a policy relatum not in `frozen` (mirrors C5's program) ──
row2='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genProgram = gen.lib.framework.program;
  mkProg = frozenList: genProgram.program {
    frozen = frozenList;
    declarations = [
      { head = "nap:pewter"; relata = [ "pewter" ]; }
      { head = "piping:grosgrain:faille"; pos = [ "nap:pewter" ]; neg = [ "scotched:pewter" ]; relata = [ "grosgrain" "faille" ]; }
    ];
  };
in builtins.toJSON (mkProg FROZEN).atoms'
check "T5 row2 unplanted (faille frozen)" "${row2/FROZEN/[ \"pewter\" \"damask\" \"grosgrain\" \"faille\" ]}" 0 "" \
  "$tmpdir/row2-green.err" '["nap:pewter","piping:grosgrain:faille","scotched:pewter"]'
check "T5 row2 planted   (faille not frozen)" "${row2/FROZEN/[ \"pewter\" \"damask\" \"grosgrain\" ]}" 1 \
  "gen-program: 'faille' is not in the frozen set of relata that strictly earlier passes settled (ADR-0016 ruling 7)" \
  "$tmpdir/row2-red.err"

# ── row 3 -- a Λ ∩ L collision in the carrier (mirrors C4's carrier, the label renamed at C3's
# own relata source, same seed the acceptance oracle uses to red C4 itself) ──
row3='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genView = gen.lib.substrate.view;
  mkCarrier = warpLabel:
    let
      bastingRelata = { ${warpLabel} = "pewter"; weft = "grosgrain"; };
      movementLabels = genView.edgeLabels { letters = [ "tacks" ]; };
    in genView.carrier {
      labels = movementLabels;
      relations = genView.relations { names = [ "gimp" ]; };
      relatumLabels = genView.relatumLabels { names = builtins.attrNames bastingRelata; };
      labelWellFormedness = genView.labelWellFormedness { alphabet = movementLabels; expression = "tacks*"; };
      labelOrder = genView.labelOrder { alphabet = movementLabels; layers = [ [ "tacks" ] ]; endOfPath = -1; };
      dataOrder = genView.dataOrder { channel = "selvage"; keyOf = _: "selvage"; };
    };
in builtins.toJSON (mkCarrier "LABEL").relatumLabels.names'
check "T5 row3 unplanted (relatum labelled warp)" "${row3/LABEL/warp}" 0 "" \
  "$tmpdir/row3-green.err" '["warp","weft"]'
check "T5 row3 planted   (relatum relabelled tacks, collides with L)" "${row3/LABEL/tacks}" 1 \
  "gen-view.carrier: 'tacks' is both a letter of L and a relatum label in Λ" \
  "$tmpdir/row3-red.err"

# ── row 4 -- reading `.included` on an UNDEFINED atom (mirrors C5's model/resolve). The field
# is FORCED here on purpose: reading the whole record instead exits 0 with the message rendered
# inline on stdout (`«error: ...»`), which is the trap this oracle exists to close.
row4='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genProgram = gen.lib.framework.program;
  mkModel = negSelf: genProgram.model {
    program = genProgram.program {
      frozen = [ "pewter" ];
      declarations = [ { head = "nap:pewter"; neg = if negSelf then [ "nap:pewter" ] else [ ]; relata = [ "pewter" ]; } ];
    };
    interpretation = [ ];
    complete = true;
  };
in builtins.toJSON ((mkModel SELFNEG).resolve "nap:pewter").included'
check "T5 row4 unplanted (nap:pewter an ordinary fact)" "${row4/SELFNEG/false}" 0 "" \
  "$tmpdir/row4-green.err" "true"
check "T5 row4 planted   (nap:pewter self-negates, UNDEFINED)" "${row4/SELFNEG/true}" 1 \
  "gen-program: the membership 'nap:pewter' is UNDEFINED — ADR-0020's third value" \
  "$tmpdir/row4-red.err"

# ── row 5 -- `gen.aspectCnf` absent (mirrors C6's extra `project` call) ──
row5='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genDelivery = gen.lib.framework.delivery;
  vals = { thimbles.pewter = { aspects = [ "stitch" ]; }; thimbles.damask = { aspects = [ ]; }; aspects.stitch.nixos = { foo = "bar"; }; };
  mkProj = withCnf: genDelivery.project {
    values = vals;
    cnf = if withCnf then (import ./aspect-cnf.nix) else null;
    selectNodes = v: v.thimbles or { };
  };
in builtins.toJSON (builtins.attrNames (mkProj WITHCNF).nodes)'
check "T5 row5 unplanted (cnf present)" "${row5/WITHCNF/true}" 0 "" \
  "$tmpdir/row5-green.err" '["damask","pewter"]'
check "T5 row5 planted   (cnf absent)" "${row5/WITHCNF/false}" 1 \
  "gen-delivery: project: no category source — \`cnf\` is required and has no default." \
  "$tmpdir/row5-red.err"

# ── row 6 -- an edge/decls id not a declared member (mirrors C8's contribution protocol) ──
row6='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  genAssemble = gen.lib.framework.assemble;
  thimbles = { name = "thimbles"; vertices = [ "pewter" "damask" ];
    decls = { pewter = { spool = "linen"; aspects = [ "stitch" ]; }; damask = { spool = "sateen"; aspects = [ ]; }; }; };
  mkBobbins = bobbinVertices: { name = "bobbins"; vertices = bobbinVertices;
    edgeGraphs = [ { label = "tacks"; graph = genScope.edge "pewter" "grosgrain"; } ];
    decls = { grosgrain = { gauge = "fine"; }; faille = { gauge = "coarse"; }; }; };
in builtins.toJSON (builtins.attrNames (genAssemble.assemble { contributions = [ thimbles (mkBobbins BOBBINVERTICES) ]; }).nodes)'
check "T5 row6 unplanted (grosgrain declared a member)" "${row6/BOBBINVERTICES/[ \"grosgrain\" \"faille\" ]}" 0 "" \
  "$tmpdir/row6-green.err" '["damask","faille","grosgrain","pewter"]'
check "T5 row6 planted   (grosgrain named by an edge and a decls entry, never a declared member)" \
  "${row6/BOBBINVERTICES/[ \"faille\" ]}" 1 \
  "gen-assemble: the contribution \`bobbins\` carries an edge under the label \`tacks\` whose \`to\` endpoint \`grosgrain\` is not a declared member" \
  "$tmpdir/row6-red.err"

# ── row 7 -- a required facet left unwired (mirrors C11's federated subgraph) ──
row7='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genLink = gen.lib.aspects.link;
  genAspects = gen.lib.aspects.aspects;
  genMerge = gen.lib.modules.merge;
  facetOpt = genMerge.mkOption { type = genMerge.types.raw; default = null; };
  selvageFacets = { selvageCap = { category = "facet"; contract = "capability"; option = facetOpt; };
                     selvageReq = { category = "facet"; contract = "capability"; option = facetOpt; }; };
  mkReg = modules: let schema = genAspects.mkAspectSchema { keySemantics = selvageFacets; }; in
    genMerge.evalModuleTree { modules = [ { options.schema = schema.schemaOption; } (schema.mkAspectModule { }) ] ++ modules; };
  mill = mkReg [ { config.aspects.stitch.selvageCap = { provides = [ "warp" "weft" ]; }; } ];
  loom = mkReg [ { config.aspects.braid = { selvageReq = { requires = [ "warp" ]; }; includes = [ (genAspects.keyRef "mill/stitch") ]; }; } ];
  mkFederated = wired: genLink.link {
    sources = [ { registry = mill.config.aspects; keySemantics = selvageFacets; origin = [ "mill" ]; }
                 { registry = loom.config.aspects; keySemantics = selvageFacets; origin = [ "loom" ]; } ];
    wire = if wired then { "loom/braid".selvageReq = "mill/stitch"; } else { }; };
in builtins.toJSON (mkFederated WIRED).resolved'
check "T5 row7 unplanted (braid's capability requirement wired to the mill)" "${row7/WIRED/true}" 0 "" \
  "$tmpdir/row7-green.err" '{"loom/braid":["warp","weft"]}'
check "T5 row7 planted   (braid's capability requirement left unwired)" "${row7/WIRED/false}" 1 \
  "gen-link.link: aspect 'loom/braid' has unwired required facet(s): selvageReq" \
  "$tmpdir/row7-red.err"

# ── row 8 -- a bare kind-name string passed where a kind VALUE belongs (mirrors gen-select's
# second door, `sel.kind`, exercised elsewhere in this corpus only through gen-scope's own
# kind values) ──
row8='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSelect = gen.lib.substrate.select;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  tree = genMerge.evalModuleTree {
    modules = [
      { options.schema = genSchema.mkSchemaOption {}; }
      { config.schema.thimble = { options.spool = genMerge.mkOption { type = genMerge.types.str; default = "linen"; }; }; }
    ];
  };
  kindValue = tree.config.schema.thimble;
in builtins.toJSON (builtins.attrNames (genSelect.kind ARG))'
check "T5 row8 unplanted (a real kind value, minted through the schema)" "${row8/ARG/kindValue}" 0 "" \
  "$tmpdir/row8-green.err" '["__sel","kind"]'
check "T5 row8 planted   (a bare kind-name string, never a kind value)" "${row8/ARG/\"thimble\"}" 1 \
  "gen-select: sel.kind expects a kind value" \
  "$tmpdir/row8-red.err"

# ── row 9 -- a retired lattice key declared on a cyclic member (mirrors C15's cyclic stratum) ──
row9='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  lib = (builtins.getFlake (toString ./.)).inputs.nixpkgs.lib;
  genMemo = gen.lib.substrate.memo;
  genScope = gen.lib.substrate.scope;
  cyclicAccessor = { dependencies = id: { chintz = [ "tulle" ]; tulle = [ "chintz" "organdy" ]; }.${id} or [ ]; nodeData = id: { inherit id; }; };
  reach = acc: view: id: lib.sort (a: b: a < b) (lib.unique ([ id ] ++ lib.concatLists (map (d: view.${d} or [ ]) (acc.dependencies id))));
  reachLattice = { bottom = [ ]; join = a: b: lib.sort (x: y: x < y) (lib.unique (a ++ b)); maxIter = 8; };
  mkSolved = eqKey: genMemo.runScc genScope.ascend {
    accessor = cyclicAccessor; recompute = reach; store = { };
    scc = [ "chintz" "tulle" ]; higherStrata = { organdy = [ "organdy" ]; };
    lattices = { chintz = if eqKey then reachLattice // { eq = a: b: a == b; } else reachLattice; tulle = reachLattice; };
  };
in builtins.toJSON (mkSolved EQKEY).chintz'
check "T5 row9 unplanted (both lattices declare only bottom/join/maxIter)" "${row9/EQKEY/false}" 0 "" \
  "$tmpdir/row9-green.err" '["chintz","organdy","tulle"]'
check "T5 row9 planted   (chintz's lattice still declares the retired eq key)" "${row9/EQKEY/true}" 1 \
  "gen-memo: cyclic member declares retired lattice key" \
  "$tmpdir/row9-red.err"

# ── row 10 -- C7's planted cycle (mirrors C7's own construction: C2's declared edges,
# contracted, gated by `boundedWellDefinedSchedule`). Plants `damask -> pewter`, closing
# `pewter -> grosgrain -> damask -> pewter`; the refusal must name that SCC. ──
row10='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genGraph = gen.lib.substrate.graph;
  genView = gen.lib.substrate.view;
  nodes = { pewter = { }; damask = { }; grosgrain = { }; faille = { }; };
  baseEdges = [
    { from = "pewter"; to = "grosgrain"; label = "tacks"; }
    { from = "grosgrain"; to = "damask"; label = "tacks"; }
    { from = "pewter"; to = "damask"; label = "gathers"; }
  ];
  plantedEdges = baseEdges ++ (if PLANT then [ { from = "damask"; to = "pewter"; label = "tacks"; } ] else [ ]);
  ref = genGraph.mkNodeRef { isRegistered = id: nodes ? ${id}; };
  contracted = es: genGraph.mkDeclaredEdges (map (e: e // { from = ref e.from; to = ref e.to; }) es);
  gated = genView.boundedWellDefinedSchedule {
    nodes = builtins.attrNames nodes;
    declaredDependencies = contracted plantedEdges;
    equations = { };
    admitsCycle = _: false;
  };
in builtins.toJSON (builtins.filter (scc: builtins.length scc > 1) (gated.condensation).sccs)'
check "T5 row10 unplanted (declared edges stay acyclic)" "${row10/PLANT/false}" 0 "" \
  "$tmpdir/row10-green.err" '[]'
check "T5 row10 planted   (damask -> pewter closes pewter -> grosgrain -> damask -> pewter)" \
  "${row10/PLANT/true}" 1 \
  "gen-view.boundedWellDefinedSchedule: the declared relation has a cyclic component \`admitsCycle\` does not admit: [[\"damask\",\"grosgrain\",\"pewter\"]]" \
  "$tmpdir/row10-red.err"

# ── row 11 -- C7's DOOR (mirrors C7's construction, `declaredDependencies` swapped for a
# hand-assembled attrset carrying the same `index`/`dependencies` fields `mkDeclaredEdges`
# would build, but no `_type` tag). `isDeclaredEdges` is purely nominal, so this is the only
# construct-granular refusal a hand-written stand-in cannot forge (Oracle 1b). The unplanted
# arm is the live control: the value `mkDeclaredEdges` itself mints is accepted. ──
row11='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genGraph = gen.lib.substrate.graph;
  genView = gen.lib.substrate.view;
  nodes = { pewter = { }; damask = { }; grosgrain = { }; faille = { }; };
  baseEdges = [
    { from = "pewter"; to = "grosgrain"; label = "tacks"; }
    { from = "grosgrain"; to = "damask"; label = "tacks"; }
    { from = "pewter"; to = "damask"; label = "gathers"; }
  ];
  ref = genGraph.mkNodeRef { isRegistered = id: nodes ? ${id}; };
  minted = genGraph.mkDeclaredEdges (map (e: e // { from = ref e.from; to = ref e.to; }) baseEdges);
  lookalikeIndex = { pewter = [ "grosgrain" "damask" ]; grosgrain = [ "damask" ]; };
  handAssembled = { index = lookalikeIndex; dependencies = id: lookalikeIndex.${id} or [ ]; };
  gated = genView.boundedWellDefinedSchedule {
    nodes = builtins.attrNames nodes;
    declaredDependencies = if DOOR then handAssembled else minted;
    equations = { };
    admitsCycle = _: false;
  };
in builtins.toJSON (gated.edges "pewter")'
check "T5 row11 unplanted (the value mkDeclaredEdges minted is accepted)" "${row11/DOOR/false}" 0 "" \
  "$tmpdir/row11-green.err" '["grosgrain","damask"]'
check "T5 row11 planted   (a hand-assembled lookalike, no _type tag, is refused by name)" \
  "${row11/DOOR/true}" 1 \
  "gen-view.boundedWellDefinedSchedule: field 'declaredDependencies' must be the relation \`gen-graph.mkDeclaredEdges\` returns; received an attrset that \`mkDeclaredEdges\` did not build" \
  "$tmpdir/row11-red.err"

# ── row 12 -- the aspect includes contribution offered under the reserved label `I` (mirrors
# C16's own construction: graphFacts -> parentGraph -> a caller-labelled edgeGraphs entry) ──
row12='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genScope = gen.lib.substrate.scope;
  genAssemble = gen.lib.framework.assemble;
  genMerge = gen.lib.modules.merge;
  cnf = { };
  schema = genAspects.mkAspectSchema cnf;
  tree = genMerge.evalModuleTree {
    modules = [
      { options.schema = schema.schemaOption; }
      (schema.mkAspectModule { })
      { config.aspects.hemline.placket = { }; config.aspects.hemline.facing = { }; }
    ];
  };
  facts = genAspects.graphFacts cnf tree.config.aspects;
  parentGraph = genScope.overlays (map (id:
    let p = facts.parentOf.${id}; in
    if p == null then genScope.vertex id else genScope.edge id p) facts.nodes);
  aspectGraph = { name = "aspect-graph"; vertices = facts.nodes; inherit parentGraph;
    edgeGraphs = [ { label = LABEL; graph = genScope.edge "hemline/facing" "hemline/placket"; } ]; };
in builtins.toJSON (builtins.attrNames (genAssemble.assemble { contributions = [ aspectGraph ]; }).nodes)'
check "T5 row12 unplanted (label declares)" "${row12/LABEL/\"declares\"}" 0 "" \
  "$tmpdir/row12-green.err" '["hemline","hemline/facing","hemline/placket"]'
check "T5 row12 planted   (label I, the reserved import-relation name)" "${row12/LABEL/\"I\"}" 1 \
  "gen-assemble: a contribution offers the reserved label(s) [\"I\"]" \
  "$tmpdir/row12-red.err"

# ── row 13 -- a KIND option contributed after an evaluation already minted, refused on the WARM
# re-compose (mirrors C17's closure from the other side) ──
#
# ★ IT IS A WARM RE-COMPOSE, NOT A COLD PLANT, AND THAT IS THE WHOLE ROW. Region 1 closes the
# INSTANCE side by construction, so an instance-side option is unexpressible in an identity rather
# than refused -- there is nothing for a by-name row to catch there, and C17 asserts it as a value
# instead. The KIND side has no such construction: within ONE evaluation a kind's option set simply
# is what it is. The move is only nameable where TWO evaluations are in hand, and the substrate
# holds two in exactly one place -- `warmFrom`. So this row builds the prior evaluation AND the
# warm re-compose in one expression, which is what makes a by-name refusal reachable from a single
# `nix eval` at all. A cold plant would exit 0 on BOTH arms and measure nothing.
#
# The two arms are ONE token apart: `internal = true` makes the planted option a declaration the
# identity reflection excludes, so it is still a dirty decl-side contribution -- the id_hash is
# re-merged either way -- and moves nothing. A refusal keyed on decl-side dirtiness alone would
# fire on BOTH arms and destroy reuse; the unplanted arm is what catches that, and its exact
# stdout is the corpus's own unmoved thimble stamp.
#
# ★ THE CROSSING SPELLING MIGRATED (2026-09-15 relocation, §2.6): the kind is read through the
# staged `evalSchema` pass now, same as the corpus's own `gen-modules/corpus.nix`, not off a bare
# `config.schema.thimble`. `evalSchema` has no `warmFrom` of its own to thread -- it runs its OWN
# internal `evalModuleTree`, sealed before the outer tree below ever starts -- so "prior" and
# "warm" each get their OWN `evalSchema` call over the kind's own module list (unplanted / with
# `grommet` planted), and it is the OUTER tree's `mkInstanceRegistry <schema>.thimble` declaration
# that differs between the two, which is what the outer `warmFrom` compares. Driven both arms:
# green still exits 0 with the unmoved stamp; red still carries gen-memo's own by-name refusal.
row13='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  aspectSchema = genAspects.mkAspectSchema (import ./aspect-cnf.nix);
  kindModules = extra: [
    {
      config.schema.thimble.options.aspects = genMerge.mkOption { type = genMerge.types.listOf genMerge.types.str; default = [ ]; };
      config.schema.thimble.options.spool = genMerge.mkOption { type = genMerge.types.str; };
    }
  ] ++ extra;
  mkOuter = schema: [
    { imports = [ (aspectSchema.mkAspectModule { }) ]; }
    { options.schema = genMerge.mkOption { type = genMerge.types.raw; default = schema; }; }
    ({ config, ... }: { options.thimbles = genSchema.mkInstanceRegistry schema.thimble { }; })
    { config.thimbles.pewter = { aspects = [ "stitch" ]; spool = "linen"; }; }
  ];
  priorSchema = genSchema.evalSchema { inherit (aspectSchema) schemaOption; modules = kindModules [ ]; };
  warmSchema = genSchema.evalSchema {
    inherit (aspectSchema) schemaOption;
    modules = kindModules [ { config.schema.thimble.options.grommet = genMerge.mkOption { type = genMerge.types.str; default = "plain"; internal = INTERNAL; }; } ];
  };
  prior = genMerge.evalModuleTree { modules = mkOuter priorSchema; };
  warmBase = mkOuter warmSchema;
  warm = genMerge.evalModuleTree { modules = warmBase; warmFrom = prior; editedModules = warmBase; };
in warm.config.thimbles.pewter.id_hash'
check "T5 row13 unplanted (planted option internal, no identity moves)" "${row13/INTERNAL/true}" 0 "" \
  "$tmpdir/row13-green.err" 'thimble:d3dc9389c41b780239d34cc9e1046d74ed8ead1af294db092f7bd3e79c9cba6a'
check "T5 row13 planted   (planted option is an identity key, pewter moves)" "${row13/INTERNAL/false}" 1 \
  "gen-memo.identitiesHeld: minted identity moved on a warm re-compose at 'thimbles.pewter'" \
  "$tmpdir/row13-red.err"

# ── row 14 -- a node declared in BOTH registries, colliding in the delivery target view
# (mirrors the corpus's `options.haberdashery`, `den-hoag-uedvp`) ──
#
# `gen.nodeRegistryPath` names ONE attribute path because it names a delivery-target VIEW, so a
# consumer with several registries declares their union as its own option. THE COLLISION RULE IS
# THE MODULE SYSTEM'S, not one gen writes, and this row is what pins that: `attrsOf raw` fed by
# `mkMerge` refuses a node declared in both, BY NAME. The rejected `//` is the reason the row
# exists -- it is right-wins, so the same corpus spelled with `//` drops `pewter` from the
# delivery set at exit 0 with zero diagnostics. Nothing in gen can refuse that spelling, so the
# `mkMerge` arm's refusal is the only thing holding the ruled construction in place.
row14='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  reg = genMerge.mkOption { type = genMerge.types.attrsOf genMerge.types.raw; default = { }; };
  mod = { config, ... }: {
    options = { thimbles = reg; bobbins = reg; haberdashery = reg; };
    config = {
      thimbles.pewter = { spool = "linen"; };
      bobbins.BOBBIN = { gauge = "fine"; };
      haberdashery = genMerge.mkMerge [ config.thimbles config.bobbins ];
    };
  };
in builtins.toJSON (builtins.attrNames (gen.lib.compose { modules = [ mod ]; }).values.haberdashery.pewter)'
check "T5 row14 unplanted (bobbins.grosgrain, no node in both registries)" "${row14/BOBBIN/grosgrain}" 0 "" \
  "$tmpdir/row14-green.err" '["spool"]'
check "T5 row14 planted   (bobbins.pewter, the same node in both registries)" "${row14/BOBBIN/pewter}" 1 \
  "gen-merge: the option \`haberdashery.pewter' has conflicting definitions" \
  "$tmpdir/row14-red.err"

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

# ── row 18 -- exportType's republished functor, at the natural door: a redeclared option whose
# second declaration disagrees only on WHICH type governed the merge (mirrors interface.nix's
# importType/exportType retention and gen-schema's mkRefinedType, the motivating consumer) ──
row18='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  refinedInt = genSchema.refined genMerge.types.int [ genSchema.refinements.tcpPort ];
  base = { options.grommet = genMerge.mkOption { type = refinedInt; }; };
  second = { options.grommet = genMerge.mkOption { type = SECOND; }; };
  tree = genMerge.evalModuleTree { modules = [ base second ]; };
in tree.options.grommet.type.functor.name'
check "T5 row18 unplanted (grommet redeclared refined, functor identity holds)" "${row18/SECOND/refinedInt}" 0 "" \
  "$tmpdir/row18-green.err" 'refined<int>'
check "T5 row18 planted   (grommet redeclared bare int, functor identity dropped)" "${row18/SECOND/genMerge.types.int}" 1 \
  "which the first type's own \`functor' does not reconcile" \
  "$tmpdir/row18-red.err"

# ── row 19 -- A9, the discrete/monotone separation's message actionability (mirrors C19,
# den-hoag-0hwn): `checks.monotone-separation` asserts the refusal fires via `tryEval`, but
# `tryEval` exposes only `success`, never the thrown text, so whether the refusal NAMES the tag
# and the accessor -- rather than reading as an opaque abort -- is unreachable from that cell and
# is checked here instead ──
row19='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSelect = gen.lib.substrate.select;
  ctx = genSelect.adapters.registry.mkContext {
    nodes = [ "a" "b" ];
    data = _: { };
    parent = _: null;
    entryFor = _: null;
    inFlight = INFLIGHT;
  };
in builtins.toJSON (genSelect.matches (genSelect.not (genSelect.has (genSelect.attrs { key = "b"; }))) "a" ctx)'
check "T5 row19 unplanted (children not declared in flight, sel.not still answers)" "${row19/INFLIGHT/[ ]}" 0 "" \
  "$tmpdir/row19-green.err" 'true'
check "T5 row19 planted   (children declared in flight, sel.not refuses by name and by accessor)" \
  "${row19/INFLIGHT/[ \"children\" ]}" 1 \
  "sel.not observes the in-flight accessor \`children\` at a NON-MONOTONE position" \
  "$tmpdir/row19-red.err"

# ── rows 20/21 -- den-hoag-i546n's thunk-authorization guards (ADR-0023(c) site 3, ADR-0025 item 1).
# Both plant against `gen.lib.substrate.bind.crossing` and both mint their own identity: ADR-0016
# §2.3.1 forbids `hashIdentity` in production, and gen-bind's own fixtures name the test-only stand-in
# `_testHashIdentity` (`gen-bind/ci/tests/_crossing-fixtures.nix`), so the plant carries one by that
# name rather than reaching for the published surface. `mkOperations` is applied and its `.value`
# merged over the raw vocabulary because the identity function is the operations' formal, not the
# vocabulary's.
row20='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  x0 = gen.lib.substrate.bind.crossing;
  _testHashIdentity = kind: labels: relatumOf:
    builtins.hashString "sha256" (kind + "@" + builtins.concatStringsSep "|" (
      builtins.map (l: l + "=" + relatumOf l) (builtins.sort (a: b: a < b) labels)
    ));
  x = x0 // (x0.mkOperations { hashIdentity = _testHashIdentity; }).value;
  c = x.contractTerm;
  imp = { merge = "one"; contract = c.any; required = true; sealed = false; origin = "fixture"; satisfiedBy = null; };
  supply = { bindings.host = x.binding.plain { value = 1; mark = x.mark.open; }; proposals = { }; origins = { }; };
  proj = (x.registerSupply supply).value.projection;
  f = x.declare { imports.host = imp; exports = { }; } { kind = "body"; };
  l = x.link "igloo" proj supply f.value;
  adapter = {
    bindFormals = vals: body: body // { bound = vals; };
    bindArgEnv = vals: { argEnv = vals; };
    wrapFn = fn: { wrapFnOf = fn; };
    wrapUnit = body: units: { inherit body units; };
    interpret = x.interpret;
    thunkBindings = [ "THUNKNAME" ];
  };
  r = x.close "igloo" proj { members = [ ]; } adapter l.value;
in if x.isRefusal r then throw "gen-bind:${r.refusal.code}:${builtins.concatStringsSep "," (r.refusal.witness.unmatched or [ ])}" else "ok"'
check "T5 row20 unplanted (thunkBindings names host, which crosses)" "${row20/THUNKNAME/host}" 0 "" \
  "$tmpdir/row20-green.err" 'ok'
check "T5 row20 planted   (thunkBindings names nope, which never crosses -- ADR-0023(c) site 3)" \
  "${row20/THUNKNAME/nope}" 1 \
  "gen-bind:thunk-bindings-unmatched:nope" \
  "$tmpdir/row20-red.err"

# Row 21 is the SHAPE guard rather than the membership one, and `null` is its unplanted arm on
# purpose: null is the total absent-authorization state the formal admits, so the green arm proves the
# guard admits "no thunks declared" instead of refusing every adapter that omits the key.
row21='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  x0 = gen.lib.substrate.bind.crossing;
  _testHashIdentity = kind: labels: relatumOf:
    builtins.hashString "sha256" (kind + "@" + builtins.concatStringsSep "|" (
      builtins.map (l: l + "=" + relatumOf l) (builtins.sort (a: b: a < b) labels)
    ));
  x = x0 // (x0.mkOperations { hashIdentity = _testHashIdentity; }).value;
  c = x.contractTerm;
  imp = { merge = "one"; contract = c.any; required = true; sealed = false; origin = "fixture"; satisfiedBy = null; };
  supply = { bindings.host = x.binding.plain { value = 1; mark = x.mark.open; }; proposals = { }; origins = { }; };
  proj = (x.registerSupply supply).value.projection;
  f = x.declare { imports.host = imp; exports = { }; } { kind = "body"; };
  l = x.link "igloo" proj supply f.value;
  adapter = {
    bindFormals = vals: body: body // { bound = vals; };
    bindArgEnv = vals: { argEnv = vals; };
    wrapFn = fn: { wrapFnOf = fn; };
    wrapUnit = body: units: { inherit body units; };
    interpret = x.interpret;
    thunkBindings = THUNKSHAPE;
  };
  r = x.close "igloo" proj { members = [ ]; } adapter l.value;
in if x.isRefusal r then throw "gen-bind:${r.refusal.code}:${r.refusal.witness.reason or "NO-REASON"}" else "ok"'
check "T5 row21 unplanted (thunkBindings is null, the total absent-authorization state)" "${row21/THUNKSHAPE/null}" 0 "" \
  "$tmpdir/row21-green.err" 'ok'
check "T5 row21 planted   (thunkBindings is a string, not null or a list -- ADR-0025 item 1)" \
  "${row21/THUNKSHAPE/\"not-a-list\"}" 1 \
  "gen-bind:adapter-malformed:thunkBindings is null or a list of names, not string" \
  "$tmpdir/row21-red.err"

# ── row 22/23 -- `mintAttachmentId`/`parseParent`, the multi-parent EXTEND (gen-scope
# `den-hoag-4kh.53.13`). NOT a T5/ADR-0025 refusal row -- neither function names a door this
# file's `check` harness exercises by plant/unplant; it is placed here only because this is where
# the repo's "one let-prefixed base, `check`-call-per-arm" idiom and `nix eval --raw` harness
# already live, and because `refusals.sh` is the devshell command CI schedules (this file's own
# header). `shaft1`/`shaft2`/`heddle` are ADR-0035 weaving vocabulary, chosen distinct from
# row17/18's own `selvage`/`bobbin`/`warp`/`thread`/`bolt` family to stay visibly independent of
# that row rather than implying a jointly-verified shared fixture. ──
heddleBase='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  kinds = genScope.mkKinds [
    (genScope.mkKind { name = "shaft"; })
    (genScope.mkKind { name = "heddle"; })
  ];
  built = genScope.buildRoots {
    parentGraph = genScope.overlay
      (genScope.edge (genScope.mintAttachmentId "heddle" [ "shaft1" "shaft2" ] "shaft1") "shaft1")
      (genScope.edge (genScope.mintAttachmentId "heddle" [ "shaft1" "shaft2" ] "shaft2") "shaft2");
    types.shaft1 = "shaft"; types.shaft2 = "shaft";
    types."heddle@shaft1" = "heddle"; types."heddle@shaft2" = "heddle";
    decls.shaft1 = { }; decls.shaft2 = { };
    decls."heddle@shaft1" = { }; decls."heddle@shaft2" = { };
    kinds = kinds;
  };
  nodes = built.nodes;
in '

# row22 -- O10's first three facts: both minted ids present, both `.parent` fields correct, and
# `parseParent` round-trips both directions plus the bare-root null case (spec §2.4/O10).
row22="$heddleBase"'builtins.toJSON {
  bothIdsPresent = builtins.elem "heddle@shaft1" (builtins.attrNames nodes) && builtins.elem "heddle@shaft2" (builtins.attrNames nodes);
  parentField1 = nodes."heddle@shaft1".parent;
  parentField2 = nodes."heddle@shaft2".parent;
  parseRoundTrip1 = genScope.parseParent "heddle@shaft1";
  parseRoundTrip2 = genScope.parseParent "heddle@shaft2";
  bareParseIsNull = genScope.parseParent "shaft1" == null;
}'
check "row22 multi-parent attachment (both ids minted, both parent fields, parseParent round-trips, bare root parses null)" \
  "$row22" 0 "" \
  "$tmpdir/row22.err" \
  '{"bareParseIsNull":true,"bothIdsPresent":true,"parentField1":"shaft1","parentField2":"shaft2","parseRoundTrip1":"shaft1","parseRoundTrip2":"shaft2"}'

# row23 -- the fourth oracle fact, its own arm: a single-element `parents` list leaves `bareId`
# unchanged (the id-stability property, spec §2.2), a third root with exactly one parent.
row23="$heddleBase"'builtins.toJSON (genScope.mintAttachmentId "spindle" [ "shaft1" ] "shaft1")'
check "row23 single-parent id stability (mintAttachmentId returns bareId unchanged when parents has exactly one member)" \
  "$row23" 0 "" \
  "$tmpdir/row23.err" \
  '"spindle"'

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

# ── rows 25/26 -- `attrs` as a nullary container strategy, the two arms that must read the MESSAGE
# (den-hoag-241d7's spec rows 5 and 10; den-hoag-row12-message-cells-wrong-plane-x2stm).
#
# THEY LIVE HERE AND NOT IN `constructChecks`, AND THAT IS THE WHOLE POINT. Both inputs below THREW
# before the container strategy landed, so a cell asserting only the `tryEval` failure bit passes on
# the UNREPAIRED tree -- an oracle that cannot fail for the thing it was written to catch. What
# changed is the MESSAGE, which `tryEval` cannot read (header, above), so the discrimination is only
# available on this plane. Each row's `want_grep` is therefore the POST-component string: at
# gen-merge `08fcdd1e` row 25 refuses with "the option `selvedge' has conflicting definitions" and
# row 26 with "a definition for option `selvedge' is not of the expected type", and neither contains
# the substring its row requires.
#
# The construction mirrors C23's own `selvedge` declaration rather than importing it, as every row
# here does; `_file` is set because naming the offending FILE is half of what each message owes.
row25='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  decl = { options.selvedge = genMerge.mkOption { type = genMerge.types.attrs; }; };
in builtins.toJSON (genMerge.evalModuleTree {
  modules = [
    decl
    { _file = "/corpus/a.nix"; config.selvedge.warp = "flax"; }
    { _file = "/corpus/b.nix"; config.selvedge.SECONDKEY = "tussah"; }
  ];
}).config.selvedge'

check "T5 row25 unplanted (two files, disjoint keys -- the fold unions them)" "${row25/SECONDKEY/weft}" 0 "" \
  "$tmpdir/row25-green.err" '{"warp":"flax","weft":"tussah"}'
check "T5 row25 planted   (two files, the SAME key -- refused naming the key and both files)" \
  "${row25/SECONDKEY/warp}" 1 \
  "has \`attrs' definitions that collide at \`warp' (/corpus/b.nix, /corpus/a.nix)" \
  "$tmpdir/row25-red.err"

# Row 26's third arm is a CONTROL, not an unplanted counterpart, so it is labelled with a distinct
# word and stays outside the pairing population the way row24's `catchable` does: `attrsOf int` over
# the SAME rejected definition is the partition this row exists to keep `attrs` out of, and it aborts
# UNCATCHABLY. That is also why it cannot be a conjunct of any `checks` cell -- it would take the
# corpus evaluation down rather than red one cell.
row26Base='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  decl = { options.selvedge = genMerge.mkOption { type = TYPE; }; };
in builtins.toJSON (genMerge.evalModuleTree {
  modules = [
    decl
    { _file = "/corpus/bad.nix"; config.selvedge = DEFN; }
  ];
}).config.selvedge'
row26attrsetDefn='{ warp = "flax"; }'
row26attrs="${row26Base//TYPE/genMerge.types.attrs}"
row26="${row26attrs/DEFN/$row26attrsetDefn}"
row26planted="${row26attrs/DEFN/\"not-an-attrset\"}"
row26control="${row26Base//TYPE/(genMerge.types.attrsOf genMerge.types.int)}"
row26control="${row26control/DEFN/\"not-an-attrset\"}"

check "T5 row26 unplanted (an attrset definition the fold consumes)" "$row26" 0 "" \
  "$tmpdir/row26-green.err" '{"warp":"flax"}'
check "T5 row26 planted   (a string definition attrs cannot consume -- refused naming the file)" \
  "$row26planted" 1 \
  "has definitions \`attrs' cannot consume (/corpus/bad.nix)" \
  "$tmpdir/row26-red.err"
check "T5 row26 control   (attrsOf int over the SAME definition aborts UNCATCHABLY -- the partition)" \
  "$row26control" 1 \
  'expected a set but found a string' \
  "$tmpdir/row26-control.err"

# ── row 27 -- a definition composed with a graph over ANOTHER ALPHABET (gen-view og383) ──
# The seam M9 left open: `viewRelation` checked the orderMark against the definition's alphabet but
# never the definition's against the GRAPH's, so a composition over `{alpha, beta}` answered
# indistinguishably from the legitimate one over `{tacks, gathers}` -- same value, no refusal.
# ★ The mark is `D.identity`, the DEFINITION's own. Handing `G.identity` makes M9's orderMark guard
# fire instead and the row measures the wrong guard. The unplanted arm asserts a STDOUT VALUE, so a
# library that refused everything cannot pass it.
# ★ The graph's letters render `gathers, tacks` -- `quote` SORTS, so the declaration order below
# does not appear in the message.
row27='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  world = letters: rec {
    labels = genView.edgeLabels { inherit letters; };
    admission = genView.labelWellFormedness { alphabet = labels; expression = "(" + builtins.concatStringsSep "|" letters + ")*"; };
    order = genView.labelOrder { alphabet = labels; layers = map (l: [ l ]) letters; endOfPath = -1; };
    identity = genView.labelOrder { alphabet = labels; layers = [ letters ]; endOfPath = 0; };
  };
  G = world [ "tacks" "gathers" ];
  D = world [ ALPHABET ];
  carrier = genView.carrier {
    labels = G.labels;
    relations = genView.relations { names = [ "declares" ]; };
    relatumLabels = genView.relatumLabels { names = [ "warp" ]; };
    labelWellFormedness = G.admission;
    labelOrder = G.order;
    dataOrder = genView.dataOrder { channel = "settings"; keyOf = _: "settings"; };
  };
  graph = genView.scopeGraph {
    inherit carrier;
    scopes = [ "pewter" "grosgrain" ];
    edges = { tacks = id: if id == "pewter" then [ "grosgrain" ] else [ ]; gathers = _: [ ]; };
    data = [ { scope = "pewter"; relation = "declares"; datum = [ "from-pewter" ]; } ];
  };
in builtins.toJSON (map (c: c.datum) (genView.viewRelation {
  definition = genView.compositions.movement {
    channel = "settings"; relation = "declares"; root = "pewter"; direction = "outbound";
    admission = D.admission; order = D.order;
    wellFormed = _: true; tieSet = genView.tieSets.union; empty = [ ];
    combine = genView.combines.listAppend; dedup = genView.dedups.none;
  };
  inherit graph;
  marks = _: [ ];
  orderMark = D.identity;
}).contributions)'
check "T5 row27 unplanted (definition over the graph's own alphabet)" \
  "${row27/ALPHABET/\"tacks\" \"gathers\"}" 0 "" "$tmpdir/row27-green.err" '[["from-pewter"]]'
check "T5 row27 planted   (definition over an alphabet the graph does not carry)" \
  "${row27/ALPHABET/\"alpha\" \"beta\"}" 1 \
  "gen-view.viewRelation: the definition's alphabet is not the graph's (alpha, beta vs gathers, tacks); one composition has one L" \
  "$tmpdir/row27-red.err"

# ── row 28 -- a kind-declaration key NO reader consumes (gen-schema nn4) ──
# The class the arc names most often: something vanishes and nothing says so. A key on a STRUCTURED
# kind declaration that no reader consumes was discarded unread, and the discard was invisible to
# every instrument gen-schema owns -- a typo'd `spoool` produced a kind byte-identical to one
# declared without it. Owner-ruled 2026-08-19: mkSchemaOption aborts on an unknown kind key, by name.
# ★ THE PLANT IS A TYPO, not a foreign key, which is the whole point of the refusal: the two arms
# differ by one character and answered indistinguishably before the guard existed.
# ★ `options` is what makes the declaration STRUCTURED, and that is what puts it in the guard's
# domain. An unstructured declaration is config shorthand -- gen-merge reads every key of it -- and
# is not refused. The unplanted arm asserts a STDOUT VALUE, so a library that refused everything
# cannot pass it; the planted arm's exit code is what a library refusing nothing cannot pass.
row28='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  strOpt = genMerge.mkOption { type = genMerge.types.str; default = "linen"; };
in builtins.toJSON (builtins.attrNames (genMerge.evalModuleTree {
  modules = [
    { options.schema = genSchema.mkSchemaOption {}; }
    { config.schema.thimble = { options.spool = strOpt; SECONDSPOOL; }; }
  ];
}).config.schema.thimble.options)'
check "T5 row28 unplanted (the second spool DECLARED, the way gen-schema reads it)" \
  "${row28/SECONDSPOOL/options.spoool = strOpt}" 0 "" \
  "$tmpdir/row28-green.err" '["spool","spoool"]'
check "T5 row28 planted   (a typo on a structured kind declaration, read by nothing)" \
  "${row28/SECONDSPOOL/spoool = \"linen\"}" 1 \
  "gen-schema: kind 'thimble': unrecognised declaration key 'spoool'" \
  "$tmpdir/row28-red.err"

# ── row 29 -- a COLLECTION name colliding with gen-schema's own vocabulary (gen-schema 6vgwm) ──
# Row 28's mirror image, and the pair is deliberate: row 28 guards a kind DECLARATION against the
# vocabulary, row 29 guards the VOCABULARY against the constructor argument. Neither door can cover
# for the other -- `surplusDeclarationKeys` has `collectionKeys` as a term of its own ALLOW-list, so
# no collection key can ever be surplus and row 28's guard is blind to every input here.
# ★ THE TWO ARMS DIFFER BY A COLLECTION NAME ON `mkSchemaOption`, one token apart. The kind
# declaration is byte-identical and well-formed on BOTH -- unlike row 28, nothing here is a typo and
# nothing is malformed. What changes is a name in the SCHEMA's configuration.
# ★ WHAT THE PLANTED ARM DID BEFORE THE DOOR, measured in this corpus at gen-schema a89efce: it
# exited 0 and produced `thimble:17fa9b9a...` -- a DIFFERENT node from the unplanted arm's
# `thimble:80177db4...`, silently. `strippedDefs` removes every collection key from every def before
# the module merge, so a collection named `options` deletes the kind's option MODULE while
# `kind.options` still advertises it; the mint's preimage reads the stripped introspection and the
# identity moves. Under ADR-0016 ruling 5 that is a different node, propagating into every binding
# referencing it. No throw, no warning.
# ★ THE UNPLANTED ARM ASSERTS THE id_hash ITSELF, not merely an exit code: it is the corpus's own
# unmoved stamp, so a library that refused everything cannot pass it and a library that moved the
# identity a different way cannot either. The planted arm's exit code and message are what a library
# refusing nothing cannot pass.
row29='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  strOpt = genMerge.mkOption { type = genMerge.types.str; default = "linen"; };
  schema = (genMerge.evalModuleTree {
    modules = [
      { options.schema = genSchema.mkSchemaOption { collections.COLLECTIONNAME = { default = [ ]; }; }; }
      { config.schema.thimble = { options.spool = strOpt; }; }
    ];
  }).config.schema;
in (genMerge.evalModuleTree {
  modules = [
    {
      options.thimbles = genSchema.mkInstanceRegistry schema.thimble { };
      config.thimbles.t1 = { name = "t1"; };
    }
  ];
}).config.thimbles.t1.id_hash'
check "T5 row29 unplanted (an ORDINARY collection name, and the instance's stamp is the assertion)" \
  "${row29/COLLECTIONNAME/spools}" 0 "" \
  "$tmpdir/row29-green.err" 'thimble:80177db4d723f893f012782915c3c7716d5e52ed4fd59113a9caee27552b1ce8'
check "T5 row29 planted   (the same declaration, the collection renamed to a key gen-schema writes)" \
  "${row29/COLLECTIONNAME/options}" 1 \
  "gen-schema: collection 'options' is reserved — cannot be used as a collection key" \
  "$tmpdir/row29-red.err"

# ── row 30 -- two DIFFERENT refinements of one base, merged with one silently dropped (gen-schema
#    oqrvg) ──
# The arc's class again, at the value level and fail-OPEN: a refined type's merge decision was taken
# on `functor.name`, which carries only the BASE, so declaring one option as two different
# refinements of `int` MERGED and kept one refinement. The other was gone with nothing said, and the
# value it forbade was then accepted. ADR-0034 rejects a name-only comparison anywhere it mints OR
# KEYS, and a merge decision keys.
# ★ THE TWO ARMS DIFFER BY ONE REFINEMENT RECORD on the second declaration -- the option, the base
# and the module shape are byte-identical on both. Nothing here is malformed.
# ★ THE UNPLANTED ARM ASSERTS A STDOUT VALUE, the surviving refinement's own message, so a library
# that refused every redeclaration cannot pass it; the planted arm's exit code is what a library
# refusing nothing cannot pass. The stderr substring proves a refusal FIRED, not WHICH one -- the
# relation's template interpolates the type's name and `refined` keeps the BASE's, so this string is
# byte-identical to the shipped bare-versus-refined refusal. Discrimination lives in gen-schema's
# own O2b table, never here.
row30='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  gauge = { check = self: self > 0 && self < 65536; message = "must be a valid gauge (1-65535)"; };
  slack = { check = self: self > 0; message = "must be slack"; };
  bolt = r: genMerge.mkOption { type = genSchema.refined genMerge.types.int [ r ]; };
in builtins.concatStringsSep "," (map (r: r.message) (genMerge.evalModuleTree {
  modules = [
    { options.gauge = bolt gauge; }
    { options.gauge = bolt SECONDREFINEMENT; }
  ];
}).options.gauge.type.__schema.refinements)'
check "T5 row30 unplanted (the SAME refinement declared twice, and the survivor is the assertion)" \
  "${row30/SECONDREFINEMENT/gauge}" 0 "" \
  "$tmpdir/row30-green.err" 'must be a valid gauge (1-65535)'
check "T5 row30 planted   (a SECOND, different refinement of the same base on the same option)" \
  "${row30/SECONDREFINEMENT/slack}" 1 \
  "which the first type's own \`functor' does not reconcile" \
  "$tmpdir/row30-red.err"

# ── row 30's second probe -- an identity DEMANDED of a sealed refined type ──
# The same defect one axis over: `__mint`/`__id` arrived verbatim from the base, so two different
# refinements of one base shared an identity WITH EACH OTHER AND WITH THE BARE BASE, and the demand
# still ANSWERED. ADR-0034 admits migrated or not-yet, and a silently-collapsing identity that
# answers is neither.
# ★ THE UNPLANTED ARM DEMANDS `__id` OF THE BARE BASE, which must still answer. That is what stops
# this row passing because gen-schema refuses everything, and it is the same digest the defect used
# to hand back for the REFINED type.
row30id='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
in SUBJECT.__id'
check "T5 row30id unplanted (the BARE base still mints, and the digest is the assertion)" \
  "${row30id/SUBJECT/genMerge.types.int}" 0 "" \
  "$tmpdir/row30id-green.err" 'type:d56681ac4aa3f64b427f9aceaab601fa2fe1e0db2cce50349be86f3fa0d886b6'
check "T5 row30id planted   (an identity demanded of a refinement over a caller predicate)" \
  "${row30id/SUBJECT/(genSchema.refined genMerge.types.int [ genSchema.refinements.tcpPort ])}" 1 \
  "identity: a lambda in an identity position" \
  "$tmpdir/row30id-red.err"

# ── row 31 -- a surplus key beside an explicit `config` (mirrors C35's `module-reader-syntax`,
#    gen-merge s7826) ──
# gen-merge reads a module's keys the way nixpkgs' `unifyModuleSyntax` does: once a module names
# `config` (or `options`), every key outside the reserved set is surplus, and surplus is refused BY
# NAME with the module's `_file`, where the reader used to drop it unread. The two arms differ by the
# one surplus key; the unplanted arm prints the value, so a reader refusing every module cannot pass.
row31='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
in (genMerge.evalModuleTree {
  modules = [
    { options.spool = genMerge.mkOption { type = genMerge.types.str; default = "none"; }; }
    ({ _file = "/demo/typo.nix"; config.spool = "sateen"; } // { SURPLUS })
  ];
}).config.spool'
check "T5 row31 unplanted (an explicit config and nothing beside it)" "${row31/SURPLUS/}" 0 "" \
  "$tmpdir/row31-green.err" 'sateen'
check "T5 row31 planted   (a surplus key beside an explicit config)" "${row31/SURPLUS/spol = 1;}" 1 \
  "gen-merge: module \`/demo/typo.nix' has an unsupported attribute \`spol'" \
  "$tmpdir/row31-red.err"

# ── row 32 -- a refined option on a kind built through gen-aspects' `mkType` arm (mirrors C36's
#    `bobbin.picks`, gen-schema mx07b) ──
# The arm used to publish `refinements = { }` as a literal, so the registry enforced nothing a kind's
# refined option declared and `picks = 0` was accepted. The arms differ by the one instance value; the
# unplanted arm prints it, so a registry refusing every instance cannot pass.
row32='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  aspectSchema = genAspects.mkAspectSchema (import ./aspect-cnf.nix);
  schema = genSchema.evalSchema {
    inherit (aspectSchema) schemaOption;
    modules = [ { config.schema.bobbin.options.picks = genMerge.mkOption { type = genSchema.refined genMerge.types.int [ genSchema.refinements.positive ]; default = 1; }; } ];
  };
in toString (genMerge.evalModuleTree {
  modules = [
    { imports = [ (aspectSchema.mkAspectModule { }) ]; }
    { options.schema = genMerge.mkOption { type = genMerge.types.raw; default = schema; }; }
    { options.bobbins = genSchema.mkInstanceRegistry schema.bobbin { }; }
    { config.bobbins.grosgrain.picks = PICKS; }
  ];
}).config.bobbins.grosgrain.picks'
check "T5 row32 unplanted (an admissible value on the refined option)" "${row32/PICKS/3}" 0 "" \
  "$tmpdir/row32-green.err" '3'
check "T5 row32 planted   (a value the refinement forbids)" "${row32/PICKS/0}" 1 \
  "gen-schema: refinement failed at bobbin:grosgrain.picks" \
  "$tmpdir/row32-red.err"

# ── row 33 -- a refusal renders the value it refuses TOTALLY (gen-view p79do, ADR-0025 item 1) ──
# `direction` handed a lambda is refused by `viewDefinition`, whose message renders the value. It
# rendered through `toJSON`, which aborts on a function PAST `tryEval`, so the refusal itself became
# an uncatchable abort. The planted arm exits 1 either way, so its substring is what separates the
# named refusal from the abort, and the catchable arm is the one that measures item 1 (row 24's form).
row33='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  definition = genView.compositions.movement {
    channel = "settings"; relation = "declares"; root = "pewter"; direction = DIRECTION;
    admission = genView.labelWellFormedness { alphabet = labels; expression = "tacks*"; };
    order = genView.labelOrder { alphabet = labels; layers = [ [ "tacks" ] ]; endOfPath = -1; };
    wellFormed = _: true; tieSet = genView.tieSets.union; empty = [ ];
    combine = genView.combines.listAppend; dedup = genView.dedups.none;
  };
in BODY'
row33unplanted="${row33/DIRECTION/\"outbound\"}"
row33planted="${row33/DIRECTION/(x: x)}"
check "T5 row33 unplanted (a declared direction)" \
  "${row33unplanted/BODY/definition.direction}" 0 "" "$tmpdir/row33-green.err" 'outbound'
check "T5 row33 planted   (a lambda direction, refused by name)" \
  "${row33planted/BODY/builtins.deepSeq definition \"ADMITTED\"}" 1 \
  "gen-view.viewDefinition: field 'direction' is <a lambda>" \
  "$tmpdir/row33-red.err"
check "T5 row33 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row33planted/BODY/if (builtins.tryEval (builtins.deepSeq definition \"ADMITTED\")).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row33-catch.err" 'CAUGHT'

# ── row 34 -- a refinement over a FOREIGN parametric base is discriminated at its parameter
#    (gen-schema u92up) ──
# gen-schema's `refined` decided its base's half by the base's own `typeMergeRel`, and a raw nixpkgs
# type has none, so it fell back to the functor NAME -- which carries `listOf` and not its element.
# Declaring one option as a refined `listOf str` and a refined `listOf int` MERGED and kept the first
# base: the second declaration's element type was gone with nothing said. The same pair declared
# bare is refused by name. The base's half is now gen-merge's published `mergeTypes`, so a refined
# pair answers what its bare bases answer.
# ★ THE TWO ARMS DIFFER BY ONE ELEMENT TYPE on the second declaration; the container, the refinement
# and the module shape are byte-identical. The unplanted arm asserts the defined VALUE, so a library
# refusing every redeclaration cannot pass it; the planted arm's exit is what a library refusing
# nothing cannot pass. The stderr substring is row 30's template, so it proves a refusal FIRED, not
# which one -- discrimination lives in the ELEM swap and gen-schema's S1 cell. For the same reason
# this row stays out of the cross-row control below: its planted stderr is row 30's, byte for byte.
row34='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  lib = (builtins.getFlake (toString ./.)).inputs.nixpkgs.lib;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  reed = e: genMerge.mkOption { type = genSchema.refined (lib.types.listOf e) [ genSchema.refinements.nonEmpty ]; };
in builtins.concatStringsSep "," (genMerge.evalModuleTree {
  modules = [
    { options.reed = reed lib.types.str; }
    { options.reed = reed ELEM; }
    { config.reed = [ "warp" "weft" ]; }
  ];
}).config.reed'
check "T5 row34 unplanted (one foreign container and element declared twice; the value is the assertion)" \
  "${row34/ELEM/lib.types.str}" 0 "" \
  "$tmpdir/row34-green.err" 'warp,weft'
check "T5 row34 planted   (the same foreign container over a DIFFERENT element on the second declaration)" \
  "${row34/ELEM/lib.types.int}" 1 \
  "which the first type's own \`functor' does not reconcile" \
  "$tmpdir/row34-red.err"

# ── row 35 -- a declaration-only read of a module with a surplus key (mirrors C40's
#    `declaration-read-syntax`, gen-merge 4kw63) ──
# The refusals used to sit in the config reader, so a read of declarations alone answered without
# the typo'd key. The arms differ by the one key's spelling; the unplanted arm prints the names.
row35='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  o = genMerge.mkOption { type = genMerge.types.str; default = "none"; };
in builtins.concatStringsSep "," (builtins.attrNames (genMerge.declaredOptions {
  modules = [ { _file = "/demo/typo.nix"; options.spool = o; KEY.weft = o; } ];
}))'
check "T5 row35 unplanted (both options spelled right)" "${row35/KEY/options}" 0 "" \
  "$tmpdir/row35-green.err" 'spool,weft'
check "T5 row35 planted   (a declaration-only read of a typo key)" "${row35/KEY/option}" 1 \
  "gen-merge: module \`/demo/typo.nix' has an unsupported attribute \`option'" \
  "$tmpdir/row35-red.err"

# ── row 36 -- a foreign type's `check` before gen-merge's fold (mirrors C41's `foreign-type-check`,
#    gen-merge v4h7k) ──
# nixpkgs checks every definition against the option type's `check` before its merge; gen-merge's own
# folds used to skip a foreign type's `check`, so `lib.types.str` accepted `1`. The arms differ by the
# one value; the unplanted arm prints it, so a fold refusing every definition cannot pass.
row36='let
  flake = builtins.getFlake (toString ./.);
  genMerge = flake.inputs.gen.lib.modules.merge;
  lib = flake.inputs.nixpkgs.lib;
in toString (genMerge.evalModuleTree {
  modules = [
    { options.spool = genMerge.mkOption { type = lib.types.str; }; }
    { _file = "/demo/spool.nix"; spool = VALUE; }
  ];
}).config.spool'
check "T5 row36 unplanted (a string for a foreign str)" "${row36/VALUE/\"sateen\"}" 0 "" \
  "$tmpdir/row36-green.err" 'sateen'
check "T5 row36 planted   (an int for a foreign str)" "${row36/VALUE/1}" 1 \
  "gen-merge: a definition for option \`spool' is not of type \`string', in \`/demo/spool.nix'" \
  "$tmpdir/row36-red.err"

# ── row 37 -- a nested tree used as a container element refuses the key it cannot report
#    (mirrors C44's `element-tree-refuses-per-level`, gen-merge 0s6zi) ──
# A `check = false` tree typed as an `attrsOf` element has no undeclared report, and a key its own
# level does not declare used to vanish at exit 0 with `.config` smaller. It is now refused by name,
# naming the key, its file and the element. The arms differ by ONE key in the element; the unplanted
# arm asserts the value, so a library refusing every element cannot pass it.
row37='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genMerge = gen.lib.modules.merge;
  pocketTree = (genMerge.evalModuleTree {
    check = false;
    modules = [ { options.selvedge = genMerge.mkOption { type = genMerge.types.str; }; } ];
  }).type;
in builtins.toJSON (genMerge.evalModuleTree {
  check = false;
  modules = [
    { options.pockets = genMerge.mkOption { type = genMerge.types.attrsOf pocketTree; }; }
    { _file = "row37"; config.pockets.welt = { selvedge = "pinked"; } // PLANT; }
  ];
}).config.pockets'
check "T5 row37 unplanted (a clean element of a lax nested tree)" \
  "${row37/PLANT/{ \}}" 0 "" \
  "$tmpdir/row37-green.err" '{"welt":{"selvedge":"pinked"}}'
check "T5 row37 planted   (the same element with one key its tree does not declare)" \
  "${row37/PLANT/{ fray = \"loose\"; \}}" 1 \
  "is not declared by the nested tree that owns it (defined in row37); the tree at \`pockets.welt' is merged where no undeclared report is carried" \
  "$tmpdir/row37-red.err"

# ── row 38 -- a distance rule returning a non-int is refused by name (gen-view hvucx, ADR-0025
#    item 1; C4b's diamond shape) ──
# `pewter` reaches `grosgrain` in one `tacks` hop and in two, in ONE derivative state, so the
# projection compares the two arrivals' distances. A caller's `distance` rule returning a string
# used to be compared as one: "x" against 1 aborted uncatchably, and two strings ordered
# lexicographically. The arms differ by the rule alone; the unplanted arm is the hop count and
# asserts the one-hop arrival survives, so a library refusing every rule cannot pass it.
row38='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  admission = genView.labelWellFormedness { alphabet = labels; expression = "tacks*"; };
  order = genView.labelOrder { alphabet = labels; layers = [ [ "tacks" ] ]; endOfPath = -1; };
  channel = genView.dataOrder { channel = "selvage"; keyOf = c: c.scope; };
  relation = genView.viewRelation {
    definition = genView.viewDefinition {
      inherit channel admission order;
      relation = "gimp"; root = "pewter"; direction = "outbound"; wellFormed = _: true;
      distance = DISTANCE;
      tieSet = genView.tieSets.union; empty = [ ];
      combine = genView.combines.listAppend; dedup = genView.dedups.none;
    };
    graph = genView.scopeGraph {
      carrier = genView.carrier {
        inherit labels;
        relatumLabels = genView.relatumLabels { names = [ ]; };
        labelWellFormedness = admission; labelOrder = order; dataOrder = channel;
        relations = genView.relations { names = [ "gimp" ]; };
      };
      scopes = [ "grosgrain" "faille" "pewter" ];
      edges.tacks = id: { pewter = [ "faille" "grosgrain" ]; faille = [ "grosgrain" ]; }.${id} or [ ];
      data = [ { scope = "grosgrain"; relation = "gimp"; datum = [ "cambric" ]; } ];
    };
    marks = _: [ ];
    orderMark = genView.labelOrder { alphabet = labels; layers = [ [ "tacks" ] ]; endOfPath = 0; };
  };
in builtins.toJSON (builtins.deepSeq relation.value (map (c: c.distance) relation.contributions))'
check "T5 row38 unplanted (the hop count; the one-hop arrival survives)" \
  "${row38/DISTANCE/s: s.distance + 1}" 0 "" \
  "$tmpdir/row38-green.err" '[1]'
check "T5 row38 planted   (a rule returning a string, refused by name)" \
  "${row38/DISTANCE/s: if builtins.isInt s.distance then \"x\" else 1}" 1 \
  "gen-view.viewRelation: channel 'selvage' declares a distance rule that returned \"x\"" \
  "$tmpdir/row38-red.err"

# ── control: the per-row grep must DISCRIMINATE, not just match anything red. Row 2's refusal
# must not appear in row 1's, and row 1's must not appear in row 2's -- if either did, the check
# function above would pass a mismatched row/message pairing and the by-name half would be
# measuring nothing. Extended to the v1.1 rows: row6's `bobbins` message against row9's
# `retired lattice key` message, the two new rows furthest apart in both library and shape.
# Further extended to rows 10/11: both gate the same construct through the same door prefix
# (`gen-view.boundedWellDefinedSchedule:`), so this is the pair most likely to cross-match by
# accident -- row 10 refuses a cyclic component, row 11 refuses a non-minted attrset, and
# neither message may appear in the other's stderr. Extended again to row 14 against row 5, its
# message-distant sibling: both rows are about the DELIVERY TARGET SET (row 5 the projection's
# missing category source, row 14 a collision in the view it selects over) while their refusals
# come from different libraries and share no token, so a leak either way would mean the by-name
# half is matching the area rather than the message. Extended once more to rows 20/21, which are the
# rows 10/11 case in gen-bind: both refuse the SAME `close` call through the same `gen-bind:` door,
# differing only in which guard fires, so they are the pair most able to cross-match by accident.
# Extended a final time to rows 28/29, which are that case in gen-schema: both are kind-plane
# refusals reached through `mkSchemaOption` on the same `thimble` fixture, both open with
# `gen-schema:`, and both are about a NAME the library does not admit -- row 28 a declaration key no
# reader consumes, row 29 a collection key colliding with the library's own vocabulary. They are the
# pair most able to cross-match by accident, and neither message may appear in the other's stderr.
# Extended to rows 35/36: both are gen-merge refusals of one `spool` module behind the same `gen-merge:`
# prefix, row 35 a key the reader does not admit and row 36 a value the foreign type does not admit.
if grep -qF "unresolved relatum 'pewter'" "$tmpdir/row2-red.err"; then
  echo "FAIL control: row1's message leaked into row2's refusal"
  fail=1
elif grep -qF "not in the frozen set" "$tmpdir/row1-red.err"; then
  echo "FAIL control: row2's message leaked into row1's refusal"
  fail=1
elif grep -qF "not a declared member" "$tmpdir/row9-red.err"; then
  echo "FAIL control: row6's message leaked into row9's refusal"
  fail=1
elif grep -qF "retired lattice key" "$tmpdir/row6-red.err"; then
  echo "FAIL control: row9's message leaked into row6's refusal"
  fail=1
elif grep -qF "received an attrset that" "$tmpdir/row10-red.err"; then
  echo "FAIL control: row11's message leaked into row10's refusal"
  fail=1
elif grep -qF "cyclic component" "$tmpdir/row11-red.err"; then
  echo "FAIL control: row10's message leaked into row11's refusal"
  fail=1
elif grep -qF "no category source" "$tmpdir/row14-red.err"; then
  echo "FAIL control: row5's message leaked into row14's refusal"
  fail=1
elif grep -qF "has conflicting definitions" "$tmpdir/row5-red.err"; then
  echo "FAIL control: row14's message leaked into row5's refusal"
  fail=1
elif grep -qF "thunk-bindings-unmatched" "$tmpdir/row21-red.err"; then
  echo "FAIL control: row20's message leaked into row21's refusal"
  fail=1
elif grep -qF "adapter-malformed" "$tmpdir/row20-red.err"; then
  echo "FAIL control: row21's message leaked into row20's refusal"
  fail=1
elif grep -qF "already a registered node's id" "$tmpdir/row21-red.err"; then
  echo "FAIL control: row24's message leaked into row21's refusal"
  fail=1
elif grep -qF "adapter-malformed" "$tmpdir/row24-red.err"; then
  echo "FAIL control: row21's message leaked into row24's refusal"
  fail=1
elif grep -qF "cannot consume" "$tmpdir/row25-red.err"; then
  echo "FAIL control: row26's message leaked into row25's refusal"
  fail=1
elif grep -qF "definitions that collide at" "$tmpdir/row26-red.err"; then
  echo "FAIL control: row25's message leaked into row26's refusal"
  fail=1
elif grep -qF "is reserved — cannot be used as a collection key" "$tmpdir/row28-red.err"; then
  echo "FAIL control: row29's message leaked into row28's refusal"
  fail=1
elif grep -qF "unrecognised declaration key" "$tmpdir/row29-red.err"; then
  echo "FAIL control: row28's message leaked into row29's refusal"
  fail=1
elif grep -qF "is not of type" "$tmpdir/row35-red.err"; then
  echo "FAIL control: row36's message leaked into row35's refusal"
  fail=1
elif grep -qF "has an unsupported attribute" "$tmpdir/row36-red.err"; then
  echo "FAIL control: row35's message leaked into row36's refusal"
  fail=1
else
  echo "ok   control (row1/row2, row6/row9, row10/row11, row5/row14, row20/row21, row25/row26, row28/row29 and row35/row36 refusals do not cross-match)"
fi

exit $fail
