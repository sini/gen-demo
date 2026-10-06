{
  title = "a nullable refuses null beside a value";
  adr = "0025 item 1, azdne";
  what = "`nullable-refuses-null-beside-a-value`: a gen-merge `nullOr int` defined null in one module and `5` in another is refused catchably, the answer nixpkgs' own `nullOr int` gives on the same two definitions (\"defined both null and not null\"), where gen-merge dropped the null and served `5`; every definition null, a null under `mkDefault` and a null under `mkIf false`, equal on both engines, are the controls";
}
