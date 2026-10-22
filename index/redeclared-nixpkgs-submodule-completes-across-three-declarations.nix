{
  title = "a redeclared nixpkgs submodule completes across three declarations";
  adr = "0014, 0033, 0034";
  what = "`foreign-submodule-redeclared-thrice-cross-defined`: a stock nixpkgs `attrsOf (submodule …)` option `accts` declared three times, `base` declared in the first, only defined (`mkDefault 5`) in the second and a sibling `b` declared in the third, resolves to `{ base = 5; b = 0; }` under gen-merge as under nixpkgs, where gen-merge's one-value comparison read the partial join's own evaluation and refused \"option `base' does not exist\"; a sub-option no declaration declares refuses on both engines";
}
