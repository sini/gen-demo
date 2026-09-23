# ── C13 — `foldLayers` over an invented layered record (ADR-0017): all three strategies
# plus the default channel in one call, so a fold that only did `replace` would be green
# under a broken `append`.
{ genAlgebra }:
let
  weaveLayers = [
    {
      spool = "linen";
      tacks = [ "a" ];
      meta.warp = 1;
    }
    {
      spool = "sateen";
      tacks = [ "b" ];
      meta.weft = 2;
    }
  ];
  folded = genAlgebra.record.foldLayers {
    strategies = {
      tacks = "append";
      meta = "recursive";
    };
    defaults = {
      gauge = "fine";
    };
    layers = weaveLayers;
  };
in
{
  inherit weaveLayers folded;
}
