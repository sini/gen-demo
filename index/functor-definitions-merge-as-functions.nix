{
  title = "functor definitions merge as functions";
  adr = "0025 item 1, 1ypox";
  what = "`functor-definitions-merge-as-functions`: two nixpkgs `setFunctionArgs` wrappers defined at one position are a function to both `lib.mergeDefaultOption` and gen-merge's `mergeDefaultOption`, and gen-merge's applied to `1` gives `[ 1 2 ]`, where gen-merge `//`-folded the two wrappers and kept only the last; a check-only `mkOptionType` refuses one wrapper written twice as it refuses one lambda written twice; a wrapper beside a plain attrset merges as an attrset on both engines, the control";
}
