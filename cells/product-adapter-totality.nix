# `product-adapter-totality` — C20, den-hoag-4kh.53.52. Two arms, one real `gen-product` coordinate
# graph (C12's own `seamSpace`/`seamCell`, not a mock): the working arm's real `coordsOf` flows
# through `adapters.product.mkContext`'s `coordsFor` unchanged; the armed arm swaps in the SAME
# `coordsOf`, deliberately under-applied by one argument, and now refuses (named throw,
# `tryEval`-caught) instead of writing a residual function into `__coords` that every downstream
# coord-selector match would have read as a silent, wrong `false`.
#
# C20 — gen-select's product adapter, real coordsOf data (den-hoag-4kh.53.52).
# RED (pre-landing): a malformed `coordsFor`'s result wrote straight into `__coords`
# and every coord-selector match against it read a plausible, silent, WRONG `false`
# — never a refusal (`lib/adapters/product.nix` had no door at all). GREEN: the same
# malformed `coordsFor` is now caught at construction, before any match runs.
{
  asserts,
  c20ArmedCtx,
  c20Ctx,
  seamCell,
  seamSpace,
}:
{
  construct = [ "C20" ];
  check = asserts (
    # the working arm: real coordsOf flows through the adapter unchanged.
    (c20Ctx.data seamCell).__coords == seamSpace.product.coordsOf seamCell
    # the armed arm: the SAME real space, deliberately under-applied `coordsFor`
    # (mode C, den-hoag-g8lo), now refuses (named throw, `tryEval`-caught) instead
    # of writing a residual function into `__coords`.
    && !(builtins.tryEval (builtins.deepSeq (c20ArmedCtx.data seamCell).__coords true)).success
  );
}
