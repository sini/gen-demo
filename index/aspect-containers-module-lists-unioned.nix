{
  title = "an aspect container's module lists, unioned";
  adr = "0034, den-hoag-a0gc";
  what = "`aspect-module-lists-concatenate`: two declarations of the aspect container over `aspect-cnf.nix`, one adding `baize` through `aspectModules` and `boucle` through `metaModules`, the other `chenille`; `stitch` reads all three in either order, as nixpkgs concatenates a submodule's `modules`, the second declaration alone has no `baize`, and a declaration differing at `closedKeys` is still refused catchably";
}
