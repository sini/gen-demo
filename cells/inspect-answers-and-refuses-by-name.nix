# `inspect-answers-and-refuses-by-name` — C25, den-hoag-graph-viz-viy69. The query surface answers
# over this graph AND the door refuses a name it does not carry, and the pair is the assertion
# rather than either half. Against a raw row source an unknown table yields `[ ]` at exit 0,
# indistinguishable from "no such edge", so a refusal alone proves nothing without an answer beside
# it. Two refusals are driven: an unknown table, and an unknown LABEL VALUE — the sharp one, a
# well-formed query over a known column whose value nothing publishes. A label this graph does carry
# is the live control on the same door.
#
# C25 — the query surface answers over this graph, and the DOOR refuses a name
# it does not carry. The pair is the assertion: against a raw row source an unknown
# table yields `[ ]` at exit 0, which is indistinguishable from "no such edge", so a
# refusal alone proves nothing without the answer beside it and the answer alone
# proves nothing without the refusal.
{
  asserts,
  c25Ir,
  c25Refuses,
}:
{
  construct = [ "C25" ];
  check = asserts (
    c25Ir.query "SELECT src, dst FROM edge WHERE label = 'gathers'" == [
      {
        src = "pewter";
        dst = "damask";
      }
    ]
    &&
      c25Ir.query "SELECT name FROM thimble ORDER BY name" == [
        { name = "damask"; }
        { name = "pewter"; }
      ]
    # the unknown TABLE, and the unknown LABEL VALUE — the second is the sharp one,
    # a well-formed query over a known column whose value nothing publishes
    && c25Refuses "SELECT name FROM spindles"
    && c25Refuses "SELECT src FROM edge WHERE label = 'basting'"
    # …and the live control on the same door: a label this graph DOES carry answers
    &&
      c25Ir.query "SELECT src FROM edge WHERE label = 'tacks' ORDER BY src" == [
        { src = "grosgrain"; }
        { src = "pewter"; }
      ]
  );
}
