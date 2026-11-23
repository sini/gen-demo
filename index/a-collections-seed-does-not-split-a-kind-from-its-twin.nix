{
  title = "a collection's seed does not split a kind from its twin";
  adr = "0034 B′";
  what = "`a-collections-seed-does-not-split-a-kind-from-its-twin`: one kind declaration defining a kept collection, under schemas differing only in whether that collection declares a `default` its value does not read, is treated by nixpkgs' `lib.evalModules` as its twin (two constructions under one schema) is, one kept in either order, and gen's engine refuses both by name: a collection's seed enters the separation key only as a kind's value";
}
