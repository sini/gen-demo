# shellcheck shell=bash
# ── row 128 -- a member whose `includes` is not a list is refused BY NAME, catchably, with its aspect
#    and the key (den-hoag-rc4mb; ADR-0025 item 1) ──
# A directly-supplied registry bypasses the aspect type, so `graphFacts` reads a hand-built member's
# `includes` as given; a string there aborted in a builtin past tryEval, in an error class the
# evaluators did not agree on. The unplanted arm leaves `includes` out (the type's declared default)
# and asserts a STDOUT VALUE, so a library refusing every member cannot pass it. The members are bound
# in the prelude: a `}` inside a `${row128/EXTRA/...}` replacement would end the expansion early.
row128='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  bare = { };
  notAList = { includes = "notalist"; };
  member = { name = "gore"; } // EXTRA;
  sites = (genAspects.graphFacts { } { gore = member; }).includeSitesOf.gore;
  shown = builtins.toJSON sites;
  caught = if (builtins.tryEval (builtins.deepSeq sites null)).success then "ADMITTED" else "CAUGHT";
in BODY'
row128unplanted="${row128/EXTRA/bare}"
row128planted="${row128/EXTRA/notAList}"
check "T5 row128 unplanted (a member with no includes reads the declared default)" \
  "${row128unplanted/BODY/shown}" 0 "" "$tmpdir/row128-green.err" '[]'
check "T5 row128 planted   (a non-list includes is refused by name, with its aspect)" \
  "${row128planted/BODY/shown}" 1 \
  "gen-aspects.includes (aspect 'gore'): 'includes' must be a list, not a string" \
  "$tmpdir/row128-planted.err"
check "T5 row128 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row128planted/BODY/caught}" 0 "" "$tmpdir/row128-catch.err" 'CAUGHT'
