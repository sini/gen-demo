# `membership-guard-lowered-to-atoms` — C105, den-hoag-fuci. Three settled shapes (a negated
# present aspect, an unconditionally excluded one, a two-guard chain) all admit, with `yoke` and
# `placket` out and `collar` in. Adding one exclude cycle with no negation written at the guard —
# `dart` enters through `welt-held` and unpicks `welt` — reds the pass: `dart` is `U`, `included`
# refuses `tryEval`, and the adjudication is `refused`; the three settled answers are unchanged
# beside it, because the contest does not spread to its neighbours. A guard written as a Nix
# closure instead of `pos`/`neg` literals is refused at the declaration door, catchably.
{
  asserts,
  settledPass,
  cyclePass,
  closureGuard,
}:
let
  T = included: {
    flag = "T";
    inherit included;
  };
  settledAnswers =
    m:
    m.resolve "yoke:bolt" == T false
    && m.resolve "placket:bolt" == T false
    && m.resolve "collar:bolt" == T true;
  dart = cyclePass.resolve "dart:bolt";
in
{
  construct = [ "within-pass-conditional-edge-guard-as-data" ];
  check = asserts (
    settledPass.adjudication.outcome == "admitted"
    && settledAnswers settledPass
    && cyclePass.adjudication.outcome == "refused"
    && dart.flag == "U"
    && !(builtins.tryEval dart.included).success
    && settledAnswers cyclePass
    && !(builtins.tryEval (builtins.deepSeq (closureGuard.resolve "yoke:bolt") true)).success
  );
}
