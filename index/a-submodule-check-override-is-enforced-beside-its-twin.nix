{
  title = "a check override of a gen submodule is enforced beside its twin";
  adr = "0039, 8ip0d, 59gnz (owner-ruled 2026-10-08, arm (b))";
  what = "`submodule-check-override-redeclared`: a gen `submodule` whose check is overridden by nixpkgs `addCheck` and by the ad-hoc `// { check }`, raw and re-completed through `types.defineType` and `mkOptionType`, redeclared beside the plain submodule in either order, serves `{ a = 2; }` and refuses `{ a = 1; }` by name, where the raw redeclaration was refused whole and the re-completed override's check was dropped";
}
