# shellcheck shell=bash
# ── row 124 -- a member missing from mkHostedTerminal's adapter carriage is refused by name,
#    catchably (den-hoag-54al9; ADR-0025 item 1) ──
# gen-bind's `mkHostedTerminal(...).adapter` takes one closed carriage: `extent`, `extraModules`,
# `peerGraph`, `marksOf` and `readerId` required, `passthrough` and `thunkBindings` optional. Its
# native required formal used to abort on a carriage without `marksOf` (`called without required
# argument 'marksOf'`), past `tryEval`. It is a closed `prelude.door` now: the missing member is
# refused when the adapter is applied, naming the door, the field and the required set. The
# unplanted arm is C22's carriage shape spelt whole and asserts the peer relation it builds, so a
# door that refused everything cannot pass it. Every arm is bound in the prelude, as row 115's are.
row124='let
  s = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate;
  t = s.bind.crossing.mkHostedTerminal { evaluator = a: a; locateConfig = a: a; class = "notion"; };
  whole = {
    extent.linen = 1;
    extraModules = [ ];
    peerGraph = s.graph.labeledFrom { peer = _: [ "linen" ]; } [ "linen" ];
    marksOf = _: [ ];
    readerId = "linen";
  };
  answered = (t.adapter whole).peerRelation.name;
  missing = builtins.toJSON (builtins.attrNames (t.adapter (builtins.removeAttrs whole [ "marksOf" ])));
  caught = if (builtins.tryEval (builtins.seq (t.adapter (builtins.removeAttrs whole [ "marksOf" ])) null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row124 unplanted (mkHostedTerminal's adapter with its whole carriage builds the peer relation)" \
  "${row124/BODY/answered}" 0 "" "$tmpdir/row124-green.err" 'peers/notion'
check "T5 row124 planted   (a carriage missing marksOf is refused by name at the adapter)" \
  "${row124/BODY/missing}" 1 \
  "gen-bind.crossing.mkHostedTerminal.adapter: required field 'marksOf' is missing (required: 'extent', 'extraModules', 'peerGraph', 'marksOf', 'readerId') (in prelude.checkRequired)" \
  "$tmpdir/row124-red.err"
check "T5 row124 catchable  (the missing member is caught by tryEval at the adapter's application, not an abort)" \
  "${row124/BODY/caught}" 0 "" "$tmpdir/row124-catch.err" 'CAUGHT'
