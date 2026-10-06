# `conditional-include-reads-the-graph` — C200, den-hoag-1wdng. A conditional include whose condition
# fires another aspect's door node through the one root table, in the same evaluation: `trim` includes
# `"trimmed"` because `hem`'s closure fires to `"hem-pewter"`, exactly as `trimControl`, whose condition
# is `true`. Firing `hem` forces no other aspect's include condition, so the program has no cycle.
# Before, the evaluation recursed infinitely.

{
  asserts,
  c200Hem,
  c200Trim,
  c200TrimControl,
}:

{
  construct = [ "conditional-include-whose-condition-reads-the-graph" ];
  check = asserts (
    c200Hem == "hem-pewter" && c200Trim == [ "trimmed" ] && c200Trim == c200TrimControl
  );
}
