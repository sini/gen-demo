{
  title = "a nixpkgs rename onto an option typed by a module argument";
  adr = "0039";
  what = "`argumentTypedRename`: stock `lib.mkRenamedOptionModule` onto an option whose `type` reads a `_module.args` value another module defines (NixOS `systemd.nix` under `with utils;`), beside a rename chain; the staged declaration passes read an earlier pass's declarations with the arguments that pass's modules define, so the alias serves nixpkgs' value";
}
