# `a-malformed-route-into-a-sibling-warp-leaves-the-contained-receiver-usable` — gen-delivery `forward`'s sibling
# isolation where C2 is live (heddle and pirn have no terminal, so their cells are stripped). A third warp `twill`
# whose one route carries a malformed `order` refuses twill by name, while selvage reads exactly the contained
# receiver's value and the diagnostics stay data. Red if the stripping checks every route (twill's fault refuses
# selvage), if twill is admitted, or if `diagnostics.cycles` throws the malformed route's text.
{
  asserts,
  forwardContained,
  forwardContainedBesideMalformed,
}:
let
  inherit (forwardContainedBesideMalformed) realized diagnostics;
  twill = builtins.tryEval (builtins.deepSeq realized.warp.twill realized.warp.twill);
in
{
  construct = [ "forwarded-occurrence-reaches-a-nested-receiver" ];
  check = asserts (
    realized.warp.selvage == forwardContained.realized.warp.selvage
    && !twill.success
    && diagnostics.cycles == [ ]
  );
}
