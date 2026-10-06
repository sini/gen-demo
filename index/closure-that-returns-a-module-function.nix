{
  title = "a closure that returns a module function";
  adr = "0025 item 1, 0010 §4(a), den-hoag-zm0gu";
  what = "`closure-returning-a-module-function`: under C197's mounted cnf, a load-time closure over `thimble` returns `{ config, ... }: { nixos = …; }`, which the module system applies downstream under arguments the door never holds, so the door checks its result when applied: `plain`'s result holds no closure and is served, its class value `\"plain-pewter-P\"`, and `stitched`'s writes a class closure over `bobbin`, which can be neither registered nor scoped and is refused by name at its position (row 157), where it was delivered without its `has bobbin` guard";
}
