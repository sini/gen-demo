{
  title = "an `enum` redeclared across names is nixpkgs' union";
  adr = "0025 item 1, 0034, 0039, n8cpq";
  what = "`enum-redeclared-across-names-is-nixpkgs-union`: one option `weave` declared by gen `enum \"weave\" [ \"sateen\" ]`, gen `enum \"loom\" [ \"twill\" ]` and nixpkgs `enum [ \"satin\" ]`, in all six orders under `genMerge.evalModuleTree` and `lib.evalModules`, equals its nixpkgs-only twin read in nixpkgs' engine at each member, description included, where every order refused; a planted `bobbin` is refused in all twelve";
}
