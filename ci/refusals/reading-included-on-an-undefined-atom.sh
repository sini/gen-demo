# shellcheck shell=bash
# ── row 4 -- reading `.included` on an UNDEFINED atom (mirrors C5's model/resolve). The field
# is FORCED here on purpose: reading the whole record instead exits 0 with the message rendered
# inline on stdout (`«error: ...»`), which is the trap this oracle exists to close.
row_reading_included_on_an_undefined_atom='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genProgram = gen.lib.framework.program;
  mkModel = negSelf: genProgram.model {
    prior = null;
    program = genProgram.program [ "pewter" ] [ { head = "nap:pewter"; neg = if negSelf then [ "nap:pewter" ] else [ ]; relata = [ "pewter" ]; } ];
    interpretation = [ ];
    complete = true;
  };
in builtins.toJSON ((mkModel SELFNEG).resolve "nap:pewter").included'
check "T5 reading-included-on-an-undefined-atom unplanted (nap:pewter an ordinary fact)" "${row_reading_included_on_an_undefined_atom/SELFNEG/false}" 0 "" \
  "$tmpdir/reading-included-on-an-undefined-atom-green.err" "true"
check "T5 reading-included-on-an-undefined-atom planted   (nap:pewter self-negates, UNDEFINED)" "${row_reading_included_on_an_undefined_atom/SELFNEG/true}" 1 \
  "gen-program: the membership 'nap:pewter' is UNDEFINED — the well-founded model's third truth value" \
  "$tmpdir/reading-included-on-an-undefined-atom-red.err"
