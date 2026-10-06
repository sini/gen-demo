{
  title = "one `lib` passed through `withArgs` twice merges ×3";
  adr = "0034, 0025 item 1";
  what = "`submodule-withargs-shared-lib`: the flake's own nixpkgs `lib`, reaching two declaring modules as a `specialArgs` formal, is handed by each to `(submodule [ reads ]).withArgs`, and the submodule reads `LIB-ARRIVED` on Nix, Determinate and Lix, where Nix and Determinate threw on a removed nixpkgs alias the comparison walked; `lib` against `builtins` is still refused catchably";
}
