# shellcheck shell=bash
# ── row 38 -- a distance rule returning a non-int is refused by name (gen-view hvucx, ADR-0025
#    item 1; C4b's diamond shape) ──
# `pewter` reaches `grosgrain` in one `tacks` hop and in two, in ONE derivative state, so the
# projection compares the two arrivals' distances. A caller's `distance` rule returning a string
# used to be compared as one: "x" against 1 aborted uncatchably, and two strings ordered
# lexicographically. The arms differ by the rule alone; the unplanted arm is the hop count and
# asserts the one-hop arrival survives, so a library refusing every rule cannot pass it.
row38='let
  genView = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.view;
  genScope = (builtins.getFlake (toString ./.)).inputs.gen.lib.substrate.scope;
  labels = genView.edgeLabels { letters = [ "tacks" ]; };
  admission = genScope.wellFormed { alphabet = labels.letters; expression = "tacks*"; };
  order = genScope.labelOrder { alphabet = labels.letters; layers = [ [ "tacks" ] ]; endOfPath = -1; };
  channel = genView.dataOrder { channel = "selvage"; keyOf = c: c.scope; };
  relation = genView.viewRelation { engine = genScope;
    definition = genView.viewDefinition {
      inherit channel admission order;
      relation = "gimp"; root = "pewter"; direction = "outbound"; wellFormed = _: true;
      distance = DISTANCE;
      tieSet = genView.tieSets.union; empty = [ ];
      combine = genView.combines.listAppend; dedup = genView.dedups.none;
    };
    graph = genView.scopeGraph {
      carrier = genView.carrier {
        inherit labels;
        relatumLabels = genView.relatumLabels { names = [ ]; };
        labelWellFormedness = admission; labelOrder = order; dataOrder = channel;
        relations = genView.relations { names = [ "gimp" ]; };
      };
      scopes = [ "grosgrain" "faille" "pewter" ];
      edges.tacks = id: { pewter = [ "faille" "grosgrain" ]; faille = [ "grosgrain" ]; }.${id} or [ ];
      data = [ { scope = "grosgrain"; relation = "gimp"; datum = [ "cambric" ]; } ];
    };
    marks = _: [ ];
    orderMark = genScope.labelOrder { alphabet = labels.letters; layers = [ [ "tacks" ] ]; endOfPath = 0; };
  };
in builtins.toJSON (builtins.deepSeq relation.value (map (c: c.distance) relation.contributions))'
check "T5 row38 unplanted (the hop count; the one-hop arrival survives)" \
  "${row38/DISTANCE/s: s.distance + 1}" 0 "" \
  "$tmpdir/row38-green.err" '[1]'
check "T5 row38 planted   (a rule returning a string, refused by name)" \
  "${row38/DISTANCE/s: if builtins.isInt s.distance then \"x\" else 1}" 1 \
  "gen-view.viewRelation: channel 'selvage' declares a distance rule that returned \"x\"" \
  "$tmpdir/row38-red.err"
