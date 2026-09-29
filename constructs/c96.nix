# ── C96 — a growing relation withholds an answer resting on negation (den-hoag-ea3j4, 0010) ──
#
# Two passes over one frozen set. Pass 1 declares `furl:damask` and `shirr:damask:faille :-
# furl:damask, not smocked:damask`, at `complete = false`; pass 2 resubmits both and adds
# `smocked:damask`, at `complete = true`. Pass 1 DERIVES the shirr atom, but its support rests on
# `not smocked:damask`, which a later pass may derive, so the growing relation withholds it by name
# rather than serving an `included = true` the final graph falsifies. The fact `furl:damask` is
# negation-free and is served at pass 1: the withholding is per atom, never per pass.
#
# Pass 2 is handed pass 1's result record as `prior`, so its carry is DERIVED (pass 1's `undefined`
# atoms only), and a pass 2 that resubmits only its own new declaration is refused by name.
{ genProgram }:
let
  shirrHead = "shirr:damask:faille";
  furl = {
    head = "furl:damask";
    relata = [ "damask" ];
  };
  shirr = {
    head = shirrHead;
    pos = [ "furl:damask" ];
    neg = [ "smocked:damask" ];
    relata = [
      "damask"
      "faille"
    ];
  };
  smocked = {
    head = "smocked:damask";
    relata = [ "damask" ];
  };
  passOver =
    declarations: prior: complete:
    genProgram.model {
      program = genProgram.program {
        frozen = [
          "damask"
          "faille"
        ]; # earlier passes settled these
        inherit declarations;
      };
      interpretation = [ ];
      inherit prior complete;
    };
  shirrPass1 = passOver [ furl shirr ] null false;
  # Pass 2 takes pass 1's RECORD: the carry is derived from it, and every pass-1 declaration must
  # be resubmitted.
  shirrFinal = passOver [ furl shirr smocked ] shirrPass1 true;
  # The same pass submitting only what it adds is refused by name: it drops pass 1's declarations.
  shirrDeltaOnly = passOver [ smocked ] shirrPass1 true;
in
{
  inherit
    shirrHead
    shirrPass1
    shirrFinal
    shirrDeltaOnly
    ;
}
