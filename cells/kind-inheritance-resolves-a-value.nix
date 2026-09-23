# `kind-inheritance-resolves-a-value` — C26, den-hoag-0pk67. The corpus's `dart` kind declares
# `inherits = [ "notch" ]` and no `grade` option of its own; `darts.chambray` sets only `bevel`, so
# a resolved `grade == "waxed"` on the real corpus is the relocated pass composing by NAME (ADR-0016
# ruling 7), not two defaults agreeing. A mirrored fixture with the same shape and `inherits`
# dropped shows `grade` unreachable on that arm, the check's own discriminator.
#
# C26 — a real `inherits` pair on the corpus's own kinds resolves a value.
# The stock arm reads the corpus's composed `darts.chambray`, which declares only
# `bevel`; `grade` still resolves because `dart` inherits `notch`. The
# discriminator, over the SAME option shapes built beside the corpus, drops the
# edge and shows the identical accessor is then uncatchable — `attribute 'grade'
# missing` — which is what makes the stock reading a statement about the
# inheritance and not an accident of two defaults agreeing.
{
  asserts,
  c26MirroredGrade,
  c26NoInheritHasGrade,
  genValues,
}:
{
  construct = [ "C26" ];
  check = asserts (
    genValues.darts.chambray.grade == "waxed"
    && genValues.darts.chambray.bevel == "shallow"
    && c26MirroredGrade == "waxed"
    && c26NoInheritHasGrade == false
  );
}
