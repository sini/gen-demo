# shellcheck shell=bash
# ── row 4 -- reading `.included` on an UNDEFINED atom (mirrors C5's model/resolve). The field
# is FORCED here on purpose: reading the whole record instead exits 0 with the message rendered
# inline on stdout (`«error: ...»`), which is the trap this oracle exists to close.
row4='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genProgram = gen.lib.framework.program;
  mkModel = negSelf: genProgram.model {
    program = genProgram.program {
      frozen = [ "pewter" ];
      declarations = [ { head = "nap:pewter"; neg = if negSelf then [ "nap:pewter" ] else [ ]; relata = [ "pewter" ]; } ];
    };
    interpretation = [ ];
    complete = true;
  };
in builtins.toJSON ((mkModel SELFNEG).resolve "nap:pewter").included'
check "T5 row4 unplanted (nap:pewter an ordinary fact)" "${row4/SELFNEG/false}" 0 "" \
  "$tmpdir/row4-green.err" "true"
check "T5 row4 planted   (nap:pewter self-negates, UNDEFINED)" "${row4/SELFNEG/true}" 1 \
  "gen-program: the membership 'nap:pewter' is UNDEFINED — ADR-0020's third value" \
  "$tmpdir/row4-red.err"
