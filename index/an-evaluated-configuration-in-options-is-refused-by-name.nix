{
  title = "an evaluated configuration in options is refused by name";
  adr = "0039 (replacement bar, modules.sh); 0025 item 1";
  what = "`options.shuttle` set to an evaluation's result is refused by name and catchable, as nixpkgs refuses it, where gen-merge walked into the result and aborted; the twin declaring `shuttle` with `mkOption` reads nixpkgs' value";
}
