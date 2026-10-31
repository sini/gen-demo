# `delivery-one-host` (den-hoag-ien5k) — a fleet of `spindle`s, an invented kind, composed through the
# hub's own `flakeModule` as a consumer's flake is: every spindle a member of `ply`, which carries the
# corpus's `stitch` system body, and each its own `hostName`, read from the node binding. Shared by
# `cells/one-host-of-n.nix` and the `ci/refusals/` row of the same name.
#   names  the spindles declared
#   plant  the LAST spindle also reaches `snag`, `gusset` content with no terminal
{ inputs }:
{
  names,
  plant ? false,
}:
(inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  imports = [
    inputs.gen.flakeModules.default
    inputs.gen.flakeModules.genLibs
  ];
  systems = [ "x86_64-linux" ];
  gen = {
    aspectCnf = import ../../aspect-cnf.nix;
    nodeRegistryPath = [ "spindles" ];
    modules = [
      (
        {
          genAspects,
          genMerge,
          genSchema,
          ...
        }:
        let
          inherit (genMerge) mkOption types;
          schema =
            genSchema.evalSchema
              {
                schemaOption = (genAspects.mkAspectSchema (import ../../aspect-cnf.nix)).schemaOption;
              }
              [
                {
                  config.schema.spindle = {
                    options.aspects = mkOption {
                      type = types.listOf types.str;
                      default = [ ];
                    };
                    options.hostName = mkOption { type = types.str; };
                  };
                }
              ];
          last = builtins.elemAt names (builtins.length names - 1);
        in
        {
          imports = [ ((genAspects.mkAspectSchema (import ../../aspect-cnf.nix)).mkAspectModule { }) ];
          options.spindles = genSchema.mkInstanceRegistry { } schema.spindle;
          config = {
            aspects.ply.nixos =
              { node, ... }:
              {
                nixpkgs.hostPlatform = "x86_64-linux";
                boot.loader.grub.enable = false;
                fileSystems."/" = {
                  device = "none";
                  fsType = "tmpfs";
                };
                system.stateVersion = "25.05";
                networking.hostName = node.hostName;
              };
            aspects.snag.gusset.snagged = true;
            spindles = builtins.listToAttrs (
              map (n: {
                name = n;
                value = {
                  aspects = [ "ply" ] ++ (if plant && n == last then [ "snag" ] else [ ]);
                  hostName = n;
                };
              }) names
            );
          };
        }
      )
    ];
  };
}).nixosConfigurations
