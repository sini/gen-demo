# ── `delivery-declared-membership` — a delivery class's members read from what each node declares (den-hoag-ien5k T3) ──
# A plain gen-schema registry named directly by `gen.nodeRegistryPath`, through the hub's `flakeModules.default`, in
# three variants of its kind: one declaring nothing for `aspects` (`none`), one setting it (`kindcfg`, which falls
# back to the module-system read: two definitions survive at one priority), and one setting it under `mkDefault`
# (`kinddefault`, served: the node's own definition is the one survivor). Each variant is evaluated twice: through
# the plain registry, where the hub reads membership with gen-schema's `declaredField`, and through the same
# declaration with an opaque `extraModules` member, which no syntactic reader sees into, so every node is read by
# the module system (the reference). `declaredMembership.<variant>.<arm>` is each node's toplevel `drvPath`.
{ inputs }:
let
  base = {
    nixpkgs.hostPlatform = "x86_64-linux";
    boot.loader.grub.enable = false;
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
    };
    system.stateVersion = "25.05";
  };
  cnf.keySemantics.nixos.category = "class";
  names = [
    "bobbin-a"
    "bobbin-b"
  ];
  fleet =
    variant: opaque:
    let
      tree =
        {
          genAspects,
          genMerge,
          genSchema,
          ...
        }:
        let
          inherit (genMerge) mkDefault mkOption types;
          schema = genSchema.evalSchema { } [
            {
              config.schema.spool = {
                options.aspects = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                };
                options.idx = mkOption { type = types.int; };
                config =
                  if variant == "kindcfg" then
                    { aspects = [ "warp" ]; }
                  else if variant == "kinddefault" then
                    { aspects = mkDefault [ "warp" ]; }
                  else
                    { };
              };
            }
          ];
        in
        {
          imports = [ ((genAspects.mkAspectSchema cnf).mkAspectModule { }) ];
          options.spools = genSchema.mkInstanceRegistry (
            if opaque then { extraModules = [ ({ ... }: { }) ]; } else { }
          ) schema.spool;
          config.spools = builtins.listToAttrs (
            builtins.genList (i: {
              name = builtins.elemAt names i;
              value = {
                aspects = [ "weft" ];
                idx = i;
              };
            }) (builtins.length names)
          );
          config.aspects.weft.nixos =
            { node, ... }:
            base // { networking.hostName = "h${toString node.idx}"; };
          config.aspects.warp.nixos.environment.etc."warp".text = "warp";
        };
      ev =
        inputs.flake-parts.lib.evalFlakeModule
          {
            inputs = {
              inherit (inputs) gen nixpkgs;
              self = {
                outPath = "/gen-demo-declared-membership";
                inputs = { };
              };
            };
          }
          {
            systems = [ ];
            imports = [ inputs.gen.flakeModules.default ];
            gen = {
              modules = [ tree ];
              aspectCnf = cnf;
              nodeRegistryPath = [ "spools" ];
            };
          };
    in
    builtins.mapAttrs (
      _: s: s.config.system.build.toplevel.drvPath
    ) ev.config.flake.nixosConfigurations;
  variant = v: {
    declared = fleet v false;
    reference = fleet v true;
  };
in
{
  declaredMembership = {
    none = variant "none";
    kindcfg = variant "kindcfg";
    kinddefault = variant "kinddefault";
  };
}
