{
  title = "a derived container's verify copy evaluates its definition";
  adr = "0039, mym0d";
  what = "`derived-container-verify-copy-evaluates-its-definition`: `deriveType` over a `verify` copy of a nixpkgs `nullOr`, `attrsOf` and `either` (an `addCheck` beneath an admit-all `verify`) of a gen submodule, mounted in nixpkgs' `lib.evalModules` and in gen-merge's `evalModuleTree`, serves `{ warp = 2; }` evaluated as `{ warp = 2; weft = 0; }` and refuses `{ warp = 5; }`, which the `verify` or the check rejects; gen-merge served the definition unevaluated, because the import handed the `verify` overlay back unhomed, so the derivation folded as a leaf";
}
