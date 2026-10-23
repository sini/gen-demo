{
  title = "a re-wrapped partial output reads the module arguments";
  adr = "0039, vsu8s";
  what = "`a-rewrapped-partial-output-reads-the-module-arguments`: gen-bind's partial output over a `{ host, user, ... }:` module, wrapped again so every formal is bound, reads `config`, `lib`, `options` and a caller's `specialArgs` under nixpkgs' `lib.evalModules`, the argument set nixpkgs serves the unwrapped module, where gen-bind called it with the bound `host` and `user` alone; the closed `{ host, user }:` twin is still called with its formals alone and serves them";
}
