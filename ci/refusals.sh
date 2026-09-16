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
    selectHosts = v: v.thimbles or { };
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
row13='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genSchema = gen.lib.substrate.schema;
  genMerge = gen.lib.modules.merge;
  aspectSchema = genAspects.mkAspectSchema (import ./aspect-cnf.nix);
  base = [
    { imports = [ (aspectSchema.mkAspectModule { }) ]; }
    { options.schema = aspectSchema.schemaOption; }
    ({ config, ... }: { options.thimbles = genSchema.mkInstanceRegistry config.schema.thimble { }; })
    {
      config.schema.thimble.options.aspects = genMerge.mkOption { type = genMerge.types.listOf genMerge.types.str; default = [ ]; };
      config.schema.thimble.options.spool = genMerge.mkOption { type = genMerge.types.str; };
      config.thimbles.pewter = { aspects = [ "stitch" ]; spool = "linen"; };
    }
  ];
  edit = [
    { config.schema.thimble.options.grommet = genMerge.mkOption { type = genMerge.types.str; default = "plain"; internal = INTERNAL; }; }
  ];
  prior = genMerge.evalModuleTree { modules = base; };
  warm = genMerge.evalModuleTree { modules = base ++ edit; warmFrom = prior; editedModules = edit; };
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
# half is matching the area rather than the message.
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
else
  echo "ok   control (row1/row2, row6/row9, row10/row11 and row5/row14 refusals do not cross-match)"
fi

exit $fail
