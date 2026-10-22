{
  title = "a fully-bound open module reads the module arguments";
  adr = "0039, 4uta7";
  what = "`a-fully-bound-open-module-reads-the-module-arguments`: a `{ host, ... }:` module whose every named formal gen-bind binds reads `config`, `lib`, `options` and a caller's `specialArgs` under nixpkgs' `lib.evalModules`, the argument set nixpkgs serves the unwrapped module, where gen-bind called it with the bound `host` alone; the closed `{ host }:` twin is still called with `host` alone and serves it";
}
