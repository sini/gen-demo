# `aspect-body-key-closed` — C111, den-hoag-661s2. The corpus declares its aspect-body vocabulary
# closed (`aspect-cnf.nix`: `closedKeys`, with the four intended undeclared keys in `freeformKeys`),
# so a key at an aspect body's first level that names no class, channel or facet and is not listed
# is refused catchably, where it used to become a nested aspect: a misspelt `nixos` on `stitch`
# emptied `nixosConfigurations` at exit 0. Three readings of the corpus's own grammar: the
# misspelling is caught; a listed nested aspect (`placket`, with its own undeclared child) composes
# as a node; the correctly spelt class keeps its content. The refusal's text is read by T5 row 127.
# Below a listed key the subtree is ungated; `aspect-body-key-below-listed` pins that price.
{
  asserts,
  genAspects,
  genMerge,
}:
let
  cnf = import ../aspect-cnf.nix;
  gore =
    body:
    (genMerge.evalModuleTree { } [
      { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
      { aspects.gore = body; }
    ]).config.aspects.gore;
  misspelt = gore { nixso.boot.loader.grub.enable = false; };
  nested = gore { placket.eyelet = { }; };
  spelt = gore { nixos.boot.loader.grub.enable = false; };
in
{
  construct = [ "C111" ];
  check = asserts (
    !(builtins.tryEval (builtins.deepSeq misspelt.nixso null)).success
    && nested.placket.key == "gore/placket"
    && nested.placket.eyelet.key == "gore/placket/eyelet"
    && genAspects.hasClassContent spelt.nixos
  );
}
