{
  title = "a foreign `check` stated on a descriptor through `defineType` is enforced";
  adr = "0025 item 1, zdp46";
  what = "`foreign-check-through-define-type`: a descriptor stating nixpkgs' `check` beside gen-merge's own words (alone, or with `admits`, `verify` or `mergeDefs`), passed through gen-merge's published `types.defineType`, refuses a value only the check rejects and serves one every predicate admits, declared once and twice in gen-merge's evaluation and in nixpkgs' own `evalModules`, and beside a `verify` an `either` with `int` serves the rejected value by `int`; a descriptor carrying nixpkgs' `listOf int` fold with a `check` and a `verify` serves `[ 1 ]` and refuses `[ 1 2 3 ]` and `[ 9 ]`, once and twice, in both evaluations; gen-merge derived the door's `check` from `verify` or `admits` alone, fell back to `_: true`, and served the rejected value silently";
}
