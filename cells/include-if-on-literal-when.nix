# `include-if-on-literal-when` — C177, den-hoag-fuci G1. den v1's `includeIf` shapes written as
# literal `when` terms decide as v1's tests and the fuci spike say: the fallback pair splits on a
# present aspect and flips when that aspect is excluded; a guard over an absent aspect, `_: false` and an
# unreached includer all leave their payload out; `_: true`, a disjunction and a guard reading another
# guard's payload let theirs in; a negated conjunction is out by its DNF; a sibling's membership does
# not reach the guard and an ancestor's does. An exclude cycle reads `U`, refuses `included` and is
# adjudicated `refused`, with every settled answer beside it unchanged. A closure `when` is refused.
{
  asserts,
  includeIfPass,
  includeIfCycle,
  includeIfClosure,
}:
let
  T = included: {
    flag = "T";
    inherit included;
  };
  inn = p: a: p.resolve a == T true;
  out = p: a: p.resolve a == T false;
  settled =
    p:
    builtins.all (inn p) [
      "facing:bolt"
      "piping:bolt"
      "hem:bolt"
      "placket:bolt"
      "interlining:remnant"
      "lining:remnant"
      "collar:remnant"
    ]
    && builtins.all (out p) [
      "interlining:bolt"
      "ruffle:bolt"
      "binding:bolt"
      "shirring:bolt"
      "yoke:bolt"
      "facing:remnant"
      "gusset-held:remnant"
    ];
in
{
  construct = [ "C177" ];
  check = asserts (
    includeIfPass.adjudication.outcome == "admitted"
    && settled includeIfPass
    && includeIfCycle.adjudication.outcome == "refused"
    && (includeIfCycle.resolve "dart:bolt").flag == "U"
    && !(builtins.tryEval (includeIfCycle.resolve "dart:bolt").included).success
    && settled includeIfCycle
    && !(builtins.tryEval (builtins.deepSeq includeIfClosure includeIfClosure)).success
  );
}
