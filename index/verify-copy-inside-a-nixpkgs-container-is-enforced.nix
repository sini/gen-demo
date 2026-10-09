{
  title = "a `//` copy's `verify` is enforced inside a nixpkgs container";
  adr = "0025 item 1, 0039, dyww5";
  what = "`verify-copy-inside-a-nixpkgs-container`: `spool // { verify = …; }` rejecting `\"weft\"`, declared alone as nixpkgs `listOf`, refuses `[ \"weft\" ]` and reads `[ \"warp\" ]`, where gen-merge served `[ \"weft\" ]` because nixpkgs' fold reads the copy's `check`, its base's; under gen-merge's own `listOf` and bare it refuses `\"weft\"` as before";
}
