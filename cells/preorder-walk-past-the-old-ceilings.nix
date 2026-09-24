# `preorder-walk-past-the-old-ceilings` — C51, den-hoag-2t0sj / den-hoag-ngtxq. gen-graph's pre-order
# walks and `ancestorsOf` are `genericClosure` loops with no depth or fan-out ceiling: `expandPreorder`
# over a star of 40,001 (where the recursive walk aborted with a stack overflow), `foldReach` over a
# star of 8,001 (where it exceeded max-call-depth), and all four over a chain of 20,000 (where each
# refused past its depth cap). On a small cyclic graph the answers keep their pre-order: a frame
# before its children, siblings in list order, the first occurrence wins, and a seeded key prunes
# its subtree. Red if any walk aborts, refuses, or answers in another order.
{
  asserts,
  genGraph,
}:
let
  nm = i: "n${toString i}";
  idx = id: builtins.fromJSON (builtins.substring 1 20 id);
  star = n: id: if id == "n0" then builtins.genList (i: nm (i + 1)) (n - 1) else [ ];
  chain = n: id: if idx id + 1 < n then [ (nm (idx id + 1)) ] else [ ];
  len = xs: builtins.length (builtins.deepSeq xs xs);
  expand =
    edges: seen0:
    genGraph.expandPreorder {
      roots = [ "n0" ];
      key = f: f;
      inherit edges seen0;
    };
  reach =
    edges:
    (genGraph.foldReach {
      roots = [ { to = "n0"; } ];
      edges = id: map (t: { to = t; }) (edges id);
      target = e: e.to;
      project = e: [ e.to ];
      itemKey = i: i;
    }).nodes;
  count =
    edges:
    (genGraph.foldPreorder {
      roots = [ "n0" ];
      key = f: f;
      acc = 0;
      expand = a: f: {
        acc = a + 1;
        children = edges f;
      };
    }).acc;

  # awl → [twill, spool]; twill → [spool, awl]; spool → [heddle, twill]; heddle → [ ].
  loom = {
    awl = [
      "twill"
      "spool"
    ];
    twill = [
      "spool"
      "awl"
    ];
    spool = [
      "heddle"
      "twill"
    ];
    heddle = [ ];
  };
  woven = id: loom.${id} or [ ];
  order =
    seen0:
    (genGraph.expandPreorder {
      roots = [ "awl" ];
      key = f: f;
      edges = woven;
      inherit seen0;
    }).nodes;
in
{
  construct = [ "C51" ];
  check = asserts (
    len (expand (star 40001) { }).nodes == 40001
    && len (reach (star 8001)) == 8001
    && len (expand (chain 20000) { }).nodes == 20000
    && len (reach (chain 20000)) == 20000
    && count (chain 20000) == 20000
    &&
      len (
        genGraph.ancestorsOf { parent = id: if idx id == 0 then null else nm (idx id - 1); } (nm 19999)
      ) == 19999
    &&
      order { } == [
        "awl"
        "twill"
        "spool"
        "heddle"
      ]
    &&
      order { spool = true; } == [
        "awl"
        "twill"
      ]
  );
}
