# shellcheck shell=bash
# ── row 66 -- an origin that is not a list of strings is refused by name, catchably
#    (gen-link bkdkg U4; ADR-0025 item 1) ──
# `renderOrigin` takes an origin (a list of strings; [ ] renders as "self"). A string or a record
# handed there used to abort inside `concatStringsSep`. The unplanted arm is the live control.
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
  "$tmpdir/row66-green.err" 'bolt/selvage'
check "T5 row66 planted   (a string origin is refused by name)" \
  "${row66bad/BODY/rendered}" 1 \
  "gen-link.renderOrigin: got string, expected an origin (a list of strings)" \
  "$tmpdir/row66-red.err"
check "T5 row66 catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row66bad/BODY/if (builtins.tryEval rendered).success then \"ADMITTED\" else \"CAUGHT\"}" 0 "" \
  "$tmpdir/row66-catch.err" 'CAUGHT'
