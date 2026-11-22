{
  title = "a kind's reference key splits in nixpkgs exactly where its mark splits";
  adr = "0034 (B′), 0012";
  what = "`a-kind-key-splits-in-nixpkgs-where-its-mark-splits`: one declaration literal under two schemas differing in their mixins, a function base, a sealed keySemantics leaf, an open config path, or (agreeing marks) the order of two imports keeps two constructions in nixpkgs' `lib.evalModules` where the marks differ and one where they agree; the first four kept one and the last kept two";
}
