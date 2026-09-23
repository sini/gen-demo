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
  inherit (genMerge) mkMerge mkOption types;

  # §2.6's staged pass — the kind bodies moved verbatim out of `config`, below, and evaluated by
  # gen-schema's OWN `evalModuleTree` (never this file's `config`). `schema.thimble`/`schema.bobbin`
  # is the frozen result these registries and `options.schema` both read.
  schema = genSchema.evalSchema {
    inherit (aspectSchema) schemaOption;
    modules = [
      {
        config.schema.thimble = {
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
        config.schema.bobbin = {
          options.gauge = mkOption {
            type = types.str;
            description = "An arbitrary attribute on the second kind, carrying content of its own.";
          };
        };

        # ── C26 (den-hoag-0pk67, ADR-0016 ruling 7 / ADR-0033) — A REAL `inherits` PAIR ──
        # `notch`/`dart` is the corpus's own exercise of the relocated capability, not a fixture
        # built beside it: `dart` declares no `grade` option itself, `grade` travels from `notch` by
        # NAME through this same staged pass, and `darts.chambray` below never sets it. The value
        # every `dart` instance carries for `grade` is therefore genuinely inherited, not merely a
        # name that happens to resolve.
        config.schema.notch = {
          options.grade = mkOption {
            type = types.str;
            default = "waxed";
            description = "Parent-only. No `dart` instance sets this; a resolved value is the inheritance, not a coincidence.";
          };
        };
        config.schema.dart = {
          inherits = [ "notch" ];
          options.bevel = mkOption {
            type = types.str;
            description = "The child's own attribute, declared alongside what it inherits from notch.";
          };
        };
      }
    ];
  };
in
{
  # `mkAspectModule` declares `options.aspects` and threads schema-declared options into every
  # instance. It does NOT declare `options.schema` despite what its comment in gen-aspects says, so
  # the schema option is declared here -- now as a plain read-only republication of the frozen pass
  # above, not the aspect-aware `schemaOption` itself (that lives on the staged pass's `modules`).
  imports = [ (aspectSchema.mkAspectModule { }) ];

  # Reading a strictly-earlier pass's frozen output is precisely what staging licenses; it is the
  # declaration-plane read (`config.schema.<k>` composed live) that the relocation removes.
  # Republished so `flake.nix`'s `genValues.schema.<k>` reads keep working unchanged.
  options.schema = mkOption {
    type = types.raw;
    default = schema;
    description = "The frozen result of the staged evalSchema pass above -- read-only.";
  };

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
  # cell — a throw is not a value — so it is `refusals` row 13.
  options.thimbles = genSchema.mkInstanceRegistry schema.thimble {
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
  options.bobbins = genSchema.mkInstanceRegistry schema.bobbin { };

  # C26's own registries. Kept off `haberdashery`/`declaredEdges`/the aspects tree deliberately —
  # this pair exercises the schema-inheritance capability alone, not delivery or the graph.
  options.notches = genSchema.mkInstanceRegistry schema.notch { };
  options.darts = genSchema.mkInstanceRegistry schema.dart { };

  # ── THE DELIVERY TARGET VIEW (`den-hoag-uedvp`) ──
  # `gen.nodeRegistryPath` names ONE attribute path, and that cardinality is the ruling, not a
  # limitation: a consumer has as many REGISTRIES as it declares kinds, while the delivery TARGET SET
  # is one. So the corpus declares the union of its two registries as its own option and names THAT
  # path to the hub. `haberdashery` is an invented collective and deliberately NOT the plural of a
  # kind — it is a view, not a registry, so `mkInstanceRegistry` is the wrong constructor for it.
  #
  # `mkMerge` and not `//` is the mechanism. `//` is right-wins: a node declared in both registries
  # would be silently dropped from the delivery set at exit 0 with no diagnostic. `attrsOf raw` fed by
  # `mkMerge` puts the collision on the module system's own conflicting-definitions refusal, which
  # names the offending attribute — `refusals` row 14 pins that message.
  options.haberdashery = mkOption {
    type = types.attrsOf types.raw;
    default = { };
    description = "The delivery target view: every node of both registries, under one name.";
  };

  # THE DECLARED EDGES (ADR-0012, ADR-0019). Edges are data, never read off a projection; `flake.nix`
  # unions them with the dynamic edge C5's policy program admits and queries the result as one graph.
  options.declaredEdges = mkOption {
    type = types.listOf types.raw;
    default = [ ];
    description = "Labelled { from; to; label; } relations over the node names above.";
  };

  config = {
    # THE VIEW, unioned from the two registries below.
    haberdashery = mkMerge [
      config.thimbles
      config.bobbins
    ];

    # THE TWO KINDS now live on the staged pass above, in `schema`'s `let`-bound `modules` --
    # moved verbatim out of `config` (§2.6), not declared here any more.

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

    # C26 — `chambray` sets only `bevel`; `grade` is never mentioned here or anywhere else on
    # `dart`'s own declaration. It resolves to `notch`'s default purely through `inherits` above.
    notches.khaki = { };
    darts.chambray = {
      bevel = "shallow";
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

    # den-hoag-sezf's corpus declaration (ADR-0018) — witness 1 half. `binding` is an UNDECLARED
    # freeform key (absent from `aspect-cnf.nix`'s `keySemantics`), so it falls through to the
    # plain-value merge path Arm A fixes. The SECOND definition lives in
    # `gen-modules/multidef-witness.nix`, a separate file `import-tree` loads as its own module —
    # a real cross-module collision, not one literal attrset defining a key twice. Pre-fix this
    # leaked the raw `{ _type = "merge"; contents = [...]; }` marker verbatim; post-fix it routes
    # through `merge.mergeDefaultOption` and concatenates like any other list-valued option.
    aspects.stitch.binding = [ "bias" ];

    # witness 2 half. `trim` carries a guard record (`genAspects.guard`/`pred.eq` over the corpus's
    # own `thimble` kind, the base form `whenEq` is sugar for) at the SAME freeform key, again completed in
    # `multidef-witness.nix`. Pre-fix this aborted `flatten` uncatchably; post-fix the two defs merge
    # into one fragment carrier, discharged per node downstream — at `pewter` this fragment survives
    # and the other (guarded on `damask`) does not.
    aspects.stitch.trim = genAspects.guard (genAspects.pred.eq [ "thimble" "name" ] "pewter") "piping";

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
      config.aspects.hemline.placket # a REFERENCE — resolves to the node "hemline/placket"
      ({ node, ... }: { }) # INLINE CONTENT — its POSITION is published, not an edge
      (genAspects.keyRef "mill/stitch") # a FOREIGN REFERENCE — published as a ref, never an edge
    ];
  };
}
