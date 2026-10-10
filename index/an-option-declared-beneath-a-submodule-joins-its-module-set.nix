{
  title = "an option declared beneath a submodule joins its module set";
  adr = "0025 item 1, 0039, 3pnlv";
  what = "`option-declared-beneath-a-submodule`: `nix.settings` declared as a freeform `submodule` with one typed option in one module and `nix.settings.sandbox` declared beneath it in another, the NixOS shape, reads under `genMerge.evalModuleTree` the set `lib.evalModules` reads, in both declaration orders and under gen-merge's `submodule` and nixpkgs', with `lib.evalModules` as the live arm; the same beneath declaration under an `int` leaf stays refused by both engines, where before gen-merge refused every row as a leaf/group collision";
}
