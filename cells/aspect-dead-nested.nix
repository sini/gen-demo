# `aspect-dead-nested` — C16, den-hoag-ouuwg. `graphFacts` publishes `deadNested`, the nested
# aspects whose subtree delivers nothing (no declared class content, no includes, no delivering
# child), and warns once per forced record when a dead node's id is not listed in the cnf's
# `freeformKeys` (den-hoag-l62pz). Over this corpus the view names C16's three placeholder nodes,
# which are intended taxonomy: `hemline/placket` is still an include target (`bartack`), so
# "delivers nothing" holds and "dead" is the view's name, not a defect here. `aspect-cnf.nix` lists
# each of the three by id, which declares it intended, so the record warns nothing over this corpus
# (T5 row 153 holds that under `abort-on-warn`). The delivering siblings (`stitch/trim`, a guard
# leaf) and every root stay out of the view.
{
  asserts,
  c16Facts,
}:
let
  cnf = import ../aspect-cnf.nix;
in
{
  construct = [ "aspect-graph-assembled" ];
  # `or null`: a gen-aspects that does not publish the view reds this cell, not every check.
  check = asserts (
    (c16Facts.deadNested or null) == [
      "hemline/facing"
      "hemline/placket"
      "hemline/placket/eyelet"
    ]
    &&
      c16Facts.deadNested
      == builtins.filter (
        id: c16Facts.parentOf.${id} != null && !c16Facts.deliversOf.${id}
      ) c16Facts.nodes
    # every dead node is declared intended by its id
    && builtins.all (id: builtins.elem id cnf.freeformKeys) c16Facts.deadNested
  );
}
