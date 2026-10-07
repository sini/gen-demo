# shellcheck shell=bash
# ── guard-body-data-shaped-like-a-refusal-or-a-term -- a guard body record that spells `__bodyTerm` by
#    hand is refused BY NAME, `term-not-constructed`, naming its former (den-hoag-s1ua7 / den-hoag-3nr2o) ──
# A term is a record a former built, and it carries the former's mint. The hand-spelled record fired as
# the term it imitates, or aborted past `tryEval` when its identity was demanded. The unplanted arm
# fires a body built by the formers and asserts its STDOUT VALUE, so a guard that refused every body
# cannot pass it.
row_guard_body_data_shaped_like_a_refusal_or_a_term='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  aspects = gen.lib.aspects.aspects;
  t = (gen.lib.substrate.algebra.term gen.lib.substrate.identity.hashIdentity).term;
  merge = gen.lib.modules.merge;
  place = defs: (merge.evalModuleTree { } [
      { options.aspects = (aspects.mkAspectSchema { keySemantics.nixos.category = "class"; }).mkAspectOption { }; }
      { config.aspects = defs; }
    ]).config.aspects;
  fired = b: (aspects.mkGuardVocab { }).applyGuard { } (place { d = aspects.guard aspects.pred.always b; }).d;
  green = (fired { x = t.lit "selvage"; }).x;
  red = builtins.deepSeq (fired { x = { __bodyTerm = "Lit"; value = 1; }; }) "fired";
in BODY'
check "T5 guard-body-data-shaped-like-a-refusal-or-a-term unplanted (a body built by the formers fires, its value read)" \
  "${row_guard_body_data_shaped_like_a_refusal_or_a_term/BODY/green}" 0 "" \
  "$tmpdir/guard-body-data-shaped-like-a-refusal-or-a-term-green.err" 'selvage'
check "T5 guard-body-data-shaped-like-a-refusal-or-a-term planted   (a hand-spelled __bodyTerm record is refused by name)" \
  "${row_guard_body_data_shaped_like_a_refusal_or_a_term/BODY/red}" 1 \
  "gen-aspects.guard: aspect \`d\`: term-not-constructed: {\"former\":\"Lit\"," \
  "$tmpdir/guard-body-data-shaped-like-a-refusal-or-a-term-red.err"
