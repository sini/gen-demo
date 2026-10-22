{
  title = "declared options serve a nixpkgs declaration read";
  adr = "0033, 0039, qqywn";
  what = "`declared-options-serve-a-nixpkgs-declaration-read`: `declaredOptions` over a renamed option, a declaration built from a module argument, one whose presence reads `config`, an untyped declaration and `_module.specialArgs` reads each leaf as nixpkgs' `.options` does; the same presence read with a gen type is refused catchably, and a declaration reading nothing is the control";
}
