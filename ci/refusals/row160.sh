# shellcheck shell=bash
# (PROVISIONAL row number, above every row on any open branch at the time of writing; the relock assigns the final one.)
# ── row 160 -- a context read at a STATIC aspect's include position is refused BY NAME, catchably
#    (den-hoag-ekq31; ADR-0025 item 1; first-order rules design: `always ⇒ readCtx` is `unsafe-read`) ──
# The aspect type stamps a key on a term written at `includes`, so the include-site classifier took it
# for inline CONTENT with no sites and the read vanished at rc 0. The unplanted arm names an aspect at the
# same position and asserts a STDOUT VALUE, the local site, so a classifier that refused every include
# cannot pass it. The element is bound in the prelude: a `}` inside a `${row160/EXTRA/...}` replacement
# would end the expansion early.
row160='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  t = (gen.lib.substrate.algebra.term gen.lib.substrate.identity.hashIdentity).term;
  cnf = { keySemantics.nixos.category = "class"; };
  byName = "gore";
  byRead = t.readCtx "host" [ ];
  byLit = t.lit "gore";
  aspects = (merge.evalModuleTree {
    modules = [
      { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
      { aspects.gore.nixos.marks = [ "gore" ]; aspects.panel.includes = [ EXTRA ]; }
    ];
  }).config.aspects;
  sites = (genAspects.graphFacts cnf aspects).includeSitesOf.panel;
  shown = builtins.toJSON sites;
  caught = if (builtins.tryEval (builtins.deepSeq sites null)).success then "ADMITTED" else "CAUGHT";
in BODY'
row160unplanted="${row160/EXTRA/byName}"
row160planted="${row160/EXTRA/byRead}"
row160lit="${row160/EXTRA/byLit}"
check "T5 row160 unplanted (an aspect named at a static include position is a local site)" \
  "${row160unplanted/BODY/shown}" 0 "" "$tmpdir/row160-green.err" \
  '[{"kind":"local","target":"gore"}]'
check "T5 row160 planted   (a context read at a static include position is refused by name: unsafe-read)" \
  "${row160planted/BODY/shown}" 1 \
  "unsafe-read: the include position holds a ReadCtx term" \
  "$tmpdir/row160-planted.err"
check "T5 row160 planted   (a term that reads nothing is refused under the second code: static-term)" \
  "${row160lit/BODY/shown}" 1 \
  "static-term: the include position holds a Lit term; only static content is admitted at a static include position" \
  "$tmpdir/row160-lit.err"
check "T5 row160 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row160planted/BODY/caught}" 0 "" "$tmpdir/row160-catch.err" 'CAUGHT'
