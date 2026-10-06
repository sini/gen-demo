# `admission-plus-family-keys-bounded` — C4, den-hoag-2dx7j. A movement's admission is a
# user-authored path expression, and gen-scope's `wellFormed` parses it at construction. Thirty
# levels of `(…)+` around `tacks` is 95 characters, and `plus` holds its argument twice at every
# level, so the old rendered state key grew as 2^k and gen-graph interned it as an attribute name:
# an uncatchable `Size of symbol exceeds 4GiB` abort, well inside the parser's 1,000-character cap.
# The key is now a Merkle digest, so the admission constructs and walks. Plain `tacks+` is the
# control: the same answers at one level, where the old key was short.
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
      admissionOf =
        expression:
        genScope.wellFormed {
          alphabet = (genView.edgeLabels { letters = [ "tacks" ]; }).letters;
          inherit expression;
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
      # accepts no word, accepts `tacks`, accepts `tacks tacks`
      answers =
        a:
        accepts a 3 [
          0
          1
          2
        ];
      deep = admissionOf (rep 30 "(" + "tacks" + rep 30 ")+");
      shallow = admissionOf "(tacks)+";
    in
    answers deep == [
      false
      true
      true
    ]
    && answers shallow == answers deep
  );
}
