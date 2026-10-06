# ── C20 — gen-select's product adapter wired to a REAL gen-product coordinate graph
# (den-hoag-4kh.53.52 G2/G3), not a mock: C12's own `seamSpace`/`seamCell` supply
# `coordsFor`'s real return value, so `adapters.product.mkContext` is exercised against
# real gen-product data for the first time anywhere in the swept ecosystem. The armed
# variant swaps in a deliberately under-applied `coordsFor` (mode C, den-hoag-g8lo) over
# the SAME real space, to exhibit the totality door this landing added to
# `lib/adapters/product.nix` in the same expression as the working arm.
{
  genSelect,
  seamCell,
  seamSpace,
}:
let
  c20Ctx = genSelect.adapters.product.mkContext {
    cellIds = [ seamCell ];
    coordsFor = cell: seamSpace.product.coordsOf cell;
  };
  c20ArmedCtx = genSelect.adapters.product.mkContext {
    cellIds = [ seamCell ];
    coordsFor = _cell: seamSpace.product.coordsOf; # under-applied: returns a function, not coords
  };
in
{
  inherit c20Ctx c20ArmedCtx;
}
