# `layered-fold-nested` — C13. `foldNestedLayers` keeps a literal dotted key and the nested
# path it spells as two leaves, and over a shape conflict the last layer providing a path wins:
# a scalar resets the subtree before it, and a later subtree merges onto the reset.
{
  asserts,
  dottedFold,
  shapeConflictFold,
  shapeResetFold,
}:
{
  construct = [ "C13" ];
  check = asserts (
    dottedFold == {
      "a.b" = "literal";
      a.b = "nested";
    }
    && shapeConflictFold == { a.b = 5; }
    && shapeResetFold == { a.b.y = 9; }
  );
}
