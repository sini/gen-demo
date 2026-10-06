{
  title = "`foldLayers`";
  adr = "0017";
  what = "`genAlgebra.record.foldLayers`, all three strategies plus the default channel in one call; `foldNestedLayers` over a literal dotted key `\"a.b\"` and the nested path `a.b` it spells keeps both as two leaves; over a shape conflict the last layer providing `a.b` wins, a scalar resetting the subtree before it and a later subtree merging onto the reset";
}
