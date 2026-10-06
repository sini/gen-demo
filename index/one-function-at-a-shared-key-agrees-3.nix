{
  title = "one function at a shared key agrees ×3";
  adr = "0025 item 1";
  what = "`mkoptiontype-shared-key-identity`: a check-only `mkOptionType` compares each definer's own value at a shared key, so `heddle = { a = spin; }` in two files, over one binding `spin`, keeps `heddle.a` a function on Nix, Determinate and Lix, where Nix and Determinate refused and Lix kept it; `spin` passed through `specialArgs` reads the same; two closures of one lambda are still refused catchably at the read of `heddle.a`";
}
