{
  title = "a gen module tree names its position as nixpkgs does";
  adr = "0025 item 1, xy2r0";
  what = "`tree-names-its-position`: a gen module tree `spool` whose module reads `name`, mounted under `attrsOf` in nixpkgs' own `lib.evalModules` and in gen-merge's `evalModuleTree`, reads the attribute name `warp`, its docs read `‹name›`, and a module's `mkForce` on `_module.args.name` wins, each equal to nixpkgs over its own `(lib.evalModules …).type`, where gen-merge refused the module by name (`` module argument `name' is not defined ``)";
}
