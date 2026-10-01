# ── C113 — a node receives what its aspects include (den-hoag-5q36i) ──
# One direct `genDelivery.project` call, the way C6 makes one, over two synthesized nodes outside
# `haberdashery`, so the hub realizes no new `nixosConfiguration`. `probe` lists `interfacing`,
# which includes `selvage` and is split across two modules (an attrset and a function); `control`
# lists `selvage` alone.
{ genDelivery, genValues }:
let
  includeProjection = genDelivery.project {
    values = genValues;
    cnf = import ../aspect-cnf.nix;
    selectNodes = _: {
      probe.aspects = [ "interfacing" ];
      control.aspects = [ "selvage" ];
    };
  };
in
{
  inherit includeProjection;
}
