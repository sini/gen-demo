# shellcheck shell=bash
# ── row 93 -- an undeclared vocabulary collision is refused PER NAME, catchably, at gen-merge's
#    `types` (den-hoag-m9r03; ADR-0025 item 1) ──
# gen-merge over nixpkgs' whole `lib.types` (its documented compat mode) shares nine names with its
# strategies undeclared. Each is bound to its own refusal, naming the ONE name demanded, and every
# other name publishes. It used to refuse the whole namespace at all nine names, so the planted
# arm's message (`at name 'anything'.`, singular) does not match the old one (`at names 'anything',
# …`). The unplanted arm reads a non-colliding name's STDOUT VALUE, so a namespace that refused
# everything cannot pass it. Every addressing is bound here, in the prelude.
row93='let
  flake = builtins.getFlake (toString ./.);
  h = flake.inputs.gen.inputs;
  gm = import "${h.gen-merge}/lib" {
    prelude = h.gen-prelude.lib;
    types = flake.inputs.nixpkgs.lib.types;
    memo = h.gen-memo.lib;
    scope = h.gen-scope.lib;
  };
  str = gm.types.str.name;
  anything = gm.types.anything;
  caught = if (builtins.tryEval anything).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 row93 unplanted (a name the vocabulary shares with nothing publishes)" \
  "${row93/BODY/str}" 0 "" "$tmpdir/row93-green.err" 'str'
check "T5 row93 planted   (an undeclared shared name is refused by its own name)" \
  "${row93/BODY/anything}" 1 \
  "linkset: undeclared export collision between 'the supplied \`types\` vocabulary' and 'gen-merge' at name 'anything'." \
  "$tmpdir/row93-red.err"
check "T5 row93 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row93/BODY/caught}" 0 "" "$tmpdir/row93-catch.err" 'CAUGHT'
