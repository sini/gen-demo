# `kind-collection-mixin-folds-with-kind`. Red at the hub before the landing: the mixin's `mkIf` and
# `mkDefault` records are served as list elements, `region` is the raw `mkDefault` record, and the
# mixin's string `classes` reaches the list fold and aborts uncatchably.
{ asserts, kcmRead }:
{
  construct = [ "kind-collection-mixin-folds-with-kind" ];
  check = asserts (
    kcmRead == {
      classes = [
        "nixos"
        "darwin"
      ];
      metadata = {
        region = "us";
      };
      wrongShapeServed = false;
    }
  );
}
