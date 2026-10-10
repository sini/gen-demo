{
  title = "a nixpkgs submodule's ad-hoc check override is enforced";
  adr = "0039, ukitj";
  what = "`nixpkgs-submodule-check-override`: a nixpkgs `submodule` given an ad-hoc `// { check }` override, raw and through gen-merge's published `types.defineType`, declared alone, twice, beside the plain submodule in both orders, and as a `listOf` and an `attrsOf` element, reads the value the override admits and refuses the value it rejects, where nixpkgs silently serves both and gen-merge refused both";
}
