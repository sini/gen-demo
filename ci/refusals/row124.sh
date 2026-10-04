# shellcheck shell=bash
# ── row 124 -- a member missing from mkHostedTerminal's adapter carriage is refused by name,
#    catchably (den-hoag-54al9; ADR-0025 item 1) ──
# gen-bind's `mkHostedTerminal(...).adapter` takes one closed carriage: `extent`, `extraModules`,
# `peersOf`, `engine` and `readerId` required, `marksOf`, `passthrough` and `thunkBindings` optional
# (the peer relation is lifted and resolved by the injected `engine`, den-hoag-gayc U2b). Its native
# required formal used to abort on a carriage without a required member, past `tryEval`. It is a closed `prelude.door` now: the missing member is
# refused when the adapter is applied, naming the door, the field and the required set. The
# unplanted arm is C22's carriage shape spelt whole and asserts the peer relation it builds, so a
# door that refused everything cannot pass it. Every arm is bound in the prelude, as row 115's are.
row124='let
  s = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate;
  t = s.bind.crossing.mkHostedTerminal { evaluator = a: a; locateConfig = a: a; class = "notion"; };
  whole = {
    extent.linen = 1;
    extraModules = [ ];
    peersOf = _: [ "linen" ];
    engine = s.scope;
    marksOf = _: [ ];
    readerId = "linen";
  };
  answered = (t.adapter whole).peerRelation.name;
  missing = builtins.toJSON (builtins.attrNames (t.adapter (builtins.removeAttrs whole [ "peersOf" ])));
  caught = if (builtins.tryEval (builtins.seq (t.adapter (builtins.removeAttrs whole [ "peersOf" ])) null)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row124 unplanted (mkHostedTerminal's adapter with its whole carriage builds the peer relation)" \
  "${row124/BODY/answered}" 0 "" "$tmpdir/row124-green.err" 'peers/notion'
check "T5 row124 planted   (a carriage missing peersOf is refused by name at the adapter)" \
  "${row124/BODY/missing}" 1 \
  "gen-bind.crossing.mkHostedTerminal.adapter: required field 'peersOf' is missing (required: 'extent', 'extraModules', 'peersOf', 'engine', 'readerId') (in prelude.checkRequired)" \
  "$tmpdir/row124-red.err"
check "T5 row124 catchable  (the missing member is caught by tryEval at the adapter's application, not an abort)" \
  "${row124/BODY/caught}" 0 "" "$tmpdir/row124-catch.err" 'CAUGHT'
