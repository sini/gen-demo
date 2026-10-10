{
  title = "a module reads its engine's `_module` option records as nixpkgs does";
  adr = "0025 item 1, 0039, a67l3";
  what = "`module-reads-its-engine-option-records`: a loom's module reads its own `options._module` records, `args`, `check`, `freeformType` and `specialArgs`: their types (`lazyAttrsOf`, `bool`, `nullOr` over `optionType`, `unspecified`), whether each is defined, `check`'s value, the type two `attrsOf int` freeform definitions merge to, and the caller's `shuttle`; an untyped option's record states `unspecified`, and a gen `submodule` child reads its own `specialArgs` record, each equal to nixpkgs' own `lib.evalModules` over the same loom, where gen-merge's module aborted on `attribute '_module' missing` and the untyped record on `attribute 'type' missing`";
}
