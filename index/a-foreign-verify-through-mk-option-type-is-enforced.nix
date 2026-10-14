{
  title = "a foreign record's `verify` through the published `mkOptionType` is enforced";
  adr = "0025 item 1, 0039, xj4tw";
  what = "`foreign-verify-through-mk-option-type`: `mkOptionType (int // { verify })`, and the same over a keyed nixpkgs `submodule` and a `nullOr` of one, refuses the value the `verify` rejects and serves the one it admits, declared once, twice and after its uncopied base, in gen-merge's evaluation and in nixpkgs' `lib.evalModules`; declared twice inside an `either` whose other member admits the rejected value, that member serves it; gen-merge answered nixpkgs' redeclaration and its submodule fixup with the nixpkgs constructor's own rebuild, which states no `verify`, and served the rejected value silently";
}
