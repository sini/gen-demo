# `forwarded-occurrence-reaches-a-nested-receiver` — den-hoag-6md1q C5 (spec G12). damask's occurrences reach
# pewter's attrsOf-submodule receiver through the REAL `genDelivery.forward`, at `spools.<dest name>`, grouped
# at the target (one module per path). Red if `forward` is absent (gen-demo main's pins), if the group is
# wrapped per item (`A\nB\nR`) or delivered twice (`B\nA\nB\nA\nR`), if equal content collapses (`A\nR`), or if
# the receiver's own normal value stops beating the group's mkDefault.
{ asserts, forwardNested }:
{
  construct = [ "forwarded-occurrence-reaches-a-nested-receiver" ];
  check = asserts (
    forwardNested.oneOccurrence.pewter == {
      thread = "B\nA\nR";
      spindle = "receiver";
    }
    && forwardNested.oneOccurrence.check
    && forwardNested.alone.pewter.spindle == "group"
    && forwardNested.twoOccurrences.pewter.thread == "B\nA\nR"
    && forwardNested.equalContent.pewter.thread == "A\nA\nR"
  );
}
