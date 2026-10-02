# `aspect-dead-nested` — C16, den-hoag-ouuwg. `graphFacts` publishes `deadNested`, the nested
# aspects whose subtree delivers nothing (no declared class content, no includes, no delivering
# child), and warns once per forced record when it is non-empty. Over this corpus it names C16's
# three placeholder nodes, which are intended taxonomy: `hemline/placket` is still an include target
# (`bartack`), so "delivers nothing" holds and "dead" is the view's name, not a defect here. The
# delivering siblings (`stitch/trim`, a guard leaf) and every root stay out of it.
{
  asserts,
  c16Facts,
}:
{
  construct = [ "C16" ];
  check = asserts (
    c16Facts.deadNested == [
      "hemline/facing"
      "hemline/placket"
      "hemline/placket/eyelet"
    ]
    &&
      c16Facts.deadNested
      == builtins.filter (
        id: c16Facts.parentOf.${id} != null && !c16Facts.deliversOf.${id}
      ) c16Facts.nodes
  );
}
