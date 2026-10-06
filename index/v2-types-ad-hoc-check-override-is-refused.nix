{
  title = "a v2 type's ad-hoc check override is refused";
  adr = "0025 item 1";
  what = "`foreign-v2-check-override`: `spool` typed nixpkgs `attrsOf str // { check = isAttrs; }`, and a `submodule // { check = isAttrs; }`, are refused, where gen-merge used to accept the first and nixpkgs erases the second without a word; the `addCheck` spelling and the stock submodule read `sateen`; by name in `refusals` rows 79/80";
}
