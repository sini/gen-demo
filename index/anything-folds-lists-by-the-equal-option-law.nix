{
  title = "anything folds lists by the equal-option law";
  adr = "0039, den-hoag-h76uk";
  what = "`anything-folds-lists-by-the-equal-option-law`: two equal list definitions of an `anything` option read one copy and two unequal ones are refused, as nixpkgs' `anything` folds them (`mergeEqualOption`), where gen concatenated them; a freeform `attrsOf anything` key written `mkOverride 40 [ 1 ]` and `mkOverride 40 [ 2 ]` is refused; a nested `{ a = [ 1 ]; }` written twice reads `{ a = [ 1 ]; }`; a guard carrier's `includes` written by two firing definitions still reads both (T4's declared `listOf`); `raw` is the control";
}
