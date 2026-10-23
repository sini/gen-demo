# `kind-collection-priority-resolves-as-nixpkgs`. Red at the hub before the landing: the `mkDefault`
# record reaches the list fold and the read aborts (`expected a list but found a set`), and the
# `mkForce` record's keys are splatted into the attrs collection.
{ asserts, kcpRead }:
{
  construct = [ "kind-collection-priority-resolves-as-nixpkgs" ];
  check = asserts (
    kcpRead == {
      userClasses = [ "homeManager" ];
      adminClasses = [ "nixos" ];
      adminMetadata = {
        tier = "prod";
      };
    }
  );
}
