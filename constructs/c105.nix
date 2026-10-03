# ── C105 — a within-pass conditional edge is a rule over a FIXED Herbrand base (den-hoag-fuci, 0010 §4(b)) ──
#
# Every conditional edge below has a known head; only its existence is conditional, so the pass's
# atoms are fixed before it is solved and the well-founded model decides it outright (ADR-0020). The
# guard of each edge is DATA — its `pos`/`neg` literals — so its read set is its body (ADR-0008).
#
# `settled` holds three shapes that are locally stratified and total:
#   · a guard negating a present aspect (the template shape): `yoke` rests on `not gusset-held`;
#   · an exclude settled by an unconditional excluder: `bias` unpicks `hem`, so `placket` is out;
#   · a two-guard chain: `collar`'s guard reads `cuff`, which enters only through `interfacing`.
# Every "-held" atom is present-and-not-excluded, the exclude conjunct written as a `neg` literal
# (v1's `hasAspect` shape, kept so an unmodified module's meaning survives — den-hoag-bme8i).
# `cycle` adds one exclude cycle with no negation written by the author at the guard: `dart` enters
# when `welt` is held, and `dart` unpicks `welt`. It has no stable model: `dart` reads `U`, the
# adjudication is `refused`, and the three settled shapes beside it keep their answers unspread.
# `closureGuard` offers the same edge with its guard as a Nix closure: the declaration door refuses
# it by name, because an undeclared read is unconstructible there (M2, no gen change).
{ genProgram }:
let
  fact = head: {
    inherit head;
    relata = [ "bolt" ];
  };
  rule = head: pos: neg: {
    inherit head pos neg;
    relata = [ "bolt" ];
  };
  settledDecls = [
    (fact "gusset:bolt")
    (rule "gusset-held:bolt" [ "gusset:bolt" ] [ "unpicked-gusset:bolt" ])
    (rule "yoke:bolt" [ ] [ "gusset-held:bolt" ])

    (fact "hem:bolt")
    (fact "bias:bolt")
    (rule "unpicked-hem:bolt" [ "bias:bolt" ] [ ])
    (rule "hem-held:bolt" [ "hem:bolt" ] [ "unpicked-hem:bolt" ])
    (rule "placket:bolt" [ "hem-held:bolt" ] [ ])

    (fact "lining:bolt")
    (rule "lining-held:bolt" [ "lining:bolt" ] [ "unpicked-lining:bolt" ])
    (rule "interfacing:bolt" [ "lining-held:bolt" ] [ ])
    (rule "cuff:bolt" [ "interfacing:bolt" ] [ ])
    (rule "cuff-held:bolt" [ "cuff:bolt" ] [ "unpicked-cuff:bolt" ])
    (rule "collar:bolt" [ "cuff-held:bolt" ] [ ])
  ];
  cycleDecls = settledDecls ++ [
    (fact "welt:bolt")
    (rule "welt-held:bolt" [ "welt:bolt" ] [ "unpicked-welt:bolt" ])
    (rule "dart:bolt" [ "welt-held:bolt" ] [ ])
    (rule "unpicked-welt:bolt" [ "dart:bolt" ] [ ])
  ];
  onePass =
    declarations:
    genProgram.model {
      program =
        genProgram.program [ "bolt" ] # one pass, no earlier pass to carry
          declarations;
      interpretation = [ ];
      prior = null;
      complete = true;
    };
in
{
  settledPass = onePass settledDecls;
  cyclePass = onePass cycleDecls;
  closureGuard = onePass [ (rule "yoke:bolt" [ (ctx: !(ctx.hasAspect "gusset")) ] [ ]) ];
}
