{
  title = "a check-rewritten gen submodule is enforced below a union";
  adr = "0039, 25 (item 1), 59gnz (owner-ruled 2026-10-08, arm (b))";
  what = "`check-rewritten-submodule-below-a-union`: a gen `submodule` whose check is rewritten by nixpkgs `addCheck` and by the ad-hoc `// { check }`, raw and re-completed through `types.defineType` and `mkOptionType`, placed in `either`, `nullOr (either)`, `attrsOf (either)` and `either (listOf)`, serves `{ a = 2; }` and refuses `{ a = 1; }` by name, where the `mkOptionType` door refused the admitted value (\"its called `mergeDefs' does not evaluate the nested tree\")";
}
