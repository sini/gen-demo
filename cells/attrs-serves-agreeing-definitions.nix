# `attrs-serves-agreeing-definitions` — C195, den-hoag-t1j4z. Two modules setting one `attrs` key to
# the same value serve it, unioned with the other keys; with the values disagreeing, the sibling
# `weft` still reads and `warp` refuses catchably. DRIVEN RED: a fold refusing every shared key reds
# `agreeing` and `siblingOfDisagreement`; one serving the last value reds `disagreementCaught`.
{
  asserts,
  c195Agreeing,
  c195Disagreeing,
}:
{
  construct = [ "attrs-serves-a-key-its-definitions-agree-on" ];
  check = asserts (
    # agreeing
    c195Agreeing == {
      warp = "flax";
      weft = "tussah";
    }
    # siblingOfDisagreement
    && c195Disagreeing.weft == "tussah"
    # disagreementCaught
    && !(builtins.tryEval c195Disagreeing.warp).success
  );
}
