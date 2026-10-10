{
  title = "attrListOf entries over a gen element each read their own tree";
  adr = "0039, lif3n";
  what = "`attr-list-entries`: gen-merge's own `evalModuleTree` over nixpkgs `attrListOf` of a gen submodule, of a gen `either` over it and of a gen `attrsOf` over it, defined `p`, `q` and `mkMerge [ r s ]` across three modules, reads each entry's own tags in nixpkgs' order `r s q p`, where every entry read the last one's (`r r r r`): each entry is keyed at its own position of the one evaluation";
}
