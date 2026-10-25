{
  title = "a check held in a container through mkOptionType is enforced";
  adr = "0039, 8uwxu";
  what = "`held-check-through-mk-option-type`: an `addCheck`'d leaf held at a nixpkgs `attrTag` tag, `listOf` element or `attrsOf` element, through gen-merge's `mkOptionType`, declared alone, twice and beside the unchecked container in either order, and a gen `int`'s `verify` copy below a nixpkgs `attrsOf`, `lazyAttrsOf`, `listOf`, `nullOr` or `either` through `mkOptionType` and `deriveType`, reads the value the check admits as nixpkgs reads it and refuses the value it rejects, where gen-merge served the rejected value silently and refused the admitted one through `deriveType`";
}
