{
  title = "an overridden container folds by its own merge";
  adr = "0039, 0025 item 1 (den-hoag-e12ro)";
  what = "`overridden-container-folds-by-its-own-merge`: gen-merge's own `evalModuleTree` over nixpkgs `lazyAttrsOf (attrsOf sub)`, its `merge` overridden to swap two keys with a `substSubModules` that forwards the override, reads the swapped value and a definition conditional on the key the swap moves as the cell's own `lib.evalModules` reference does, where the container was re-homed by its functor name, served the stock value silently and aborted uncatchably on the conditional definition";
}
