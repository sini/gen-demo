# `shared-evaluation-parity` — C186, den-hoag-htfv3 (D5). Shared evaluation realizes exactly what the
# desugared cold arm does: each parametric aspect a loom lists, applied at that loom's tuple and
# named in its place as a static aspect. The instance-key merge (every loom reading `godet`'s
# `tuck`) is the defect parity exists to catch, and it moves `jabot` and `ruffle`.
{
  asserts,
  sharedEvalRealized,
  sharedEvalColdRealized,
  sharedEvalMergedRealized,
}:
{
  construct = [ "C186" ];
  check = asserts (
    sharedEvalRealized == sharedEvalColdRealized && sharedEvalMergedRealized != sharedEvalColdRealized
  );
}
