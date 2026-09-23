# `nixos-instantiate` — the target instantiated, **not built**: the check writes
# `nixosConfigurations.pewter.config.system.build.toplevel.drvPath` to a file, which runs the whole
# NixOS evaluation and stops at the `.drv`.
#
# the target instantiated, not built. Forcing the drvPath into a file runs the
# whole NixOS evaluation and writes the .drv, and stops there.
{ config, pkgs }:
{
  construct = [ ];
  check = pkgs.writeText "gen-demo-pewter-drvpath" (
    config.flake.nixosConfigurations.pewter.config.system.build.toplevel.drvPath
  );
}
