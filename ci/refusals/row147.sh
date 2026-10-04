# shellcheck shell=bash
# ── row 147 -- a context read at a STATIC aspect's include position is refused BY NAME, catchably
#    (den-hoag-ekq31; ADR-0025 item 1; first-order rules design: `always ⇒ readCtx` is `unsafe-read`) ──
# The aspect type stamps a key on a term written at `includes`, so the include-site classifier took it
# for inline CONTENT with no sites and the read vanished at rc 0. The unplanted arm names an aspect at the
# same position and asserts a STDOUT VALUE, the local site, so a classifier that refused every include
# cannot pass it. The element is bound in the prelude: a `}` inside a `${row147/EXTRA/...}` replacement
# would end the expansion early.
row147='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  merge = gen.lib.modules.merge;
  t = (gen.lib.substrate.algebra.term gen.lib.substrate.identity.hashIdentity).term;
  cnf = { keySemantics.nixos.category = "class"; };
  byName = "gore";
  byRead = t.readCtx "host" [ ];
  byLit = t.lit "gore";
  aspects = (merge.evalModuleTree { } [
      { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
      { aspects.gore.nixos.marks = [ "gore" ]; aspects.panel.includes = [ EXTRA ]; }
    ]).config.aspects;
  sites = (genAspects.graphFacts cnf aspects).includeSitesOf.panel;
  shown = builtins.toJSON sites;
  caught = if (builtins.tryEval (builtins.deepSeq sites null)).success then "ADMITTED" else "CAUGHT";
in BODY'
row147unplanted="${row147/EXTRA/byName}"
row147planted="${row147/EXTRA/byRead}"
row147lit="${row147/EXTRA/byLit}"
check "T5 row147 unplanted (an aspect named at a static include position is a local site)" \
  "${row147unplanted/BODY/shown}" 0 "" "$tmpdir/row147-green.err" \
  '[{"kind":"local","target":"gore"}]'
check "T5 row147 planted   (a context read at a static include position is refused by name: unsafe-read)" \
  "${row147planted/BODY/shown}" 1 \
  "unsafe-read: the include position holds a ReadCtx term" \
  "$tmpdir/row147-planted.err"
check "T5 row147 planted   (a term that reads nothing is refused under the second code: static-term)" \
  "${row147lit/BODY/shown}" 1 \
  "static-term: the include position holds a Lit term; only static content is admitted at a static include position" \
  "$tmpdir/row147-lit.err"
check "T5 row147 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row147planted/BODY/caught}" 0 "" "$tmpdir/row147-catch.err" 'CAUGHT'
