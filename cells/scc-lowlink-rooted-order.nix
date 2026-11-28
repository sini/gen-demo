# `scc-lowlink-rooted-order` — gen-graph's `lowlink` arm with a `root` option (`lowlink { root; } g`) returns, from
# the one run that finds the partition, the cyclic set (`cyclic`, equal to `cycles`) and a dependency order
# (`order`): every node once, each strongly connected component's members together, each component after every
# component it reaches. On the DAG `tack` the order is the depth-first finishing order from the root, successors in
# list order (`tack → loom, card; loom → bolt`), so `bolt loom card tack` and not key order. On the late-entry graph
# the component {spool, twill} comes before `awl`, which reaches it; the members' order inside it is not promised and
# is not read. A root outside `nodes` is refused by name, catchably, and `root` left on the graph record is refused
# as an option.
{
  asserts,
  genGraph,
}:
let
  dag = {
    nodes = [
      "bolt"
      "card"
      "loom"
      "tack"
    ];
    edges =
      id:
      {
        tack = [
          "loom"
          "card"
        ];
        loom = [ "bolt" ];
        card = [ ];
        bolt = [ ];
      }
      .${id};
  };
  late = genGraph.forgetLabels {
    nodes = [
      "awl"
      "spool"
      "twill"
    ];
    labeledEdges =
      id:
      {
        awl = [
          {
            label = "pos";
            target = "twill";
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
      }
      .${id};
  };
  r = genGraph.lowlink { root = "awl"; } late;
  refuses = v: !(builtins.tryEval (builtins.deepSeq v true)).success;
in
{
  construct = [ "rooted-dependency-order" ];
  check = asserts (
    (genGraph.lowlink { root = "tack"; } dag).order == [
      "bolt"
      "loom"
      "card"
      "tack"
    ]
    && r.cyclic == genGraph.cycles late
    &&
      r.cyclic == [
        "spool"
        "twill"
      ]
    &&
      builtins.sort builtins.lessThan (builtins.genList (builtins.elemAt r.order) 2) == [
        "spool"
        "twill"
      ]
    && builtins.elemAt r.order 2 == "awl"
    &&
      builtins.removeAttrs r [
        "cyclic"
        "order"
      ] == genGraph.lowlink { } late
    && refuses (genGraph.lowlink { root = "zz"; } late).order
    && refuses (genGraph.lowlink { } (late // { root = "awl"; })).sccOf
  );
}
