# `kind-collection-declared-type-resolves-as-nixpkgs`, den-hoag-collection-declared-element-type-fwjez.
# Red at a gen-schema before the declared `type`: the field was unread, so the discharged `nixos` was
# counted (2) and served as a raw `mkIf` record, `env.eu.replicas` was never resolved, and `[ 1 ]` was
# served under `listOf str`. Red at a gen-schema before den-hoag-6ve3v: `shell`'s scalar default had
# no seed to fold its definition onto, and the read was refused by name.
# Red at a gen-schema whose typed collection with no default and no definition was refused by name
# where its type states an empty value (`aliases`, `owner`).
# Red at a gen-schema before den-hoag-s1ouh: `hosts`, every definition discharged, was refused ("has no
# definitions after priority resolution") where nixpkgs serves its default.
{ asserts, kcdtRead }:
{
  construct = [ "kind-collection-declared-type-resolves-as-nixpkgs" ];
  check = asserts (
    kcdtRead == {
      classCount = 1;
      classes = [ "darwin" ];
      env.eu.shards = 2;
      shell = "zsh";
      hosts = [ "localhost" ];
      wrongElementServed = false;
      aliases = [ ];
      owner = null;
      titleServed = false;
    }
  );
}
