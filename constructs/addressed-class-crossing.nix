# ── C74 — an addressed class crossing (ADR-0028; gen-delivery's class-addressed inlet,
# den-hoag-9vkq). Deliberately OUTSIDE `config.gen.composed`, the way C22 is: its own invented
# nodes and three invented classes over the REAL `genDelivery.realize`. `picot` carries content in
# all three classes, `ruche` in `quilting` only. A consumer adapter carries `picot`'s own `quilting`
# content into `smocking`, and the crossing is ADDRESSED `smocking.picot` — the output's own
# coordinate — so it lands at the smocking terminal and at no other class, and a crossing addressed
# to a node where `smocking` does not realize is refused by name rather than dropped (T5 row94).
{ genDelivery }:
let
  crossingProjected.nodes = {
    picot = {
      bindings = { };
      classes = {
        smocking = [ { stitch = "smocking"; } ];
        quilting = [ { stitch = "quilting"; } ];
        tatting = [ { stitch = "tatting"; } ];
      };
    };
    ruche = {
      bindings = { };
      classes.quilting = [ { stitch = "quilting"; } ];
    };
  };
  # Every terminal reflects its carriage, so what arrived is readable without forcing a module.
  crossingTerminals = {
    smocking = a: a;
    quilting = a: a;
    tatting = a: a;
  };
  # The consumer's quilting -> smocking adapter: caller code, applied to the node's own content.
  quiltingToSmocking =
    node: map (m: { adaptedFrom = m; }) crossingProjected.nodes.${node}.classes.quilting;
  crossingRealized = genDelivery.realize {
    projected = crossingProjected;
    terminals = crossingTerminals;
    extraModules.smocking.picot = quiltingToSmocking "picot";
  };
in
{
  inherit
    crossingProjected
    crossingTerminals
    quiltingToSmocking
    crossingRealized
    ;
}
