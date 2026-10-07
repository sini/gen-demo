# `merge-validator-result-is-a-declared-policy` — C158, den-hoag-d65u4. gen-bind's merge-collision
# validator reads a policy for each colliding binding, and only three are declared. `system-wins` is
# read as itself (the control); a misspelled `sytem-wins` is refused catchably, where gen-bind read
# it as `bind-wins` and warned that the module-system value was shadowed.

{
  asserts,
  lib,
  policyAtSpoolCollision,
}:

{
  construct = [ "merge-collision-policy-is-one-of-the-declared-three" ];
  check = asserts (
    map (lib.hasPrefix "gen-bind: binding 'spool' collision — system-wins, binding value dropped") (
      policyAtSpoolCollision "system-wins"
    ) == [ true ]
    && !(builtins.tryEval (builtins.deepSeq (policyAtSpoolCollision "sytem-wins") null)).success
  );
}
