# `layered-fold` — C13. All three `foldLayers` strategies plus the default channel in one call.
#
# C13 — `foldLayers`: all three strategies plus the default channel in one call.
{ asserts, folded }:
{
  construct = [ "C13" ];
  check = asserts (
    folded == {
      gauge = "fine";
      meta = {
        warp = 1;
        weft = 2;
      };
      spool = "sateen";
      tacks = [
        "a"
        "b"
      ];
    }
  );
}
