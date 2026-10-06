{
  title = "a wrapped module keeps its importer's file";
  adr = "0025 item 1";
  what = "a def reached through `{ _file = \"/demo/spool.nix\"; imports = [ … ]; }` carries that file in `provenance.spool.defs`, where it used to read the engine's `<gen-merge>` fallback; the value `sateen` is asserted beside it";
}
