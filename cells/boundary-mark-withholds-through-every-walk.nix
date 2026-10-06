# `boundary-mark-withholds-through-every-walk` — C190, den-hoag-4or0a U1. `selvage` carries a mark
# admitting no label, so the `parent` edge to `bolt` and the `imports` edge to `warp` are withheld,
# and every walk from it answers what `resolve` answers: nothing inherited, nothing collected.
# `weft`, unsealed, reads both through the same walks.
{
  asserts,
  boundaryWalks,
}:
{
  construct = [ "boundary-mark-withholds-through-every-walk" ];
  check = asserts (
    boundaryWalks "selvage" == {
      inherited = null;
      all = [ ];
      set = [ ];
      ancestors = [ ];
      neron = [ ];
    }
    &&
      boundaryWalks "weft" == {
        inherited = "napped";
        all = [ "napped" ];
        set = [ "napped" ];
        ancestors = [ "napped" ];
        neron = [
          "combed"
          "napped"
        ];
      }
  );
}
