# shellcheck shell=bash
# ── row 66 -- an origin that is not a list of strings is refused by name, catchably
#    (gen-link bkdkg U4; ADR-0025 item 1) ──
# `renderOrigin` takes an origin (a list of strings; [ ] renders as "self"). A string or a record
# handed there used to abort inside `concatStringsSep`. The unplanted arm is the live control.
# The origin renders as ONE escaped segment (den-hoag-gywcg), so the rendering is injective: the
# two-segment `[ "bolt" "selvage" ]` and the one-segment `[ "bolt/selvage" ]` rendered alike before.
row_origin_that_is_not_a_list_of_strings='let
  genLink = (builtins.getFlake (toString ./.)).inputs.gen.lib.aspects.link;
  rendered = genLink.renderOrigin ORIGIN;
in BODY'
row_origin_that_is_not_a_list_of_stringslist='[ "bolt" "selvage" ]'
row_origin_that_is_not_a_list_of_stringsstring='"bolt"'
row_origin_that_is_not_a_list_of_stringsok="${row_origin_that_is_not_a_list_of_strings/ORIGIN/$row_origin_that_is_not_a_list_of_stringslist}"
row_origin_that_is_not_a_list_of_stringsbad="${row_origin_that_is_not_a_list_of_strings/ORIGIN/$row_origin_that_is_not_a_list_of_stringsstring}"
check "T5 origin-that-is-not-a-list-of-strings unplanted (a list-of-strings origin renders)" \
  "${row_origin_that_is_not_a_list_of_stringsok/BODY/rendered}" 0 "" \
  "$tmpdir/origin-that-is-not-a-list-of-strings-green.err" 'bolt%2Fselvage'
check "T5 origin-that-is-not-a-list-of-strings unplanted (two segments and one slash-bearing segment render apart, each stably)" \
  "let genLink = (builtins.getFlake (toString ./.)).inputs.gen.lib.aspects.link;
     two = genLink.renderOrigin [ \"bolt\" \"selvage\" ];
     one = genLink.renderOrigin [ \"bolt/selvage\" ];
   in (if two == one then \"EQUAL\" else \"DISTINCT\") + \":\" + two + \":\" + one" 0 "" \
  "$tmpdir/origin-that-is-not-a-list-of-strings-apart.err" 'DISTINCT:bolt%2Fselvage:bolt%252Fselvage'
check "T5 origin-that-is-not-a-list-of-strings planted   (a string origin is refused by name)" \
  "${row_origin_that_is_not_a_list_of_stringsbad/BODY/rendered}" 1 \
  "gen-link.renderOrigin: got string, expected an origin (a list of strings)" \
  "$tmpdir/origin-that-is-not-a-list-of-strings-red.err"
check "T5 origin-that-is-not-a-list-of-strings catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_origin_that_is_not_a_list_of_stringsbad/BODY/if (builtins.tryEval rendered).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/origin-that-is-not-a-list-of-strings-catch.err" 'CAUGHT'
