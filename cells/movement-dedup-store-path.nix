# `movement-dedup-store-path` — C63, den-hoag-kunjm. A dedup over delivered content: two strings
# naming `pkgs.hello`'s `.drv`, equal under `==` and differing in string context, collapse 2 -> 1
# with one licensed drop, and the kept datum carries the UNION of both contexts. Neither string
# alone carries it, so a build that kept the walk-first datum as it stood reds here; pinned, the
# bucket address aborts uncatchably (`… is not allowed to refer to a store path`).
#
# C63 -- a dedup collapse keeps every dependency edge: the kept datum carries
# the union of its collapsed twins' string contexts.
{
  asserts,
  collisionStorePath,
  drvOnly,
  drvAll,
  noFalseDedup,
}:
let
  union = builtins.getContext (drvOnly + drvAll);
in
{
  construct = [ "C63" ];
  check = asserts (
    drvOnly == drvAll
    && builtins.getContext drvOnly != union
    && builtins.getContext drvAll != union
    && builtins.length collisionStorePath.contributions == 1
    && builtins.length collisionStorePath.dropped == 1
    && noFalseDedup collisionStorePath
    && builtins.getContext (builtins.head collisionStorePath.contributions).datum == union
  );
}
