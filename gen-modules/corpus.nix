# THE CORPUS — two kinds, four nodes, declared edges, one aspect carrying three keys under test.
#
# This tree is composed by the hub's `gen.tree`, i.e. gen-merge's `evalModuleTree`, NOT by nixpkgs'
# `lib.evalModules`. Everything here is therefore written against gen-merge's own `mkOption`/`types`
# (threaded in as `genMerge`), never nixpkgs `lib` — the pure side of the boundary.
#
# NAMING. `thimble` and `bobbin` are INVENTED on purpose. gen names no entities: there is no host,
# user, system, machine or service in the substrate, and a corpus that used one would be asserting a
# vocabulary gen does not have (ADR-0035). Every kind, node and aspect name here is a nonsense word for
# exactly that reason.
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

  # ── THE NODE REGISTRIES, BOTH UNDER INVENTED NAMES ──
  # The hub's `flakeModules/default.nix` used to call `gen-delivery`'s `project` without a
  # `selectHosts`, so the projection took that function's default — `v: v.hosts or { }` — and a
  # registry under any other name projected EMPTY: no error, no output, an empty
  # `nixosConfigurations`. The hub now takes the attribute path from the consumer through
  # `gen.nodeRegistryPath` (ADR-0035, `den-hoag-hub-hardcodes-hosts-mxpd5`), so no word here is
  # imposed. Both registries are the plural of their own kind; `flake.nix` names the first one to
  # the hub, and C6 names the second to `gen-delivery` directly.
  # ── C17 — AN OPTION CONTRIBUTED ON THE INSTANCE SIDE, AND THE IDENTITY THAT DOES NOT MOVE ──
  # `extraModules` is `mkInstanceRegistry`'s supported second inlet: its modules are imported BESIDE
  # the kind into every instance's submodule, so `shirring` below is a real declared option carrying a
  # real value on every thimble. It is NOT an identity key, and cannot become one: the key set closed
  # at the KIND boundary, one stratum above this, before any module named here was seen. So this
  # declaration has nowhere to attach in an identity — not refused, unexpressible.
  #
  # The corpus asserts it as a VALUE (C17): `thimbles.pewter.id_hash` is byte-identical to the stamp the
  # corpus carried before this option existed. Region 2's refusal is the other half and cannot be a
  # cell — a throw is not a value — so it is `just refusals` row 13.
  options.thimbles = genSchema.mkInstanceRegistry config.schema.thimble {
    extraModules = [
      {
        options.shirring = mkOption {
          type = types.str;
          default = "gathered";
          description = "Instance-side content. Declared beside the kind, never part of the identity.";
        };
      }
    ];
  };
  options.bobbins = genSchema.mkInstanceRegistry config.schema.bobbin { };

  # THE DECLARED EDGES (ADR-0012, ADR-0019). Edges are data, never read off a projection; `flake.nix`
  # unions them with the dynamic edge C5's policy program admits and queries the result as one graph.
  options.declaredEdges = mkOption {
    type = types.listOf types.raw;
    default = [ ];
    description = "Labelled { from; to; label; } relations over the node names above.";
  };

  config = {
    # THE TWO KINDS.
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
    schema.bobbin = {
      options.gauge = mkOption {
        type = types.str;
        description = "An arbitrary attribute on the second kind, carrying content of its own.";
      };
    };

    # THE FOUR NODES. `damask` is the one C2 reaches only across two `tacks` hops; `faille` is the one
    # no DECLARED edge reaches at all, which is what makes C5's dynamic edge observable.
    thimbles.pewter = {
      aspects = [ "stitch" ];
      spool = "linen";
    };
    thimbles.damask = {
      aspects = [ ];
      spool = "sateen";
    };
    bobbins.grosgrain = {
      gauge = "fine";
    };
    bobbins.faille = {
      gauge = "coarse";
    };

    declaredEdges = [
      {
        from = "pewter";
        to = "grosgrain";
        label = "tacks";
      }
      {
        from = "grosgrain";
        to = "damask";
        label = "tacks";
      }
      {
        from = "pewter";
        to = "damask";
        label = "gathers";
      }
    ];

    # THE ONE ASPECT. `nixos` carries the one delivery class, declared `category = "class"` in
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

    # C6 LIMB 1 (ADR-0028's Rider) — a `channel` key CARRYING A MODULE. A channel rides its value
    # verbatim to whoever reads it and is never a delivery class regardless of shape; this body would
    # pass any shape test for "looks like a system" and must still not realize.
    aspects.stitch.welt = {
      imports = [ ];
      boot.loader.grub.enable = false;
    };

    # C6 LIMB 2 (ADR-0028's Rider) — a `class` key valued NULL: gen-aspects' representable absence of
    # a declared-but-unset class. Present in the body (not omitted), so the projected entry's key set
    # witnesses the declaration reached the submodule even though the value carries no content.
    aspects.stitch.gusset = null;

    # ── C16 — THE ASPECT GRAPH ITSELF, given depth so its published facts are a GRAPH ──
    aspects.hemline.placket.eyelet = { };
    aspects.hemline.facing = { };
    # ★ THE THIRD ELEMENT IS A FOREIGN REFERENCE, AND IT IS THE ONE THIS CORPUS COULD NOT DECLARE
    # BEFORE. This file carries no `providerPrefix` (`aspect-cnf.nix` sets only `keySemantics`), so
    # the corpus's origin is `[ ]` — gen-link's named `self` state, meaning "assigned by whoever
    # federates me". `keyRef`'s string sugar splits the FIRST SEGMENT off as the origin, so `mill` is
    # the referent's origin and this reference is foreign BY CONSTRUCTION: `mill/stitch` names a node
    # in a fixpoint this corpus does not hold, exactly as the `loom` registry's shipped
    # `keyRef "mill/stitch"` does. gen-aspects cannot check it and does not pretend to — it is
    # published in `foreignIncludesOf`, NOT as an edge in `includesOf`, so it never reaches
    # `c16IncludesGraph` and never becomes a `declares` edge to a non-member.
    #
    # Declared here because it used to be UNDECLARABLE: with the reference in `includesOf` it became
    # a `declares` edge whose `to` is no node of this graph, and gen-assemble's
    # `requireDeclaredMembership` refused the whole contribution by name.
    aspects.bartack.includes = [
      config.aspects.hemline.placket     # a REFERENCE — resolves to the node "hemline/placket"
      ({ node, ... }: { })               # INLINE CONTENT — its POSITION is published, not an edge
      (genAspects.keyRef "mill/stitch")  # a FOREIGN REFERENCE — published as a ref, never an edge
    ];
  };
}
