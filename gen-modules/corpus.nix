# THE CORPUS — one kind, one node, one aspect carrying one delivery class.
#
# This tree is composed by the hub's `gen.tree`, i.e. gen-merge's `evalModuleTree`, NOT by nixpkgs'
# `lib.evalModules`. Everything here is therefore written against gen-merge's own `mkOption`/`types`
# (threaded in as `genMerge`), never nixpkgs `lib` — the pure side of the boundary.
#
# NAMING. `thimble` is INVENTED on purpose. gen names no entities: there is no host, user, system,
# machine or service in the substrate, and a corpus that used one would be asserting a vocabulary gen
# does not have. The kind, its node and its aspect are all nonsense words for exactly that reason.
{
  config,
  genAspects,
  genMerge,
  genSchema,
  ...
}:
let
  aspectSchema = genAspects.mkAspectSchema (import ../aspect-cnf.nix);
  inherit (genMerge) mkOption types;
in
{
  # `mkAspectModule` declares `options.aspects` and threads schema-declared options into every
  # instance. It does NOT declare `options.schema` despite what its comment in gen-aspects says, so
  # the schema option is declared here from the same aspect-aware `schemaOption`.
  imports = [ (aspectSchema.mkAspectModule { }) ];

  options.schema = aspectSchema.schemaOption;

  # ── THE NODE REGISTRY, AND WHY IT IS SPELLED `hosts` ──
  # The hub's `flakeModules/default.nix` calls `gen-delivery`'s `project` without a `selectHosts`,
  # so the projection takes that function's default — `v: v.hosts or { }`. A registry under any other
  # name projects EMPTY and `nixosConfigurations` comes out `{ }`: no error, no output. The name is
  # imposed by the hub surface, not chosen here, and it is the only word in this corpus that the
  # naming rule above did not get to pick. Reported as a finding against the hub, not worked around.
  options.hosts = genSchema.mkInstanceRegistry config.schema.thimble { };

  config = {
    # THE ONE KIND.
    schema.thimble = {
      options.aspects = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Aspect keys this node is a member of.";
      };
      options.spool = mkOption {
        type = types.str;
        description = "An arbitrary attribute, here so the kind carries content of its own.";
      };
    };

    # THE ONE NODE.
    hosts.pewter = {
      aspects = [ "stitch" ];
      spool = "linen";
    };

    # THE ONE ASPECT, carrying the one delivery class. `nixos` is declared `category = "class"` in
    # ../aspect-cnf.nix, so gen-delivery projects this content per member node and `realize` hands it
    # to the terminal. The body is the smallest thing nixpkgs will call a system: no real machine,
    # no hardware, no fleet.
    aspects.stitch.nixos = {
      nixpkgs.hostPlatform = "x86_64-linux";
      boot.loader.grub.enable = false;
      fileSystems."/" = {
        device = "none";
        fsType = "tmpfs";
      };
      system.stateVersion = "25.05";
    };
  };
}
