# `aspect-body-key-below-listed` — C111's price, den-hoag-661s2, CLOSED by den-hoag-nwshf. A key
# listed in `freeformKeys` opens an UNGATED subtree (gen-aspects' published meaning of the list), so
# the closed vocabulary of `aspect-cnf.nix` holds at an aspect body's first level only. Below it,
# gen-aspects' orphan-leaf refusal (on by default) answers instead: a misspelt `nixos` one level
# below the listed `placket` carries a scalar that is neither class content nor an aspect, and is
# refused catchably. The listed nested aspect itself still composes (`gore/placket`), and the same
# misspelling at the first level is refused by the closed-key gate (the control).
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
  below = gore { placket.nixso.boot.loader.grub.enable = false; };
  first = gore { nixso.boot.loader.grub.enable = false; };
in
{
  construct = [ "aspect-bodys-first-level-is-a-closed-vocabulary" ];
  check = asserts (
    !(builtins.tryEval (builtins.deepSeq below.placket.nixso null)).success
    && below.placket.key == "gore/placket"
    && !(builtins.tryEval (builtins.deepSeq first.nixso null)).success
  );
}
