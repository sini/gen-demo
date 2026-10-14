{
  title = "a redeclared gen container of a foreign submodule keeps a caller's check";
  adr = "0025 item 1, 0039, jyisy";
  what = "`caller-check-residue-re-doored`: `defineType (addCheck (nullOr skein) notTwoWarp)`, `skein` a nixpkgs `submodule` with a `key`, declared twice and after an unchecked `nullOr skein`, mounted in nixpkgs' `lib.evalModules`, refuses `{ warp = 2; }` and serves `{ warp = 1; }`; gen-merge served `{ warp = 2; }`, because the redeclaration's join carried the check onto its `check`, marked coherent, and not onto its `merge.v2` headError, which is all nixpkgs reads";
}
