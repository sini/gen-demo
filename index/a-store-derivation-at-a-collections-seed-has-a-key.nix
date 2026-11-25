{
  title = "a store derivation at a collection's seed has a key";
  adr = "0025";
  what = "`a-store-derivation-at-a-collections-seed-has-a-key`: a kind holding nixpkgs' `lib.toDerivation` value at its kept collection's seed (two distinct values, at the top, in a list and in a record) has a foreign key under pure evaluation without forcing `outPath`, and nixpkgs' `lib.evalModules` keeps one of a twin by it";
}
