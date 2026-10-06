# `fan-out-follows-entity-keys` — C186, den-hoag-htfv3 (D7), den-hoag-8g2rn (ruling 13). `flounce`
# reaches `fringe`, which fans out to one sibling per tassel its loom contains. The siblings are
# delivered in the order of the tassels' IDENTIFIERS (`containment`'s attribute names), canonical
# and never by identity or instance id, so renaming one tassel's identifier, its identity fixed,
# reverses the realized list. The realized list is that identifier order REVERSED, as the stock list
# merge reverses every node's members: `t1`, `t2` realizes `tassel-2` first, and `t2`, `z1` (t1
# renamed) realizes `tassel-1` first. The two arms carry the same identities and the same instance
# ids, so a list ordered by either reads one list for both.
{
  asserts,
  sharedEvalFanOut,
}:
{
  construct = [ "C186" ];
  check = asserts (
    sharedEvalFanOut {
      t1 = "t1";
      t2 = "t2";
    } == [
      "tassel-2"
      "tassel-1"
      "fringe"
      "fringe"
    ]
    &&
      sharedEvalFanOut {
        z1 = "t1";
        t2 = "t2";
      } == [
        "tassel-1"
        "tassel-2"
        "fringe"
        "fringe"
      ]
  );
}
