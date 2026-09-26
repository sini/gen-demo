# ── C22 — a bounded extent peer-read (ADR-0026 reuse; gen-bind's extent
# peer-read shape, Q5 Arm A,
# specs/2026-09-08-gen-bind-extent-peer-read-shape-spec.md, den-hoag-gcr8x).
# Deliberately OUTSIDE `config.gen.composed`, the same way C15's cyclic stratum
# is: its own invented nodes, its own accessor. Three nodes over one invented
# kind, a complete peer relation, one node carrying an invented mark that
# admits no label. The REAL `mkHostedTerminal` adapter and the REAL
# `genDelivery.realize` (never a hand-written fold) bound the marked node's
# handed peer set to empty and name the mark on every withheld member, while
# the unmarked node's handed set stays the whole class.
{
  genBind,
  genDelivery,
  genGraph,
}:
let
  flounceNodes = [
    "grommet"
    "bodkin"
    "awl"
  ];
  flouncePeerGraph = genGraph.labeledFrom {
    nodes = flounceNodes;
    perLabel.kin = _id: flounceNodes;
  };
  flounceMarksOf =
    id:
    if id == "grommet" then
      [
        {
          name = "batting";
          admits = _label: false;
        }
      ]
    else
      [ ];
  flounceExtent = builtins.listToAttrs (
    map (n: {
      name = n;
      value = { };
    }) flounceNodes
  );
  flounceProjected.nodes = builtins.listToAttrs (
    map (n: {
      name = n;
      value = {
        bindings = { };
        classes.notion = [ { } ];
      };
    }) flounceNodes
  );
  # `realize`'s own per-node carriage (`{name;modules;bindings;extent;
  # extraModules;passthrough?;}`) is a different shape from the Adapter's
  # carriage (`{extent;extraModules;peerGraph;marksOf;readerId;passthrough?;
  # thunkBindings?;}`), so composing them needs the same thin wrapper gen-bind's
  # own O-1/O-2 oracle cells use (`ci/tests/crossing-extent-peer.nix`).
  #
  # The hub's `genBind` module arg, the ordinary path every other construct
  # here takes. C22 landed on a direct sibling input instead, because the hub's
  # `gen-bind` pin was then behind the shape this construct reads; that
  # exception stated its own drop condition, the condition is met, and dropping
  # it is what its text specified — see the ★ note on the inputs above.
  flounceAdapterOf =
    readerId:
    (genBind.crossing.mkHostedTerminal {
      evaluator = a: builtins.attrNames a.specialArgs.nodes;
      locateConfig = x: x;
      class = "notion";
    }).adapter
      {
        extent = flounceExtent;
        extraModules = [ ];
        peerGraph = flouncePeerGraph;
        marksOf = flounceMarksOf;
        inherit readerId;
      };
  flounceTerminal =
    carriage:
    let
      a = flounceAdapterOf carriage.name;
    in
    a.wrapUnit (a.bindFormals carriage.bindings carriage.modules) [ ];
  flounceRealized = genDelivery.realize {
    projected = flounceProjected;
    terminals.notion = flounceTerminal;
  };
in
{
  inherit
    flounceNodes
    flouncePeerGraph
    flounceMarksOf
    flounceExtent
    flounceAdapterOf
    flounceTerminal
    flounceRealized
    ;
}
