# `aspect-body-key-below-listed` — C111's price, den-hoag-661s2. A key listed in `freeformKeys`
# opens an UNGATED subtree (gen-aspects' published meaning of the list), so the closed vocabulary of
# `aspect-cnf.nix` holds at an aspect body's first level only: a misspelt `nixos` one level below
# the listed `placket` is served, as a nested aspect, with no refusal. This cell pins that as it
# stands, so a gen-aspects change that gates the listed subtree reds here and is read as a change
# rather than passing unseen. The same misspelling at the first level is refused (the control).
{
  asserts,
  genAspects,
  genMerge,
}:
let
  cnf = import ../aspect-cnf.nix;
  gore =
    body:
    (genMerge.evalModuleTree {
      modules = [
        { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }
        { aspects.gore = body; }
      ];
    }).config.aspects.gore;
  below = gore { placket.nixso.boot.loader.grub.enable = false; };
  first = gore { nixso.boot.loader.grub.enable = false; };
in
{
  construct = [ "C111" ];
  check = asserts (
    (builtins.tryEval (builtins.deepSeq below.placket.nixso null)).success
    && below.placket.nixso.key == "gore/placket/nixso"
    && !(builtins.tryEval (builtins.deepSeq first.nixso null)).success
  );
}
