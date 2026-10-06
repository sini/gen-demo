{
  title = "den v1's `includeIf` on the literal `when` tier";
  adr = "0010 4(b), 0008, 0020, fuci";
  what = "`include-if-on-literal-when`: v1's guard sees only `hasAspect`, so each guard is a Boolean function of membership atoms and its disjunctive normal form is one declaration per disjunct, each body a `has` / `not` conjunction in the literal `when` tier. The fallback pair splits on a present aspect and flips when that aspect is excluded; a guard over an absent aspect, `_: false` and an unreached includer leave their payload out; `_: true`, a disjunction and a guard reading another guard's payload let theirs in; a negated conjunction is out by its DNF; a sibling scope's membership does not reach the guard and an ancestor's does. An exclude cycle reads `U`, refuses `included`, is adjudicated `refused`, and every settled answer beside it is unchanged. A closure `when` is refused at the door (row 145).";
}
