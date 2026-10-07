# `tasselLoops` — nixpkgs-submodule-option-reading-its-own-registry-composes, den-hoag-gi421. A kind
# option typed by nixpkgs' `types.submodule` imports one option per registry instance; both
# constructs read the loops and the kind states no ref. Red: a ref reading that forces the nixpkgs
# submodule's own `nestedTypes` aborts uncatchably with infinite recursion, which reds the whole
# check evaluation.
{ asserts, tasselLoops }:
let
  expected = {
    loops = {
      loop-t1 = "soutache";
      loop-t2 = "russia";
    };
    refs = { };
  };
in
{
  construct = [ "nixpkgs-submodule-option-reading-its-own-registry-composes" ];
  check = asserts (tasselLoops.registry == expected && tasselLoops.sibling == expected);
}
