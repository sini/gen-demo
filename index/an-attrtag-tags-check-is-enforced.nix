{
  title = "a nixpkgs attrTag tag's check is enforced";
  adr = "0039, 8pjrq";
  what = "`attrtag-tag-check`: a nixpkgs `attrTag` whose tag is an `addCheck`'d or ad-hoc-overridden nixpkgs `submodule`, or an `addCheck`'d leaf, raw and through gen-merge's `types.defineType` and `mkOptionType`, declared alone, twice, beside the plain tag in both orders, below a `listOf` and a gen `attrsOf`, reads the value the check admits as nixpkgs reads it and refuses the value it rejects, where gen-merge served the rejected value silently";
}
