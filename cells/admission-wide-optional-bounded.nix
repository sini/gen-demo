# `admission-wide-optional-bounded` — C4, den-hoag-6bh04. A movement's admission is a
# user-authored path expression, and gen-scope's `wellFormed` parses it at construction.
# `tacks?` 166 times is 996 characters, inside the parser's 1,000-character cap: one sequence of
# 166 nullable elements. A derivative step over such a sequence re-walked every suffix, so walking
# all 166 labels took 567,618,999 calls on the regex kernel; a seq is now a right-nested cons whose
# suffixes are terms, and one step walks each suffix once (747,602 calls on the kernel).
# This cell is EXERCISE, NOT AN ORACLE: its answers are the same before the change as after it,
# and it passes at the red state. gen-graph's width oracle is the calls figure measured in the
# den-hoag-6bh04 landing report.
{
  asserts,
  genView,
  genScope,
}:
{
  construct = [ "movement" ];
  check = asserts (
    let
      rep = n: s: builtins.concatStringsSep "" (builtins.genList (_: s) n);
      a = genScope.wellFormed {
        alphabet = (genView.edgeLabels { letters = [ "tacks" ]; }).letters;
        expression = rep 166 "tacks?";
      };
      # A word `tacks^k` is accepted iff the calculus reaches `c<k>` on a `tacks` chain from `c0`:
      # the derivative is gen-scope's to step (den-hoag-gayc D14), so the cell reads it through
      # `resolve` rather than stepping the admission by hand.
      chainOf =
        n:
        let
          id = i: "c${toString i}";
          next = builtins.listToAttrs (
            builtins.genList (i: {
              name = id i;
              value = if i + 1 < n then [ (id (i + 1)) ] else [ ];
            }) n
          );
        in
        genScope.eval { parseParent = _: null; } {
          children = _: _: { };
          marks = _: _: [ ];
          edges-tacks = _self: x: next.${x};
        } (genScope.buildRoots { parentGraph = genScope.vertices (builtins.genList id n); });
      reached =
        a: n:
        map (x: x.node)
          (genScope.resolve {
            wf = a;
            dataFilter = _: true;
            mode = "witnesses";
          } (chainOf n) "c0").answers;
      accepts =
        a: n: ks:
        map (k: builtins.elem "c${toString k}" (reached a n)) ks;
    in
    accepts a 168 [
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
