# `restricted-product-membership-index` — C59, den-hoag-bksu. The restricted product's member set,
# its addressing (a member is a cell, a non-member is refused), and the membership index its
# restriction record carries as a field: one attribute per declared pair, keyed by the cellId codec.
# Red when the index is absent from the record (a gen-product before the index), or is a key list
# rather than an attrset.
{
  asserts,
  genProduct,
  threading,
}:
{
  construct = [ "C59" ];
  check = asserts (
    map (c: "${c.needle}*${c.thread}") (genProduct.cells threading) == [
      "sharp*silk"
      "betweens*linen"
    ]
    && (builtins.tryEval (
      genProduct.cell threading {
        needle = "sharp";
        thread = "silk";
      }
    )).success
    && !(builtins.tryEval (
      genProduct.cell threading {
        needle = "sharp";
        thread = "linen";
      }
    )).success
    && threading.product.restriction.cellIndex == null
    &&
      map builtins.attrNames threading.product.restriction.relationIndexes == [
        [
          (builtins.toJSON [
            "betweens"
            "linen"
          ])
          (builtins.toJSON [
            "sharp"
            "silk"
          ])
        ]
      ]
  );
}
