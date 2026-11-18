# `forwarded-occurrence-reaches-a-contained-receiver` — den-hoag-6md1q C5 (spec G12's topology cell, invented
# names). Each pirn's settings reach its heddle at `pirns.<pirn>` (its captured name), and each heddle's whole
# cell reaches its warp at `heddles.<heddle>` (the hop's scope), through the REAL `genDelivery.forward`. Red if
# `forward` is absent, if a received pirn is dropped at the W1 hop or placed at the heddle's root, if a heddle
# lands under another's name, or if fringe's duplicate route reaches selvage (sibling isolation) or is silent.
{ asserts, forwardContained }:
let
  inherit (forwardContained) realized;
  fringe = builtins.tryEval (builtins.deepSeq realized.warp.fringe realized.warp.fringe);
in
{
  construct = [ "forwarded-occurrence-reaches-a-nested-receiver" ];
  check = asserts (
    realized.warp.selvage == {
      tabby = {
        reed = 12;
        pirns = {
          quill.ply = "two";
          cop.ply = "three";
        };
      };
      ottoman = {
        reed = 8;
        pirns.spool.ply = "single";
      };
    }
    &&
      builtins.attrNames realized.warp == [
        "fringe"
        "selvage"
      ]
    && !fringe.success
    && builtins.elem "warp.fringe" forwardContained.diagnostics.refusing
  );
}
