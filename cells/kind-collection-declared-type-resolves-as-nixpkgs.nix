# `kind-collection-declared-type-resolves-as-nixpkgs`, den-hoag-collection-declared-element-type-fwjez.
# Red at a gen-schema before the declared `type`: the field was unread, so the discharged `nixos` was
# counted (2) and served as a raw `mkIf` record, `env.eu.replicas` was never resolved, and `[ 1 ]` was
# served under `listOf str`. Red at a gen-schema whose typed collection with no default and no definition
# was refused by name where its type states an empty value (`aliases`, `owner`).
{ asserts, kcdtRead }:
{
  construct = [ "kind-collection-declared-type-resolves-as-nixpkgs" ];
  check = asserts (
    kcdtRead == {
      classCount = 1;
      classes = [ "darwin" ];
      env.eu.shards = 2;
      wrongElementServed = false;
      aliases = [ ];
      owner = null;
      titleServed = false;
    }
  );
}
