# `cycle-witness-and-domain` — C52, den-hoag-90k1b. gen-graph's cycle surfaces read off the
# `lowlink` partition. {hem, seam, yoke} holds two simple cycles through `hem`; `cyclePaths` returns
# the one a depth-first search from `hem`'s first successor finds (`seam → yoke → hem`), not the
# shorter `seam → hem`. `tag` is cyclic by its self-loop alone; `cuff` lies on no cycle. And an edge
# to `selvedge`, which is not a node, is refused by name by `cycles`, `cyclePaths` and the partition
# door `condensation` alike.
#
# C52 -- den-hoag-90k1b.
{
  asserts,
  genGraph,
}:
let
  m = {
    cuff = [ "hem" ];
    hem = [ "seam" ];
    seam = [
      "yoke"
      "hem"
    ];
    yoke = [ "hem" ];
    tag = [ "tag" ];
  };
  g = {
    nodes = builtins.attrNames m;
    edges = id: m.${id};
  };
  open = g // {
    edges = id: if id == "cuff" then [ "selvedge" ] else m.${id} or [ ];
  };
  refused = v: !(builtins.tryEval (builtins.deepSeq v true)).success;
in
{
  construct = [ "C52" ];
  check = asserts (
    genGraph.cycles g == [
      "hem"
      "seam"
      "tag"
      "yoke"
    ]
    &&
      genGraph.cyclePaths g == [
        [
          "hem"
          "seam"
          "yoke"
        ]
        [ "tag" ]
      ]
    &&
      genGraph.topoOrderKahn g == {
        ok = false;
        cycles = [
          [
            "hem"
            "seam"
            "yoke"
          ]
          [ "tag" ]
        ];
      }
    && refused (genGraph.cycles open)
    && refused (genGraph.cyclePaths open)
    && refused (genGraph.condensation open)
  );
}
