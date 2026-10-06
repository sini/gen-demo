{
  title = "a module reads its `_module` view as nixpkgs does";
  adr = "0025 item 1, eoka4";
  what = "`module-reads-its-module-view`: a loom's module reads `config._module`'s keys, `args`, `check`, `freeformType` and `specialArgs`, whether or not any module sets `_module.args`; its `check`, `false` under a caller `check = false`; its `freeformType`, `null` and then the resolved type; its `specialArgs`, the caller's `shuttle`, mapped by a re-declared `apply`; and a gen `submodule` child reads its own `specialArgs`, each equal to nixpkgs' own `lib.evalModules` over the same loom, where gen-merge's module aborted on `attribute '_module' missing` and refused the `apply` by name";
}
