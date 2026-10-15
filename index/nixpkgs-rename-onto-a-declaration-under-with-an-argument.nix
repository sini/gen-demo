{
  title = "a nixpkgs rename onto a declaration read under with an argument";
  adr = "0039";
  what = "`withArgumentRename`: stock `lib.mkRenamedOptionModule` onto an option declared under `with` a `_module.args` value another module defines (NixOS `systemd.nix` under `with utils;`), with no other rename pending; the staged declaration passes are tried once at a constant pass and built on demand, so the alias serves nixpkgs' value";
}
