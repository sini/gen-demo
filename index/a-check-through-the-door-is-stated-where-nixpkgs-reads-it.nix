{
  title = "a check through the door is stated where nixpkgs reads it";
  adr = "0025 item 1, 0039, qb4hj";
  what = "`door-addcheck-over-a-rehomed-container`: `mkOptionType` over nixpkgs `addCheck` of `either bolt str`, declared alone, and of `nullOr bolt`, as a member of a nixpkgs `either`, `bolt` a gen `submodule`, mounted in nixpkgs' `lib.evalModules`, refuses `{ warp = 5; }`, which the check rejects, and serves `{ warp = 2; }`, `\"sateen\"` and `null`; gen-merge served `{ warp = 5; }`, because nixpkgs reads the re-homed container's `merge.v2` `headError` and the check rode on `check` alone";
}
