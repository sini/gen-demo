# shellcheck shell=bash
# ── row 66 -- an origin that is not a list of strings is refused by name, catchably
#    (gen-link bkdkg U4; ADR-0025 item 1) ──
# `renderOrigin` takes an origin (a list of strings; [ ] renders as "self"). A string or a record
# handed there used to abort inside `concatStringsSep`. The unplanted arm is the live control.
# The origin renders as ONE escaped segment (den-hoag-gywcg), so the rendering is injective: the
# two-segment `[ "bolt" "selvage" ]` and the one-segment `[ "bolt/selvage" ]` rendered alike before.
row66='let
  genLink = (builtins.getFlake (toString ./.)).inputs.gen.lib.aspects.link;
  rendered = genLink.renderOrigin ORIGIN;
in BODY'
row66list='[ "bolt" "selvage" ]'
row66string='"bolt"'
row66ok="${row66/ORIGIN/$row66list}"
row66bad="${row66/ORIGIN/$row66string}"
check "T5 row66 unplanted (a list-of-strings origin renders)" \
  "${row66ok/BODY/rendered}" 0 "" \
  "$tmpdir/row66-green.err" 'bolt%2Fselvage'
check "T5 row66 unplanted (two segments and one slash-bearing segment render apart, each stably)" \
  "let genLink = (builtins.getFlake (toString ./.)).inputs.gen.lib.aspects.link;
     two = genLink.renderOrigin [ \"bolt\" \"selvage\" ];
     one = genLink.renderOrigin [ \"bolt/selvage\" ];
   in (if two == one then \"EQUAL\" else \"DISTINCT\") + \":\" + two + \":\" + one" 0 "" \
  "$tmpdir/row66-apart.err" 'DISTINCT:bolt%2Fselvage:bolt%252Fselvage'
check "T5 row66 planted   (a string origin is refused by name)" \
  "${row66bad/BODY/rendered}" 1 \
  "gen-link.renderOrigin: got string, expected an origin (a list of strings)" \
  "$tmpdir/row66-red.err"
check "T5 row66 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row66bad/BODY/if (builtins.tryEval rendered).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row66-catch.err" 'CAUGHT'
