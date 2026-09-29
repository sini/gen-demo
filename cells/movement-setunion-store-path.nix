# `movement-setunion-store-path` — C100, den-hoag-kunjm F2. A set union over delivered content:
# `[ drvOnly ]` and `[ drvAll ]` name `pkgs.hello`'s `.drv`, equal under `==` and differing in
# string context. Both contributions survive (no dedup), and the union collapses their elements
# into ONE carrying the union of both contexts. Neither input alone carries it, so a union that
# keeps the walk-first element as it stood (prelude `unique`) reds here.
#
# C100 -- a set union keeps every dependency edge: its one element carries the
# union of its collapsed twins' string contexts.

{
  asserts,
  unionStorePath,
  drvOnly,
  drvAll,
}:

let
  union = builtins.getContext (drvOnly + drvAll);
in

{
  construct = [ "C100" ];
  check = asserts (
    drvOnly == drvAll
    && builtins.getContext drvOnly != union
    && builtins.getContext drvAll != union
    && builtins.length unionStorePath.contributions == 2
    && builtins.length unionStorePath.value == 1
    && builtins.getContext (builtins.head unionStorePath.value) == union
  );
}
