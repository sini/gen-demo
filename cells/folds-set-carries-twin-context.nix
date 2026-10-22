# `folds-set-carries-twin-context` — den-hoag-izo7a. `folds.set` keeps the first occurrence of each
# `==` class in pinned order, `[ "b" "a" "b" "c" "a" ]` to `[ "b" "a" "c" ]`, and the kept string
# carries BOTH twins' store contexts: two strings equal under `==` (both "x"), each built from its
# own `toFile` path, collapse to one string holding 2 paths.
#
# Red before gen-scope had the fold: `folds ? set` was false. Live control: nixpkgs' `unique` on
# the same twins keeps one context, `[ 1 ]`, which is the quotient rule's violation.
{
  asserts,
  genScope,
  lib,
}:
{
  construct = [ "a-set-fold-keeps-its-twins-store-context" ];
  check = asserts (
    let
      inherit (genScope) folds;
      twin = name: builtins.substring 0 0 (builtins.toFile name name) + "x";
      twins = [
        (twin "izo7a-a")
        (twin "izo7a-b")
      ];
      # Each fragment is a contributor edge, `{ site; value; }` (gen-scope's fold contract).
      edges =
        vs:
        builtins.genList (i: {
          site = "fragment ${toString i}";
          value = builtins.elemAt vs i;
        }) (builtins.length vs);
      contexts = map (s: builtins.length (builtins.attrNames (builtins.getContext s)));
    in
    folds.set "k" (edges [
      "b"
      "a"
      "b"
      "c"
      "a"
    ]) == [
      "b"
      "a"
      "c"
    ]
    && contexts (folds.set "k" (edges twins)) == [ 2 ]
    && contexts (lib.unique twins) == [ 1 ]
  );
}
