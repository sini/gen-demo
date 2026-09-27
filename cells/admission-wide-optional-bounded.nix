# `admission-wide-optional-bounded` — C4, den-hoag-6bh04. A movement's admission is a
# user-authored path expression, and gen-view parses it through gen-graph at construction.
# `tacks?` 166 times is 996 characters, inside the parser's 1,000-character cap: one sequence of
# 166 nullable elements. A derivative step over such a sequence re-walked every suffix, so walking
# all 166 labels took 567,618,999 calls on the regex kernel; a seq is now a right-nested cons whose
# suffixes are terms, and one step walks each suffix once (747,602 calls on the kernel).
# This cell is EXERCISE, NOT AN ORACLE: its answers are the same before the change as after it,
# and it passes at the red state. gen-graph's width oracle is the calls figure measured in the
# den-hoag-6bh04 landing report.
{ asserts, genView }:
{
  construct = [ "C4" ];
  check = asserts (
    let
      rep = n: s: builtins.concatStringsSep "" (builtins.genList (_: s) n);
      a = genView.labelWellFormedness {
        alphabet = genView.edgeLabels { letters = [ "tacks" ]; };
        expression = rep 166 "tacks?";
      };
      after = n: builtins.foldl' (s: _: a.step "tacks" s) a.expr (builtins.genList (i: i) n);
    in
    map (n: a.accepts (after n)) [
      0
      1
      3
      166
      167
    ] == [
      true
      true
      true
      true
      false
    ]
  );
}
