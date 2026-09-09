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

    # $1 label, $2 nix expr, $3 wanted exit code, $4 required stderr substring (empty = none checked),
    # $5 file to capture this row's stderr into (for the cross-row control at the end).
    check() {
      local label="$1" expr="$2" want_exit="$3" want_grep="$4" errfile="$5"
      nix eval --impure --raw --expr "$expr" >/dev/null 2>"$errfile"
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
    check "T5 row1 unplanted (basting minted strictly later)" "${row1/PASS/1}" 0 "" /tmp/gen-demo-t5-row1-green.err
    check "T5 row1 planted   (basting minted in the same pass)" "${row1/PASS/0}" 1 \
      "gen-scope.mintStrata: unresolved relatum 'pewter' (label 'warp', minting kind 'basting', pass 0)" \
      /tmp/gen-demo-t5-row1-red.err

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
    in builtins.seq (mkProg FROZEN) "ok"'
    check "T5 row2 unplanted (faille frozen)" "${row2/FROZEN/[ \"pewter\" \"damask\" \"grosgrain\" \"faille\" ]}" 0 "" /tmp/gen-demo-t5-row2-green.err
    check "T5 row2 planted   (faille not frozen)" "${row2/FROZEN/[ \"pewter\" \"damask\" \"grosgrain\" ]}" 1 \
      "gen-program: 'faille' is not in the frozen set of relata that strictly earlier passes settled (ADR-0016 ruling 7)" \
      /tmp/gen-demo-t5-row2-red.err

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
    in builtins.seq (mkCarrier "LABEL") "ok"'
    check "T5 row3 unplanted (relatum labelled warp)" "${row3/LABEL/warp}" 0 "" /tmp/gen-demo-t5-row3-green.err
    check "T5 row3 planted   (relatum relabelled tacks, collides with L)" "${row3/LABEL/tacks}" 1 \
      "gen-view.carrier: 'tacks' is both a letter of L and a relatum label in Λ" \
      /tmp/gen-demo-t5-row3-red.err

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
    check "T5 row4 unplanted (nap:pewter an ordinary fact)" "${row4/SELFNEG/false}" 0 "" /tmp/gen-demo-t5-row4-green.err
    check "T5 row4 planted   (nap:pewter self-negates, UNDEFINED)" "${row4/SELFNEG/true}" 1 \
      "gen-program: the membership 'nap:pewter' is UNDEFINED — ADR-0020's third value" \
      /tmp/gen-demo-t5-row4-red.err

    # ── row 5 -- `gen.aspectCnf` absent (mirrors C6's extra `project` call) ──
    row5='let
      gen = (builtins.getFlake (toString ./.)).inputs.gen;
      genDelivery = gen.lib.framework.delivery;
      vals = { hosts.pewter = { aspects = [ "stitch" ]; }; aspects.stitch.nixos = { foo = "bar"; }; };
      mkProj = withCnf: genDelivery.project {
        values = vals;
        cnf = if withCnf then (import ./aspect-cnf.nix) else null;
        selectHosts = v: v.hosts or { };
      };
    in builtins.seq (mkProj WITHCNF) "ok"'
    check "T5 row5 unplanted (cnf present)" "${row5/WITHCNF/true}" 0 "" /tmp/gen-demo-t5-row5-green.err
    check "T5 row5 planted   (cnf absent)" "${row5/WITHCNF/false}" 1 \
      "gen-delivery: project: no category source — \`cnf\` is required and has no default." \
      /tmp/gen-demo-t5-row5-red.err

    # ── control: the per-row grep must DISCRIMINATE, not just match anything red. Row 2's refusal
    # must not appear in row 1's, and row 1's must not appear in row 2's -- if either did, the check
    # function above would pass a mismatched row/message pairing and the by-name half would be
    # measuring nothing.
    if grep -qF "unresolved relatum 'pewter'" /tmp/gen-demo-t5-row2-red.err; then
      echo "FAIL control: row1's message leaked into row2's refusal"
      fail=1
    elif grep -qF "not in the frozen set" /tmp/gen-demo-t5-row1-red.err; then
      echo "FAIL control: row2's message leaked into row1's refusal"
      fail=1
    else
      echo "ok   control (row1/row2 refusals do not cross-match)"
    fi

    exit $fail
