# `kind-collection-in-identity-reads-an-instance` — den-hoag-9zyp7, den#719 undeclared. Red at the hub
# before the landing: every read recurses on Nix and Determinate (the import's stamp forces the
# identity). Red too where the import's stamp leaves the identity cells out and no identity door
# holds the whole stamp: the copy's `id_hash` is then served.
{
  asserts,
  kciRead,
  kciCopyKeyed,
}:
{
  construct = [ "kind-collection-in-identity-reads-an-instance" ];
  check = asserts (
    kciRead == {
      mooring = "pier-4";
      marked = true;
      keyed = true;
      waived = [ "pier-4" ];
    }
    && !kciCopyKeyed.success
  );
}
