{
  title = "a cross-instance nixpkgs type decides";
  adr = "0034, 0025 item 1";
  what = "`foreign-type-cross-instance-decides`: through the hub's `modules.types.typeEq`, `port`, `ints.between`, `nonEmptyStr`, `addCheck str` and `listOf port` from two nixpkgs lib instances compare unequal where the record `==` overflowed, and two records sharing every closure still separate on `description`";
}
