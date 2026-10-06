{
  title = "an untyped option merges by the default";
  adr = "0039, 0025 item 1, den-hoag-yu8sa";
  what = "`untyped-option-merges-by-the-default`: an option declared with no `type` merges as nixpkgs' `types.unspecified` does at lists, strings, bools and attrsets, so `reed` defined `\"warp\"` in two files reads `\"warpwarp\"`, where it read `\"warp\"` without a word, and `{ warp = 1; }` beside `{ weft = 2; }` reads their union, where the pair was refused as unequal; `1` beside `2` is still refused catchably, and `{ a = 1; }` beside `{ a = 2; }` is refused where nixpkgs keeps the first file's value without a word";
}
