# `movement-schedule-separator-names` — C49, den-hoag-qf55g. gen-view keys a cell by the JSON of its
# names, so a `consumer` writing `<grosgrain/hem, selvage>` and a `producer` reading `<grosgrain,
# hem/selvage>` are different cells and the schedule orders `["consumer","producer"]`, where the `/`
# join rendered one key and refused the schedule. The same schedule with `-` is the control, ordered
# on both sides.
#
# C49 -- den-hoag-qf55g. gen-view keys a cell by the JSON of its names, so two
# units whose scope and channel names carry the separator no longer collide. Under
# the old `/` join, `consumer`'s write `<grosgrain/hem, selvage>` and `producer`'s
# read `<grosgrain, hem/selvage>` rendered one key, and the schedule was refused as
# a cycle; the `-` arm is the control, ordered on both sides of the landing.
{ asserts, genView }:
{
  construct = [ "C49" ];
  check = asserts (
    let
      scheduleWith =
        sep:
        let
          labels = genView.edgeLabels { letters = [ "tacks" ]; };
          admission = genView.labelWellFormedness {
            alphabet = labels;
            expression = "tacks*";
          };
          order = genView.labelOrder {
            alphabet = labels;
            layers = [ [ "tacks" ] ];
            endOfPath = -1;
          };
          hem = "pewter${sep}hem";
          hemSelvage = "hem${sep}selvage";
          graph = genView.scopeGraph {
            carrier = genView.carrier {
              inherit labels;
              relations = genView.relations { names = [ "gimp" ]; };
              relatumLabels = genView.relatumLabels { names = [ ]; };
              labelWellFormedness = admission;
              labelOrder = order;
              dataOrder = genView.dataOrder {
                channel = "selvage";
                keyOf = c: c.scope;
              };
            };
            scopes = [
              hem
              "grosgrain"
            ];
            edges.tacks = _: [ ];
            data = [
              {
                scope = hem;
                relation = "gimp";
                datum = [ "cambric" ];
              }
              {
                scope = "grosgrain";
                relation = "gimp";
                datum = [ "voile" ];
              }
            ];
          };
          gathered =
            root: channel:
            genView.viewRelation {
              definition = genView.compositions.movement {
                inherit
                  channel
                  root
                  admission
                  order
                  ;
                relation = "gimp";
                direction = "outbound";
                wellFormed = _: true;
                empty = [ ];
                tieSet = genView.tieSets.union;
                combine = genView.combines.listAppend;
                dedup = genView.dedups.byDatum;
              };
              inherit graph;
              marks = _: [ ];
              orderMark = genView.labelOrder {
                alphabet = labels;
                layers = [ [ "tacks" ] ];
                endOfPath = 0;
              };
            };
          units = {
            consumer = genView.unit {
              relation = gathered hem "selvage";
              target = genView.placement.targets.root {
                scope = "grosgrain${sep}hem";
                channel = "selvage";
              };
              mode = "nest";
            };
            producer = genView.unit {
              relation = gathered "grosgrain" hemSelvage;
              target = genView.placement.targets.root {
                scope = "pewter";
                channel = hemSelvage;
              };
              mode = "nest";
            };
          };
          answer = genView.accumulatorOrder { inherit units; };
          r = builtins.tryEval (builtins.deepSeq answer answer);
        in
        if r.success then r.value else "REFUSED";
    in
    scheduleWith "/" == [
      "consumer"
      "producer"
    ]
    &&
      scheduleWith "-" == [
        "consumer"
        "producer"
      ]
  );
}
