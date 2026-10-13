# `kind-collection-outside-identity-reads-an-instance` — den-hoag-ux9xg, den#719. Red at the hub
# before the landing: the plain arm recurses on Nix and Determinate (the import stamp), the other two
# on all three evaluators (the module key; the parent's mark read by value).
{
  asserts,
  kcoiPlain,
  kcoiInheriting,
  kcoiParentHolds,
}:
let
  read = {
    mooring = "pier-4";
    marked = true;
    waived = [ "pier-4" ];
  };
in
{
  construct = [ "kind-collection-outside-identity-reads-an-instance" ];
  check = asserts (kcoiPlain == read && kcoiInheriting == read && kcoiParentHolds == read);
}
