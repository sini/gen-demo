{
  title = "a v2 type's ad-hoc check override is refused";
  adr = "0025 item 1, 0039";
  what = "`foreign-v2-check-override`: `spool` typed nixpkgs `attrsOf str // { check = isAttrs; }` is refused, where gen-merge used to accept it; a `submodule // { check = isAttrs; }`, which nixpkgs erases without a word, is enforced as a check and reads `sateen`, the value it admits (`nixpkgs-submodule-check-override` holds the rejected half); the `addCheck` spelling and the stock submodule read `sateen`; by name in `refusals` rows 79/80";
}
