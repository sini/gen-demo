# `refusal-value-at-an-aspect-position` — C175, den-hoag-3sk7j. gen-program's `escape` and `admit 42`
# refusals, forwarded unread into an aspect's `includes` and at a root, are each refused catchably;
# an aspect included beside them is admitted. What each refusal SAYS is refusals row 144.

{
  asserts,
  c175Refused,
  c175Control,
}:

{
  construct = [ "refusal-value-at-an-aspect-position-is-refused-by-name" ];
  check = asserts (
    c175Refused == {
      escapeInIncludes = true;
      admitInIncludes = true;
      admitAtRoot = true;
    }
    && c175Control == [ "fringe" ]
  );
}
