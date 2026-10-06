# `include-closure-delivers-split` — C113, den-hoag-5q36i. `probe` lists only `interfacing`, which
# has no `nixos` of its own in `corpus.nix`, includes `selvage`, and has a second definition that is
# a `{ config, ... }:` function (`gen-modules/interfacing.nix`). It receives exactly two `nixos`
# modules: `selvage`'s, through the include, and the function part's. Before delivery followed
# includes it received none; a walk over names alone gets one, losing the function part. `control`,
# listing `selvage` directly, receives its one module, which shows the predicate reads real content.
{
  asserts,
  includeProjection,
}:
let
  nodes = includeProjection.nodes;
in
{
  construct = [ "node-receives-what-its-aspects-include" ];
  check = asserts (
    builtins.attrNames nodes.probe.classes == [ "nixos" ]
    && builtins.length nodes.probe.classes.nixos == 2
    && builtins.attrNames nodes.control.classes == [ "nixos" ]
    && builtins.length nodes.control.classes.nixos == 1
  );
}
