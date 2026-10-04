# `fan-out-follows-declared-descendants` — C186, den-hoag-htfv3 (D7). `flounce` reaches `fringe`,
# which fans out to one sibling per tassel descendant. The siblings are delivered in the order the
# scope declares its descendants, never by instance id, so reversing the declared list reverses the
# realized one. The realized list is that declared order REVERSED, as the stock list merge reverses
# every node's members: `[ t1 t2 ]` realizes `tassel-2` first.
{
  asserts,
  sharedEvalFanOut,
}:
{
  construct = [ "C186" ];
  check = asserts (
    sharedEvalFanOut [
      "t1"
      "t2"
    ] == [
      "tassel-2"
      "tassel-1"
      "fringe"
      "fringe"
    ]
    &&
      sharedEvalFanOut [
        "t2"
        "t1"
      ] == [
        "tassel-1"
        "tassel-2"
        "fringe"
        "fringe"
      ]
  );
}
