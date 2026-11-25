{
  title = "a derivation in a kept collection has no identity";
  adr = "0034";
  what = "`a-derivation-in-a-kept-collection-has-no-identity`: nixpkgs' `lib.toDerivation` value (`type = \"derivation\"` with `outPath`, no `drvPath`) is refused by the mint without forcing `outPath`; a kind holding it in a kept collection, at the seed and away from it, keeps a mark with the value sealed, and away from the seed nixpkgs' `lib.evalModules` keeps one of a twin";
}
