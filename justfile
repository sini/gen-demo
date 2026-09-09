# gen-demo — the acceptance corpus for gen.
#
# Read every exit status UNPIPED. Under zsh a pipeline's per-stage status is `$pipestatus`
# (lowercase), and a piped read of `$?` reports the last stage instead of nix.

default: check

# ARM 1 — the committed flake.lock, the last-green pin.
check:
    nix flake check

# ARM 2 — the same corpus against the hub's current main, so a hub landing that breaks the corpus
# reads red immediately instead of waiting for a relock.
check-hub-main:
    nix flake check --refresh --override-input gen github:sini/gen

# NOT a check. The full build of the one target, verified once at delivery and on demand.
build-target:
    nix build .#nixosConfigurations.pewter.config.system.build.toplevel

# The pin advances deliberately: relock, then both arms must be green before it lands.
relock:
    nix flake update gen

# T5 (ADR-0025) -- one plant per enforcer, refused BY NAME. `builtins.tryEval` cannot read a
# refusal's message (that is a property of the builtin, not of Nix -- `den-hoag-9mo`), so the
# by-name half runs here, out of band, rather than as a `checks` cell. Each plant mirrors the
# construction its own C-numbered construct in flake.nix uses -- never imports it, since a
# standalone plant must not perturb the corpus's own declarations -- and every probe below is run
# BOTH planted (must refuse, by name) and unplanted (must not refuse), because a construction that
# refused unconditionally would pass the planted arm for the wrong reason. Every exit is read
# UNPIPED: a piped `$?` reports the last stage of the pipe, not nix's.
refusals:
    #!/usr/bin/env bash
    set -u
    fail=0

    # A fresh dir per run -- two concurrent `just refusals` no longer collide on a fixed /tmp name.
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
      vals = { hosts.pewter = { aspects = [ "stitch" ]; }; hosts.damask = { aspects = [ ]; }; aspects.stitch.nixos = { foo = "bar"; }; };
      mkProj = withCnf: genDelivery.project {
        values = vals;
        cnf = if withCnf then (import ./aspect-cnf.nix) else null;
        selectHosts = v: v.hosts or { };
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

    # ── control: the per-row grep must DISCRIMINATE, not just match anything red. Row 2's refusal
    # must not appear in row 1's, and row 1's must not appear in row 2's -- if either did, the check
    # function above would pass a mismatched row/message pairing and the by-name half would be
    # measuring nothing. Extended to the v1.1 rows: row6's `bobbins` message against row9's
    # `retired lattice key` message, the two new rows furthest apart in both library and shape.
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
    else
      echo "ok   control (row1/row2 and row6/row9 refusals do not cross-match)"
    fi

    exit $fail
