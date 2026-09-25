# `gate-candidate-cycle-off` — C7 under den-hoag-6s1t (iii). A cycle that exists ONLY through a
# policy edge that resolved OFF must still be refused: the gate is static, so it ranges over every
# declared candidate (head + relata, on or off), never over what one model happened to reach.
#
# THE REAL CONSTRUCTS, RE-APPLIED — `constructs/c05.nix`, `c01.nix` and `c07.nix` are called here
# with exactly the names their formals read, as the flake's `callWith` does, over a planted state:
#   · OFF: `genProgram.program` receives one extra fact, `scotched:pewter`, which C5's two
#     conditional heads negate, so both resolve off;
#   · the BACK-EDGE: `faille -> grosgrain` joins the declared edges. With C5's piping candidate
#     `grosgrain -> faille` it closes a cycle; without it nothing does.
# A mirror of C7 would pass against a gate that never saw the candidate, which is the defect.
#
# Four conjuncts, one run: the plant really is OFF (liveness); the REACHED graph is acyclic, so the
# cycle is carried by the candidate alone; the gate REFUSES the planted state; the same state
# without the back-edge is ADMITTED (the control that keeps a gate refusing everything from
# passing). The refusal's NAME is `ci/refusals/row81.sh`'s, because `tryEval` discards messages.
{
  asserts,
  genGraph,
  genProgram,
  genScope,
  genValues,
  genView,
  seamCoords,
  seamHead,
  seamSpace,
}:
let
  call = f: env: f (builtins.intersectAttrs (builtins.functionArgs f) env);
  offProgram = genProgram // {
    program =
      a:
      genProgram.program (
        a
        // {
          declarations = a.declarations ++ [
            {
              head = "scotched:pewter";
              relata = [ "pewter" ];
            }
          ];
        }
      );
  };
  stateWith =
    extra:
    let
      values = genValues // {
        declaredEdges = genValues.declaredEdges ++ extra;
      };
      c5 = call (import ../constructs/c05.nix) {
        genProgram = offProgram;
        inherit seamCoords seamHead seamSpace;
      };
      c1 = call (import ../constructs/c01.nix) {
        inherit genScope;
        genValues = values;
        inherit (c5) seamPromotion;
      };
      c7 = call (import ../constructs/c07.nix) (
        c5
        // c1
        // {
          inherit genGraph genView;
          genValues = values;
        }
      );
      reachedEdges = values.declaredEdges ++ c5.pipingEdge ++ c5.seamPromotion.edges;
    in
    {
      off = !(c5.mdl.resolve c5.pipingHead).included && c5.seamPromotion.nodes == { };
      reachedCyclic =
        builtins.any (scc: builtins.length scc > 1)
          (genGraph.condensation {
            nodes = builtins.attrNames c1.nodes;
            edges = id: map (e: e.to) (builtins.filter (e: e.from == id) reachedEdges);
          }).sccs;
      admitted = (builtins.tryEval (builtins.deepSeq c7.gated true)).success;
    };
  planted = stateWith [
    {
      from = "faille";
      to = "grosgrain";
      label = "tacks";
    }
  ];
  control = stateWith [ ];
in
{
  construct = [ "C7" ];
  check = asserts (planted.off && !planted.reachedCyclic && !planted.admitted && control.admitted);
}
