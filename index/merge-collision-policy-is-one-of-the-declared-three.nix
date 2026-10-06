{
  title = "a merge-collision policy is one of the declared three";
  adr = "0025 item 1, d65u4";
  what = "`merge-validator-result-is-a-declared-policy`: gen-bind's `mkMergeValidator` reads the policy for a colliding `spool` binding; `system-wins` is read as itself (the control), and a misspelled `sytem-wins` is refused catchably, where gen-bind read it as `bind-wins` and warned that the module-system value was shadowed";
}
