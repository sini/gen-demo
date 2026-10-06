{
  title = "an `addCheck`'d nixpkgs leaf is not its base";
  adr = "0034";
  what = "`foreign-addcheck-leaf-does-not-unify`: through the hub's `modules.types.typeEq`, `addCheck str p` and `addCheck str q` compare unequal where both minted as `str` and compared equal; one binding, leaf or `listOf str`, still equals itself";
}
