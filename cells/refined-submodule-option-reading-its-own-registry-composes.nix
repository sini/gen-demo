# `rucheRefinedPleats` — refined-submodule-option-reading-its-own-registry-composes, den-hoag-60hql. A
# kind option's `refined` submodule imports one option per registry instance; the defined `attrsOf`
# element, the lazily refined field and the kind's `refs` all read. Red: gen-merge's import door reads
# the `refined` copy's `nestedTypes`, its own module set evaluated, and the read aborts uncatchably
# with infinite recursion, which reds the whole check evaluation.
{ asserts, rucheRefinedPleats }:
let
  pleats = {
    pleat-r1 = "shirring";
    pleat-r2 = "gauging";
  };
in
{
  construct = [ "refined-submodule-option-reading-its-own-registry-composes" ];
  check = asserts (
    rucheRefinedPleats == {
      pleats.box = pleats;
      smock = pleats;
      refs = { };
    }
  );
}
