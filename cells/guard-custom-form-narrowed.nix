# `guard-custom-form-narrowed` — C120. A custom guard form whose `eval` has a CLOSED formal set
# (`seam`'s `{ thimble }:`, no ellipsis), dispatched at a context that carries more coords than it
# declares (`bobbin` beside `thimble`). gen-aspects applies a custom form's `eval` through the same
# context door as a parametric aspect, so the extra coord never reaches it. Before that, this
# dispatch aborted `called with unexpected argument 'bobbin'`, which `tryEval` does not contain, so
# the whole check plane went down rather than this cell failing. The control is the other side of the
# same door: the context missing `thimble` is refused, catchably.
{
  asserts,
  genAspects,
}:
let
  gv = genAspects.mkGuardVocab {
    guardForms.seam = {
      eval = { thimble }: a: thimble == a.name.v;
      reads = [ [ "thimble" ] ];
    };
  };
  g = gv.guard (genAspects.pred.custom "seam" { name = "pewter"; }) { description = "seam-pewter"; };
  wide = gv.applyGuard {
    thimble = "pewter";
    bobbin = "damask";
  } g;
  missing = gv.applyGuard { bobbin = "damask"; } g;
in
{
  construct = [ "C120" ];
  check = asserts (
    wide.description == "seam-pewter" && !(builtins.tryEval (builtins.deepSeq missing null)).success
  );
}
