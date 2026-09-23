# shellcheck shell=bash
# ── row 2 -- a policy relatum not in `frozen` (mirrors C5's program) ──
row2='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genProgram = gen.lib.framework.program;
  mkProg = frozenList: genProgram.program {
    frozen = frozenList;
    declarations = [
      { head = "nap:pewter"; relata = [ "pewter" ]; }
      { head = "piping:grosgrain:faille"; pos = [ "nap:pewter" ]; neg = [ "scotched:pewter" ]; relata = [ "grosgrain" "faille" ]; }
    ];
  };
in builtins.toJSON (mkProg FROZEN).atoms'
check "T5 row2 unplanted (faille frozen)" "${row2/FROZEN/[ \"pewter\" \"damask\" \"grosgrain\" \"faille\" ]}" 0 "" \
  "$tmpdir/row2-green.err" '["nap:pewter","piping:grosgrain:faille","scotched:pewter"]'
check "T5 row2 planted   (faille not frozen)" "${row2/FROZEN/[ \"pewter\" \"damask\" \"grosgrain\" ]}" 1 \
  "gen-program: 'faille' is not in the frozen set of relata that strictly earlier passes settled (ADR-0016 ruling 7)" \
  "$tmpdir/row2-red.err"
