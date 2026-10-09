{
  title = "refined submodule option reading its own registry composes";
  adr = "0033";
  what = "`rucheRefinedPleats`: the `passantLoops` knot with the submodule under gen-schema `refined` (an `attrsOf (refined …)` option with a defined element, a lazily refined field, and the kind's `refs`); `refined` re-enters gen-merge's `mkOptionType` as a `//` copy keeping `carries.moduleSet`, and the door leaves a record carrying a module set in gen's spelling with its self-evaluating `nestedTypes` unread (`evaluatesOwnRoles`), so every read evaluates";
}
