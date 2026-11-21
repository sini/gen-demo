{
  title = "a collection's merge does not split a kind from its twin";
  adr = "0034 B′";
  what = "`a-collections-merge-does-not-split-a-kind-from-its-twin`: one kind declaration under schemas differing only in a kept collection's `merge`, which the kind does not define, is treated by nixpkgs' `lib.evalModules` as its twin (two constructions under one schema) is, one kept in either order, and gen's engine refuses both by name: a collection enters the separation key as the mark reads it";
}
