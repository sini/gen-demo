{
  title = "a gen container crosses the mkOptionType door as itself";
  adr = "0039 serve half, 0034, we9fu";
  what = "`gen-container-crosses-the-door-as-itself`: gen's `nullOr` and `attrsOf` over a gen `submodule`, and the door handed its own output, read through gen-merge's `mkOptionType` what nixpkgs' `lib.evalModules` reads on the same record, where the door refused them at construction; a copy whose `check` rejects `a = 1` keeps it through the door, so the planted definition is refused catchably";
}
