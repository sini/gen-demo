# `admission-plus-family-keys-bounded` — C4, den-hoag-2dx7j. A movement's admission is a
# user-authored path expression, and gen-view parses it through gen-graph at construction. Thirty
# levels of `(…)+` around `tacks` is 95 characters, and `plus` holds its argument twice at every
# level, so the old rendered state key grew as 2^k and gen-graph interned it as an attribute name:
# an uncatchable `Size of symbol exceeds 4GiB` abort, well inside the parser's 1,000-character cap.
# The key is now a Merkle digest, so the admission constructs and walks. Plain `tacks+` is the
# control: the same answers at one level, where the old key was short.
{ asserts, genView }:
{
  construct = [ "C4" ];
  check = asserts (
    let
      rep = n: s: builtins.concatStringsSep "" (builtins.genList (_: s) n);
      admissionOf =
        expression:
        genView.labelWellFormedness {
          alphabet = genView.edgeLabels { letters = [ "tacks" ]; };
          inherit expression;
        };
      # accepts no word, accepts `tacks`, accepts `tacks tacks`
      answers = a: [
        (a.accepts a.expr)
        (a.accepts (a.step "tacks" a.expr))
        (a.accepts (a.step "tacks" (a.step "tacks" a.expr)))
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
