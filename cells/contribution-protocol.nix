# `contribution-protocol` — C8. Three contributions unioned; the node set is fixed under
# permutation, the positionally-folded `spool` is not.
#
# C8 — the contribution protocol: shape unions commutatively while content folds
# by positional authority. Permuting `overlay` to the front is the discriminator: the
# node SET stays fixed, the folded `spool` does not.
{
  asserts,
  c8Assembled,
  c8Permuted,
  c8Unioned,
}:
{
  construct = [ "C8" ];
  check = asserts (
    builtins.attrNames c8Assembled.nodes == [
      "damask"
      "faille"
      "grosgrain"
      "pewter"
    ]
    &&
      c8Assembled.nodeOrder == [
        "pewter"
        "damask"
        "grosgrain"
        "faille"
      ]
    &&
      c8Unioned.decls.pewter == {
        aspects = [ "stitch" ];
        spool = "gros-de-tours";
        tacked = true;
      }
    &&
      c8Permuted.decls.pewter == {
        aspects = [ "stitch" ];
        spool = "linen";
        tacked = true;
      }
    && map (g: g.label) c8Unioned.edgeGraphs == [ "tacks" ]
  );
}
