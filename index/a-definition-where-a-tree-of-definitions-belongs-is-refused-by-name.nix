{
  title = "a definition where a tree of definitions belongs is refused by name";
  adr = "0039 (replacement bar, modules.sh); 0025 item 1";
  what = "a module's `config = mkIf true true` and a declared group defined as `5` are each refused by name and catchable, as nixpkgs refuses both, where gen-merge aborted uncatchably; the twin defining the group through `mkIf` reads nixpkgs' value";
}
