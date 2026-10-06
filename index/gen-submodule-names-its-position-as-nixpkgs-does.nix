{
  title = "a gen submodule names its position as nixpkgs does";
  adr = "0025 item 1, fpxsd";
  what = "`submodule-names-its-position`: a gen `submodule` `bobbin` whose module reads `name`, under gen `attrsOf`, reads the attribute name `warp`; a module's `mkForce` on `_module.args.name` wins; a caller's `name` handed through `withArgs` outranks the `mkForce`; and its docs read `‹name›`, each equal to nixpkgs' `submoduleWith` on the same construction, where gen-merge served `warp` over the `mkForce`, refused the caller's `name` at `withArgs`, and read the docs' prefix step";
}
