# `kind-collection-default-resolves-alone`. Red at the hub before the landing: the default's `mkIf`
# and `mkDefault` records are served as list elements, `region` is the raw `mkIf` record, and the
# default with `mkIf` at its top is served as that record.
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
      topServed = false;
    }
  );
}
