{
  title = "a check-only `mkOptionType` merges by the default";
  adr = "0025 item 1";
  what = "`mkoptiontype-default-merge`: a type stating `name` and `check` and no fold merges as nixpkgs' constructor default does, so `heddle` defined `[ \"warp\" ]` and `[ \"weft\" ]` in two files reads `[ \"weft\" \"warp\" ]`, where the pair was refused as unequal; `1` beside `2` is still refused catchably, and `{ a = 1; }` beside `{ a = 2; }` is refused where nixpkgs keeps the first file's value without a word";
}
