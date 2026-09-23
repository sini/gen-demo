# ── C4 — a movement declaration through gen-view (ADR-0010, ADR-0024) ──
# `carrier`'s field set is CLOSED — exactly these six. `relatumLabels` reads C3's relata names
# by construction (`builtins.attrNames bastingRelata`), not a restated copy.
{
  bastingRelata,
  genView,
  identityMark,
}:
let
  movementLabels = genView.edgeLabels { letters = [ "tacks" ]; };
  movementCarrier = genView.carrier {
    labels = movementLabels;
    relations = genView.relations { names = [ "gimp" ]; };
    relatumLabels = genView.relatumLabels { names = builtins.attrNames bastingRelata; };
    labelWellFormedness = genView.labelWellFormedness {
      alphabet = movementLabels;
      expression = "tacks*";
    };
    labelOrder = genView.labelOrder {
      alphabet = movementLabels;
      layers = [ [ "tacks" ] ];
      endOfPath = -1;
    };
    dataOrder = genView.dataOrder {
      channel = "selvage";
      keyOf = _: "selvage";
    };
  };
  movementDefinition = genView.compositions.movement {
    channel = "selvage";
    relation = "gimp";
    root = "pewter";
    direction = "outbound";
    admission = movementCarrier.labelWellFormedness;
    order = movementCarrier.labelOrder;
    wellFormed = _: true;
    empty = [ ];
    tieSet = genView.tieSets.union;
    combine = genView.combines.listAppend;
    dedup = genView.dedups.byDatum;
  };
  movementGraph = genView.scopeGraph {
    carrier = movementCarrier;
    scopes = [
      "pewter"
      "grosgrain"
    ];
    # The walk steps on `tacks` alone — the same static edge C2 also declares — and cannot enter
    # the binding, which carries no `tacks` edge of its own.
    edges = {
      tacks = id: if id == "pewter" then [ "grosgrain" ] else [ ];
    };
    data = [
      {
        scope = "grosgrain";
        relation = "gimp";
        datum = [ "cambric" ];
      }
    ];
  };
  moved = genView.viewRelation {
    definition = movementDefinition;
    marks = _: [ ];
    orderMark = identityMark movementLabels;
    graph = movementGraph;
  };
in
{
  inherit
    movementLabels
    movementCarrier
    movementDefinition
    movementGraph
    moved
    ;
}
