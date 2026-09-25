# `layered-fold-nested` — C13. `foldNestedLayers` keeps a literal dotted key and the nested
# path it spells as two leaves.
{ asserts, dottedFold }:
{
  construct = [ "C13" ];
  check = asserts (
    dottedFold == {
      "a.b" = "literal";
      a.b = "nested";
    }
  );
}
