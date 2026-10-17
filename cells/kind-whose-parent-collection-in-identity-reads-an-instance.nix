# `kind-whose-parent-collection-in-identity-reads-an-instance` — den-hoag-c2836, den#719 undeclared on a
# kind's PARENT. Red at the hub before the landing: every read recurses on Nix, Determinate and Lix (the
# berth classifies its parent by the parent's mark, which reads the instance). Red too where the berth
# composes the parent by its content and no identity read holds the parent's whole stamp: the copy's mark
# is then served.
{
  asserts,
  kphRead,
  kphCopyMarked,
}:
{
  construct = [ "kind-whose-parent-collection-in-identity-reads-an-instance" ];
  check = asserts (
    kphRead == {
      mooring = "pier-4";
      pier = 4;
      docked = true;
      marked = true;
      keyed = true;
      waived = [ "pier-4" ];
    }
    && !kphCopyMarked.success
  );
}
