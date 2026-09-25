# `nixos-instantiate` — the target instantiated, **not built**: the check writes
# `nixosConfigurations.pewter.config.system.build.toplevel.drvPath` to a file, which runs the whole
# NixOS evaluation and stops at the `.drv`.
#
# Context discarded: upstream and Lix refuse `--no-build` on an absent input `.drv` (den-hoag-lbtnv).
{ config, pkgs }:
{
  construct = [ ];
  check = pkgs.writeText "gen-demo-pewter-drvpath" (
    builtins.unsafeDiscardStringContext config.flake.nixosConfigurations.pewter.config.system.build.toplevel.drvPath
  );
}
