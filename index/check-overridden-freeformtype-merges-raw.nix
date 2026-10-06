{
  title = "a check-overridden `freeformType` merges raw";
  adr = "0025 item 1";
  what = "`freeform-check-override-accepted`: `picks = 1` reads `{ picks = 1; }` under `freeformType` nixpkgs `attrsOf int // { check = _: false; }` (v2) and `attrs // { check = _: false; }`, as nixpkgs folds by the raw `merge`, where gen-merge refused both; the same two types at a declared option are still refused, beside the stock types reading it";
}
