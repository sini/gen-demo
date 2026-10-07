# ── C109 — declared content addressed to a class with no terminal (ADR-0028; ADR-0025 item 1;
# den-hoag-xtrxn). Deliberately OUTSIDE `config.gen.composed`, the way C74 is: its own invented node
# and two invented classes over the REAL `genDelivery.realize`. `bobbinet` carries content in `crewel`
# and in `sashiko`; the terminal set realizes `crewel` only. `sashiko`'s content is addressed to a
# class nothing realizes, so it is refused by name rather than dropped — the content arm of the
# refusal `realize` already makes for extras addressed to a class with no terminal.
{ genDelivery }:
let
  undeliveredProjected.nodes.bobbinet = {
    bindings = { };
    classes = {
      crewel = [ { stitch = "crewel"; } ];
      sashiko = [ { stitch = "sashiko"; } ];
    };
  };
  # Every terminal reflects its carriage, so what arrived is readable without forcing a module.
  undeliveredTerminals.crewel = a: a;
  realizeOver = terminals: genDelivery.realize { } terminals undeliveredProjected;
in
{
  inherit undeliveredProjected undeliveredTerminals;
  # the class `sashiko` has no terminal
  undeliveredRealized = realizeOver undeliveredTerminals;
  # CONTROL: the same projection with a terminal for every content class
  deliveredRealized = realizeOver (undeliveredTerminals // { sashiko = a: a; });
}
