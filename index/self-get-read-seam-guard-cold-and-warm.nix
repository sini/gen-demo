{
  title = "the `self.get` read seam guard, cold and warm";
  adr = "0008";
  what = "`read-seam-guard-warm`: `kiln` reads `quarry`'s `clay` through `self.get`; under a declared relation the cold fold reads `101` and `genMemo.warmOverride` over gen-scope's `evalWarm`, after an edit to `quarry`, reads `109` as a fresh cold fold does; under the empty relation the cold read and both warm reads (`kiln` edited, `quarry` edited) are refused, and gen-scope's reason names `kiln`, `clay`, `quarry` and the relation `[]`";
}
