{
  title = "a set union keeps a string's twins' edges";
  adr = "0025 item 1, 0034";
  what = "`movement-setunion-store-path`: `combines.setUnion` over `[ drvOnly ]` and `[ drvAll ]` (C63's two strings naming `pkgs.hello`'s `.drv`, equal under `==`, differing in string context) with no dedup: 2 contributions, 1 element, and that element carries the union of both contexts, where prelude `unique` kept the walk-first element as it stood";
}
