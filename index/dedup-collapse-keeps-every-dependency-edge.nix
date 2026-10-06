{
  title = "a dedup collapse keeps every dependency edge";
  adr = "0025 item 1, 0034";
  what = "`movement-dedup-store-path`: two strings naming `pkgs.hello`'s `.drv`, equal under `==` and differing in string context (`drvPath` and its `unsafeDiscardOutputDependency`), collapse under `byDatum` into one datum carrying the union of both contexts; 1 kept, 1 licensed drop, where the address used to abort (`… is not allowed to refer to a store path`)";
}
