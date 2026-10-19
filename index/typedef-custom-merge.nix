{
  title = "a typedef states its own merge";
  adr = "0011, den-hoag-6orb8";
  what = "`typedef-custom-merge`: `typedef { merge = sum; } \"tally\" isInt` folds two definitions to 5 in gen-merge and mounted in nixpkgs, as `mkOptionType` with the same `merge` does; a string definition is refused before the fold and a `merge` returning a string after it, in both engines; one `merge` binding declared twice folds, two separately written ones are refused, and two typedefs over one registered `merge` term fold; the positional form and an unknown option are refused";
}
