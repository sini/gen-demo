# `kind-with-a-parent-collection-in-identity-reads-an-instance` — den-hoag-9zyp7 OQ2, den#719 undeclared on
# a kind that composes a parent. Red at the hub before the landing: every read recurses on Nix,
# Determinate and Lix (the kind's module key is its mark, so the instance's import forces the identity).
{
  asserts,
  kpiRead,
}:
{
  construct = [ "kind-with-a-parent-collection-in-identity-reads-an-instance" ];
  check = asserts (
    kpiRead == {
      mooring = "pier-4";
      pier = 4;
      marked = true;
      keyed = true;
      waived = [ "pier-4" ];
    }
  );
}
