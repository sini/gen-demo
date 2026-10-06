{
  title = "a foreign type is not the type it is named after";
  adr = "0034";
  what = "`foreign-same-name-type-does-not-unify`: through the hub's `modules.types.typeEq`, an `addCheck`'d `int` installed by `lib.extend`, a gen-merge `mkOptionType` named `int`, and `nonEmptyListOf str` compare unequal to the type whose name they carry; a type still equals itself, a shared binding and its `// { }` copy";
}
