{
  title = "a verify copy of a gen container chain over leaves judges its merged value, and each element still takes the passes it needs";
  adr = "0032, 0039 (den-hoag-c922w)";
  what = "`verify-copy-over-a-leaf-container-chain`: a gen `attrsOf (listOf (nullOr int))` copied with a `verify`, used raw as an option's type, serves a split whole and refuses by name a value its `verify` rejects; an element's `mkIf false` and `mkForce`, and a key's `mkMerge`, `mkForce` and `mkAfter`, are resolved at every level, while a definition list carrying no property folds without the three passes, which map it to itself";
}
