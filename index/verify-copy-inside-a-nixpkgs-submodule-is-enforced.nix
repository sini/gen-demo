{
  title = "a `//` copy's `verify` is enforced inside a nixpkgs submodule";
  adr = "0025 item 1, 0039, dk6zg";
  what = "`verify-copy-inside-a-nixpkgs-submodule`: `spool // { verify = …; }` rejecting `\"weft\"`, declared as an option of a nixpkgs `submodule` (alone, two deep, under nixpkgs `attrsOf`, as the member a nixpkgs `either` chooses, or below a `coercedTo`'s final `listOf`) or a tag of nixpkgs `attrTag`, refuses `\"weft\"` and reads `\"warp\"`, where gen-merge served `\"weft\"` because nixpkgs' option evaluation reads the copy's `check`, its base's; an option never read is never judged";
}
