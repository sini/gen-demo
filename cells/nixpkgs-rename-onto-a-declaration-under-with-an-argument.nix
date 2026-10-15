# `withArgumentRename` — nixpkgs-rename-onto-a-declaration-under-with-an-argument, den-hoag-8tmd5 OQ2.
# `weft` is defined through its alias onto `warp`, declared under `with loom;`, with no other rename
# pending.
# Red: the declaration guard refuses the alias leaf by the argument's name (`a module read the module
# argument `loom' while its own declarations were being folded`), which reds the whole check evaluation.
{ asserts, withArgumentRename }:
{
  construct = [ "nixpkgs-rename-onto-a-declaration-under-with-an-argument" ];
  check = asserts (withArgumentRename == 7);
}
