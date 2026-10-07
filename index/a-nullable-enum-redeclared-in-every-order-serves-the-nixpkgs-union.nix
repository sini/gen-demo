{
  title = "a nullable `enum` redeclared in every order serves nixpkgs' union";
  adr = "0025 item 1, 0039, kbiu2";
  what = "`nullable-enum-redeclared-in-every-order`: one option `loom` declared three times by nixpkgs `nullOr (enum [ … ])` over `warp`, `weft` and `selvage`, in all six orders under `genMerge.evalModuleTree` and `lib.evalModules`, serves each member and `null` as `lib.evalModules` does, where gen's engine refused every member; a planted `felt` is refused in all twelve, and a nixpkgs `addCheck` under the `nullOr` keeps `warp` refused in gen's engine in both orders";
}
