# `restricted-product-membership-index` — C59, den-hoag-bksu. The restricted product's member set,
# its addressing (a member is a cell, a non-member is refused), and the membership index its
# restriction record carries as a field: one attribute per declared pair, keyed by the cellId codec.
# Red when the index is absent from the record (a gen-product before the index), or is a key list
# rather than an attrset.
{
  asserts,
  genProduct,
  threading,
  threadingSpace,
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
    # den-hoag-4kh.53.53: a fiber of the restricted product keeps its members and its refusal, and
    # no published record carries an undeclared `__` key (`__cells` is gen-product's one stated one).
    && map (c: c.thread) (genProduct.cells (genProduct.fiber threading "needle" "sharp")) == [ "silk" ]
    && !(builtins.tryEval (
      genProduct.cell (genProduct.fiber threading "needle" "sharp") { thread = "linen"; }
    )).success
    &&
      map (pg: builtins.filter (k: builtins.substring 0 2 k == "__") (builtins.attrNames pg)) [
        threadingSpace
        threading
        (genProduct.fiber threading "needle" "sharp")
      ] == [
        [ "__cells" ]
        [ "__cells" ]
        [ "__cells" ]
      ]
  );
}
