{
  title = "a key reads a sibling of its own option";
  adr = "0025 item 1, 0039, den-hoag-11c5o";
  what = "`mkoptiontype-key-reads-a-sibling`: a check-only `mkOptionType` decides a shared key where it is read, so `heddle.a = config.heddle.b` in two files and `heddle.b = 1` in a third reads `{ a = 1; b = 1; }`, as nixpkgs does, where deciding every key first recursed uncatchably ×3; a disagreement at `a` leaves `b` readable and refuses `a` catchably";
}
