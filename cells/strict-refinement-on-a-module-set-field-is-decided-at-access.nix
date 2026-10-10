# `flounceModuleSetAccess` — strict-refinement-on-a-module-set-field-is-decided-at-access. A strict
# refinement on a field carrying a module set is checked when the field is read: the registry knot
# under a strict `refined` composes, and a failing one refuses that field while its sibling serves. A
# failing strict refinement on a flat field still refuses at construction, sibling included. Red:
# construction demands the module-set field, so the knot aborts uncatchably with infinite recursion,
# which reds the whole check evaluation, and the failing refinement refuses the sibling too.
{ asserts, flounceModuleSetAccess }:
{
  construct = [ "strict-refinement-on-a-module-set-field-is-decided-at-access" ];
  check = asserts (
    flounceModuleSetAccess == {
      knotFrills = {
        frill-f1 = "picot";
        frill-f2 = "rolled";
      };
      moduleSetFailSibling = "picot";
      moduleSetFailField = "REFUSED";
      flatFailSibling = "REFUSED";
      flatFailField = "REFUSED";
    }
  );
}
