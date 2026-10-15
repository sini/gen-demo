# `argumentTypedRename` — nixpkgs-rename-onto-an-argument-typed-option, den-hoag-8tmd5 M1. `hank` is
# defined through its alias onto `skein`, whose type reads the module argument `spool`, and `selvage`
# through a two-link chain onto `braid`.
# Red: the declaration guard refuses the alias leaf by the argument's name (`a module read the module
# argument `spool' while its own declarations were being folded`), which reds the whole check evaluation.
{ asserts, argumentTypedRename }:
{
  construct = [ "nixpkgs-rename-onto-an-argument-typed-option" ];
  check = asserts (
    argumentTypedRename == {
      braid = "soutache";
      skein = 5;
    }
  );
}
