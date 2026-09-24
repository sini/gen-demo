# `scc-lowlink-late-entry` — C50, den-hoag-c48r1. gen-graph's `lowlink` arm (Tarjan's DFS, iterated)
# partitions a graph whose depth-first walk from `awl` ENTERS the component {spool, twill} at its
# larger member, `twill`. The component is tagged by its smallest member, `spool`, not by the DFS
# root; the arm agrees with `fbNode` on the whole record; and `cyclicEdgesWhere`, which binds
# `lowlink`, answers the one `neg` edge inside the component and not the one that leaves `awl`.
#
# C50 -- den-hoag-c48r1.
{
  asserts,
  genGraph,
}:
let
  labelled = {
    awl = [
      {
        label = "pos";
        target = "twill";
      }
      {
        label = "neg";
        target = "spool";
      }
    ];
    twill = [
      {
        label = "neg";
        target = "spool";
      }
    ];
    spool = [
      {
        label = "pos";
        target = "twill";
      }
    ];
  };
  lg = {
    nodes = builtins.attrNames labelled;
    labeledEdges = id: labelled.${id};
  };
  g = genGraph.forgetLabels lg;
in
{
  construct = [ "C50" ];
  check = asserts (
    (genGraph.lowlink g).sccOf == {
      awl = "awl";
      spool = "spool";
      twill = "spool";
    }
    && genGraph.lowlink g == genGraph.fbNode g
    &&
      genGraph.cyclicEdgesWhere lg (l: l == "neg") == [
        {
          from = "twill";
          label = "neg";
          to = "spool";
        }
      ]
  );
}
