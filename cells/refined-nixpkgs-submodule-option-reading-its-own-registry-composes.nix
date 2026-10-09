# `rucheNixpkgsRefinedPleats` — refined-nixpkgs-submodule-option-reading-its-own-registry-composes,
# den-hoag-60hql. A kind option's `refined` RAW nixpkgs submodule imports one option per registry
# instance; the defined `attrsOf` element, the lazily refined field and the kind's `refs` all read.
# Red: `refined` copies the raw record, which drops the functor payload gen-merge recognises a nixpkgs
# submodule by and states no `carries`, so the door reads the copy's `nestedTypes`, its own module set
# evaluated, and the read aborts uncatchably with infinite recursion, which reds the whole check evaluation.
{ asserts, rucheNixpkgsRefinedPleats }:
let
  pleats = {
    pleat-r1 = "shirring";
    pleat-r2 = "gauging";
  };
in
{
  construct = [ "refined-nixpkgs-submodule-option-reading-its-own-registry-composes" ];
  check = asserts (
    rucheNixpkgsRefinedPleats == {
      pleats.box = pleats;
      smock = pleats;
      refs = { };
    }
  );
}
