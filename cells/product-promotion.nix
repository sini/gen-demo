# `product-promotion` — C12. The product's own `dims` order, its cells, the promoted edge set, a
# projection, and the policy program's admission of the promoted head, all read off one `seamCoords`
# rather than restated.
#
# C12 — a derived product graph and a policy-stratum promotion. The KIND is the
# discriminator (Oracle 3 drives this red by seeding `productN "tensor"`), and the
# coordinate coupling is guarded by the fact that both the head and the scope
# admission below are read off `seamCoords`, never restated.
{
  asserts,
  bobbinNodes,
  genProduct,
  mdl,
  seamCell,
  seamHead,
  seamNodes,
  seamSpace,
  thimbles,
}:
{
  construct = [ "C12" ];
  check = asserts (
    seamSpace.product.dims == [
      "thimble"
      "bobbin"
    ]
    &&
      map (c: "${c.thimble}*${c.bobbin}") (genProduct.cells seamSpace) == [
        "damask*faille"
        "damask*grosgrain"
        "pewter*faille"
        "pewter*grosgrain"
      ]
    &&
      map (
        cid:
        let
          c = genProduct.coordsOf seamSpace cid;
        in
        "${c.thimble}*${c.bobbin}"
      ) (seamSpace.edges seamCell) == [
        "damask*grosgrain"
        "pewter*faille"
      ]
    && (genProduct.projectTo seamSpace "bobbin").projection.ofCell seamCell == "grosgrain"
    && (mdl.resolve seamHead).included == true
    && seamNodes == [ "seam:pewter:grosgrain" ]
    &&
      thimbles == [
        "damask"
        "pewter"
      ]
    &&
      bobbinNodes == [
        "faille"
        "grosgrain"
      ]
  );
}
