# `kind-collection-declared-type-resolves-as-nixpkgs`, den-hoag-collection-declared-element-type-fwjez.
# Red at a gen-schema before the declared `type`: the field was unread, so the discharged `nixos` was
# counted (2) and served as a raw `mkIf` record, `env.eu.replicas` was never resolved, and `[ 1 ]` was
# served under `listOf str`.
{ asserts, kcdtRead }:
{
  construct = [ "kind-collection-declared-type-resolves-as-nixpkgs" ];
  check = asserts (
    kcdtRead == {
      classCount = 1;
      classes = [ "darwin" ];
      env.eu.shards = 2;
      wrongElementServed = false;
    }
  );
}
