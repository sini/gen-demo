# `contract-check-result-is-a-boolean` — C155, den-hoag-5rz5r. gen-bind's `contract` reads its `check`'s
# result as a Boolean: a check answering `true` serves `selvage`, and one answering the string `"yes"` is
# refused catchably, where gen-bind aborted uncatchably with `expected a Boolean but found a string`.
# The Boolean check is the control.

{ asserts, edgeVerdict }:

{
  construct = [ "C155" ];
  check = asserts (
    edgeVerdict (edge: edge == "selvage") == "selvage"
    && !(builtins.tryEval (edgeVerdict (_: "yes"))).success
  );
}
