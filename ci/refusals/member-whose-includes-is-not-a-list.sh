# shellcheck shell=bash
# ── row 128 -- a member whose `includes` is not a list is refused BY NAME, catchably, with its aspect
#    and the key (den-hoag-rc4mb; ADR-0025 item 1) ──
# A directly-supplied registry bypasses the aspect type, so `graphFacts` reads a hand-built member's
# `includes` as given; a string there aborted in a builtin past tryEval, in an error class the
# evaluators did not agree on. The unplanted arm leaves `includes` out (the type's declared default)
# and asserts a STDOUT VALUE, so a library refusing every member cannot pass it. The members are bound
# in the prelude: a `}` inside a `${row128/EXTRA/...}` replacement would end the expansion early.
row_member_whose_includes_is_not_a_list='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  bare = { };
  notAList = { includes = "notalist"; };
  member = { name = "gore"; } // EXTRA;
  sites = (genAspects.graphFacts { } { gore = member; }).includeSitesOf.gore;
  shown = builtins.toJSON sites;
  caught = if (builtins.tryEval (builtins.deepSeq sites null)).success then "ADMITTED" else "CAUGHT";
in BODY'
row_member_whose_includes_is_not_a_listunplanted="${row_member_whose_includes_is_not_a_list/EXTRA/bare}"
row_member_whose_includes_is_not_a_listplanted="${row_member_whose_includes_is_not_a_list/EXTRA/notAList}"
check "T5 member-whose-includes-is-not-a-list unplanted (a member with no includes reads the declared default)" \
  "${row_member_whose_includes_is_not_a_listunplanted/BODY/shown}" 0 "" "$tmpdir/member-whose-includes-is-not-a-list-green.err" '[]'
check "T5 member-whose-includes-is-not-a-list planted   (a non-list includes is refused by name, with its aspect)" \
  "${row_member_whose_includes_is_not_a_listplanted/BODY/shown}" 1 \
  "gen-aspects.includes (aspect 'gore'): 'includes' must be a list, not a string" \
  "$tmpdir/member-whose-includes-is-not-a-list-planted.err"
check "T5 member-whose-includes-is-not-a-list catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_member_whose_includes_is_not_a_listplanted/BODY/caught}" 0 "" "$tmpdir/member-whose-includes-is-not-a-list-catch.err" 'CAUGHT'
