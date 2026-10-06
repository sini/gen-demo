# `options-first-composes` — C91, den-hoag-7gp66 P2. A door that takes options takes them FIRST, in
# one closed set, so the partially applied `door opts` is a value a caller composes. `upTo3` is
# gen-graph's `pathsBetween` with its depth cap stated once, then mapped over three ends with one
# accessor record: the walk to `heddle` returns and the walk to `reed`, one hop past the cap, is
# refused. The same door under `{ }` walks to `reed` too, so the cap is carried by the partial
# application, not dropped. `ancestorsOf { }`, mapped the same way, is the composition over a door
# whose one option is retired; its published contract is read AS DATA (`__contract`), and names
# `maxDepth` (accepted only to be refused as retired) and the accessor record's `parent`. The record
# step is also published WITHOUT application, nested in the first step's contract (`__contract.next`,
# den-hoag-ak8va; OQ16 "nest"), and that nest is the contract the applied step answers with.
{
  asserts,
  genGraph,
}:
let
  # awl → twill → spool → heddle → reed
  down = {
    awl = "twill";
    twill = "spool";
    spool = "heddle";
    heddle = "reed";
  };
  up = builtins.listToAttrs (
    map (k: {
      name = down.${k};
      value = k;
    }) (builtins.attrNames down)
  );
  acc = {
    nodes = builtins.attrNames down ++ [ "reed" ];
    edges = id: if down ? ${id} then [ down.${id} ] else [ ];
  };
  parents.parent = id: up.${id} or null;
  walks = f: map (end: (builtins.tryEval (builtins.deepSeq (f acc "awl" end) true)).success);
  upTo3 = genGraph.pathsBetween { maxDepth = 3; };
  ends = [
    "twill"
    "heddle"
    "reed"
  ];
in
{
  construct = [ "doors-options-first-and-composed" ];
  check = asserts (
    walks upTo3 ends == [
      true
      true
      false
    ]
    &&
      walks (genGraph.pathsBetween { }) ends == [
        true
        true
        true
      ]
    &&
      map (genGraph.ancestorsOf { } parents) [
        "twill"
        "spool"
      ] == [
        [ "awl" ]
        [
          "twill"
          "awl"
        ]
      ]
    && genGraph.ancestorsOf.__contract.optional == [ "maxDepth" ]
    && (genGraph.ancestorsOf { }).__contract.required == [ "parent" ]
    && genGraph.pathsBetween.__contract.optional == [ "maxDepth" ]
    && genGraph.ancestorsOf.__contract.next or null == (genGraph.ancestorsOf { }).__contract
    && genGraph.pathsBetween.__contract.next or null == (genGraph.pathsBetween { }).__contract
  );
}
