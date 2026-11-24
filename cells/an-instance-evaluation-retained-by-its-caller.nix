# `an-instance-evaluation-retained-by-its-caller` — den-hoag-t5ndo 1b. gen-schema's `evalInstance` returns the
# one evaluation the instance type's exported `merge` makes, as `{ config; provenance; }`: its `config` is the value
# nixpkgs' `attrsOf` serves for the element and the value the exported `merge` serves, and its `provenance` names
# the type-own contribution's file beside the entry's. Red where the door is absent (gen-schema main), where the
# route serves a child the exported `merge` does not make (a copy carrying a sibling's fold and tree, which the
# copy's own `merge` still serves), or where the door takes an option it does not state.
{ asserts, retainedInstanceArms }:
{
  construct = [ "an-instance-evaluation-retained-by-its-caller" ];
  check = asserts (
    retainedInstanceArms == {
      configIsTheTypedValue = true;
      configIsTheExportedMerge = true;
      keys = [
        "config"
        "provenance"
      ];
      groupsWinners = [
        "schema.nix"
        "host.nix"
      ];
      groups = [
        "base"
        "video"
      ];
      forgedRefused = true;
      forgedMergeServes = true;
      unknownOptionRefused = true;
    }
  );
}
