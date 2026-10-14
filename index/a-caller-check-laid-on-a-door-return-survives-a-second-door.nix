{
  title = "a caller's check laid on a door's return survives a second door";
  adr = "0025 item 1, 0039, 1b55t";
  what = "`caller-check-on-a-door-return-re-doored`: `mkOptionType (addCheck (mkOptionType (addCheck int below10)) notFive)` declared twice, and `defineType` and `deriveType` over `addCheck (mkOptionType (addCheck (nullOr bolt) notTwo)) notFiveWarp`, `bolt` a gen `submodule`, declared once, each mounted in nixpkgs' `lib.evalModules`, refuse `5` and `{ warp = 5; }`, which only the laid check rejects, and `20` and `{ warp = 2; }`, which the first check rejects, and serve `3` and `{ warp = 1; }`; gen-merge served the values the laid check rejects, because the return's rebuilds and the gen data the second door completes from were closed over the first check only and rode into the caller's `addCheck` copy";
}
