# `kind-collection-without-default-folds-untyped`. Red at the hub before the landing: reading `roles`,
# defined or not, and the undefined kind's mint abort uncatchably on `attribute 'default' missing`.
{ asserts, kcnRead }:
{
  construct = [ "kind-collection-without-default-folds-untyped" ];
  check = asserts (
    kcnRead == {
      roles = [
        "kind"
        "mixin"
      ];
      undefinedRefused = true;
      undefinedMinted = true;
    }
  );
}
