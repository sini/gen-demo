{
  title = "a door reads a `verify` copy on the merged value";
  adr = "0025 item 1, 0039, 5f99v";
  what = "`door-verify-copy-on-the-merged-value`: `mkOptionType (attrsOf int // { verify })`, its `verify` needing two members two modules define, serves the merged value both definitions make and refuses one the `verify` rejects, in nixpkgs' `lib.evalModules` and in gen-merge's evaluation beside its uncopied base; gen-merge read the `verify` per definition there, so each lone definition was rejected or the `verify` aborted, and the merged value was never read";
}
