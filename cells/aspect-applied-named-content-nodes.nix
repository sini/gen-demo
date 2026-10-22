# `named-content-in-an-applied-body-is-one-node` — aspect-applied-named-content-nodes,
# den-hoag-named-include-instance-bodies-sfkyy. `binding`, included by the static `border` and in the
# applied bodies of `quilt` and `sash`, is the one node `graphFacts` publishes for `border`: `coverlet`,
# reaching all three, receives it and `binding-inl` once, and `pillow` names the same id; the factory
# `tape` in two applied bodies gives two classes, each its own content. Ids are asserted by their
# structure (the `name` position is a store path, which moves with the corpus source). Red where an
# applied body keys its own copy: `coverlet` receives `binding` three times, under
# `aspect-instance:<iid>/includes/0` ids.
{
  asserts,
  appliedNamedFacts,
  appliedNamedIds,
  appliedNamedStitches,
}:
let
  f = appliedNamedFacts;
  # Total over the red arm: every read below answers rather than aborts.
  at = l: i: if builtins.length l > i then builtins.elemAt l i else "<none>";
  bindingId = at f.includesOf.border 0;
  tapes =
    h: builtins.filter (n: builtins.match "@/includes/tape@[^/]*/.+" n != null) (appliedNamedIds h);
in
{
  construct = [ "named-content-in-an-applied-body-is-one-node" ];
  check = asserts (
    builtins.match "@/includes/binding@[^/]*" bindingId != null
    && builtins.elem bindingId (appliedNamedIds "coverlet")
    && builtins.elem bindingId (appliedNamedIds "pillow")
    && builtins.elem "${bindingId}/includes/0" (appliedNamedIds "pillow")
    && builtins.length (tapes "coverlet") == 2
    && at (tapes "coverlet") 0 != at (tapes "coverlet") 1
    &&
      appliedNamedStitches == {
        coverlet = [
          "border"
          "quilt"
          "sash"
          "binding"
          "braid"
          "ribbon"
          "binding-inl"
        ];
        pillow = [
          "quilt"
          "binding"
          "braid"
          "binding-inl"
        ];
      }
  );
}
