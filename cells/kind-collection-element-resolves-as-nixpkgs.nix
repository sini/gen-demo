# `kind-collection-element-resolves-as-nixpkgs`. Red at the hub before the landing: the `mkIf` and
# `mkDefault` records are served as list elements, the later plain `region` beats the `mkForce` one,
# and the string `classes` reaches the list fold and aborts uncatchably.
{ asserts, kceRead }:
{
  construct = [ "kind-collection-element-resolves-as-nixpkgs" ];
  check = asserts (
    kceRead == {
      classes = [
        "nixos"
        "darwin"
      ];
      metadata = {
        region = "eu";
      };
      wrongShapeServed = false;
    }
  );
}
