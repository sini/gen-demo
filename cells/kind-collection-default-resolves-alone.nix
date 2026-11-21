# `kind-collection-default-resolves-alone`. Red at the hub before the landing: the default's `mkIf`
# and `mkDefault` records are served as list elements, `region` is the raw `mkIf` record, and the
# default with `mkIf` at its top is served as that record. Red at a gen-schema before den-hoag-6ve3v:
# `rank`'s scalar default had no merge strategy, and the read was refused by name.
{ asserts, kcdRead }:
{
  construct = [ "kind-collection-default-resolves-alone" ];
  check = asserts (
    kcdRead == {
      classes = [
        "nixos"
        "darwin"
        "kind"
        "mixin"
      ];
      metadata = {
        region = "eu";
      };
      rank = 7;
      topServed = false;
    }
  );
}
