{
  title = "refined nixpkgs submodule option reading its own registry composes";
  adr = "0014, 0025 item 1";
  what = "`rucheNixpkgsRefinedPleats`: the registry knot with a RAW nixpkgs `lib.types.submodule` under gen-schema `refined` (an `attrsOf (refined …)` option with a defined element, a lazily refined field, and the kind's `refs`); `refined` imports a foreign base through gen-merge's `mkOptionType` before its `//` copy, so the copy keeps `carries.moduleSet` and the door leaves the self-evaluating `nestedTypes` unread (`evaluatesOwnRoles`), so every read evaluates";
}
