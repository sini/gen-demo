# `closure-returning-a-module-function` — C199, den-hoag-zm0gu. A load-time closure that returns a module
# function: the module system applies it downstream, under arguments the door never holds, so the door
# checks its result when applied. `plain`'s result holds no closure and is served, its class value read
# as `"plain-pewter-P"`; `stitched`'s holds a class closure over `bobbin`, which can be neither
# registered nor scoped and is refused (row 157 reads the message). Before, `stitched`'s class value was
# delivered without its `has bobbin` guard.

{
  asserts,
  c198Plain,
  c198StitchedRefused,
}:

{
  construct = [ "closure-that-returns-a-module-function" ];
  check = asserts (c198Plain == "plain-pewter-P" && c198StitchedRefused);
}
