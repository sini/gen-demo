{
  title = "a nixpkgs `addCheck` around a gen `enum` is redeclared the same in every order";
  adr = "0025 item 1, 0034, 0039, 7kj5s";
  what = "`wrapped-enum-redeclared-in-every-order`: one option `weave` declared by a nixpkgs `addCheck` around gen `enum \"weave\" [ \"sateen\" \"twill\" ]` rejecting `sateen`, nixpkgs `enum [ \"twill\" \"satin\" ]` and gen `enum \"loom\" [ \"satin\" ]`, in all six orders under `genMerge.evalModuleTree`, serves `twill` and `satin` as its nixpkgs-only twin does in `lib.evalModules`, where five orders refused them by name; `sateen` and a planted `bobbin` are refused in all six";
}
