# `passantLoops` — submodule-option-reading-its-own-registry-composes, den-hoag-dqw5z. A kind option's
# submodule imports one option per registry instance; both constructs read the loops and the kind
# states no ref. Red: a ref reading that forces the submodule's own `nestedTypes` aborts uncatchably
# with infinite recursion, which reds the whole check evaluation.
{ asserts, passantLoops }:
let
  expected = {
    loops = {
      loop-p1 = "soutache";
      loop-p2 = "russia";
    };
    refs = { };
  };
in
{
  construct = [ "submodule-option-reading-its-own-registry-composes" ];
  check = asserts (passantLoops.registry == expected && passantLoops.sibling == expected);
}
