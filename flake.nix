{
  description = "gen-demo — the acceptance corpus for gen: gen-demo v1, one declaration per ruled construct";

  inputs = {
    # The only input of note. gen-demo consumes the hub the way den v2 will: through its published
    # surface, with no library code of its own and no direct pin on any gen-* member.
    gen.url = "github:sini/gen";

    # ★ C22's ONE EXCEPTION, AND IT IS A DIRECT SIBLING INPUT, NEVER A `follows` ONTO THE HUB.
    # The hub's own `gen-bind` has not yet been bumped past den-hoag-gcr8x's extent peer-read
    # shape (Q5 Arm A) at the time C22 is staged, and — measured this session — it CANNOT be
    # bumped by a bare relock: `mkSystemTerminal` grew a new required `class` argument in that
    # landing (`{ evaluator, locateConfig }:` at the hub's still-pinned `1f06d34…` vs.
    # `{ evaluator, locateConfig, class }:` at gcr8x's `27860c8…`), and the hub's own
    # `flakeModules/default.nix:262` default `nixos` terminal calls `mkSystemTerminal` without
    # one. A `gen.inputs.gen-bind.follows` override was tried first and DRIVEN RED: it moves the
    # hub's transitive edge globally, so its own `nixos` terminal throws that same missing-`class`
    # error, and 24 of the corpus's other checks (everything routed through the hub's default
    # delivery, not just this one) fail with it — confirmed by a same-instrument, same-run control
    # (`nix flake check`: a fresh unmodified clone exits 0 "all checks passed!"; the identical
    # clone with only the `follows` line added exits 1 on the hub's own call site). This exception
    # avoids that: C22 imports gen-bind's OWN standalone entry directly (`import "${gen-bind}" { }`,
    # the same self-resolving shim gen-bind's own `ci/flake.nix` and `gen-delivery`'s use), so the
    # hub's `genBind` module arg — and everything else built on it — never moves. Drop this input
    # once the hub's own `gen-bind` pin reaches or passes gcr8x's landed sha (which itself first
    # needs the hub's `flakeModules/default.nix:262` call site to add `class = "nixos";` — a hub-repo
    # edit outside this dispatch's scope, reported not repaired, per den-hoag-gcr8x-extent-build-v0).
    gen-bind.url = "github:sini/gen-bind";

    # The systems the one `nixos` target is built with are the hub's own nixpkgs, so
    # `--override-input gen github:sini/gen` moves the target's nixpkgs with the hub rather than
    # holding it fixed against a hub that has moved on.
    nixpkgs.follows = "gen/nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      {
        lib,
        config,
        # Read only from INSIDE a value (the `gen` merge below), never to decide this module's own
        # top-level key set — that would be circular: the module system needs this module's
        # declarations to finish computing `options`.
        options,
        genScope,
        genGraph,
        genSelect,
        genValues,
        genAlgebra,
        genBind,
        genDispatch,
        genAspects,
        ...
      }:
      let
        # `gen-view`, `gen-program` and `gen-delivery` are NOT among the eight module args
        # `flakeModules.genLibs` injects (`genAlgebra genSchema genAspects genScope genGraph genSelect
        # genBind genDispatch`, `gen/flakeModules/genLibs.nix`); they are reached through the published
        # stratum buckets instead — `substrate.view` and `framework.{program,delivery}`. `genProduct`,
        # `genMemo`, `genLink`, `genClass`, `genAssemble` and `genMerge` (v1.1) are reached the same
        # way, for the same reason.
        genView = inputs.gen.lib.substrate.view;
        genProgram = inputs.gen.lib.framework.program;
        genDelivery = inputs.gen.lib.framework.delivery;
        genProduct = inputs.gen.lib.substrate.product;
        genMemo = inputs.gen.lib.substrate.memo;
        genLink = inputs.gen.lib.aspects.link;
        genClass = inputs.gen.lib.aspects.class;
        genAssemble = inputs.gen.lib.framework.assemble;
        genMerge = inputs.gen.lib.modules.merge;

        # ── C12 — a derived product graph, and a policy-stratum promotion (ADR-0016 rulings 1
        # and 2; gen-product) — computed ahead of C1 and C5 because its promoted node joins C1's
        # node set and its promoted edges join C2's edge set, the same "one graph" discipline C5's
        # own dynamic edge already follows.
        thimbleProductGraph = genGraph.mkGraph {
          edges = [
            {
              from = "pewter";
              to = "damask";
            }
          ];
        };
        bobbinProductGraph = genGraph.mkGraph {
          edges = [
            {
              from = "grosgrain";
              to = "faille";
            }
          ];
        };
        seamSpace = genProduct.productN "cartesian" [
          {
            dim = "thimble";
            graph = thimbleProductGraph;
            key = i: i;
            entryOf = i: i;
          }
          {
            dim = "bobbin";
            graph = bobbinProductGraph;
            key = i: i;
            entryOf = i: i;
          }
        ];
        seamCell = genProduct.cell seamSpace {
          thimble = "pewter";
          bobbin = "grosgrain";
        };
        # ★ THE HEAD, THE RELATA AND THE EDGE LABELS ARE ALL READ OFF THE COORDINATE — never
        # restated as literals. Oracle 3 row C12c is the guard that catches a literal in this spot.
        seamCoords = seamSpace.product.coordsOf seamCell;
        seamHead = "seam:${seamCoords.thimble}:${seamCoords.bobbin}";

        # ── C1 — kinds and nodes (ADR-0012) ──
        # The node union across both registries, plus C12's promoted coordinate node once C5's
        # program admits it. `damask` is the one C2 reaches only across two `tacks` hops; `faille`
        # is the one no DECLARED edge reaches at all, which is what makes C5's dynamic edge
        # observable rather than a sentence.
        nodes = genValues.thimbles // genValues.bobbins // seamPromotion.nodes;

        scope = genScope.buildRoots {
          kinds = genScope.mkKinds (
            map (n: genScope.mkKind { name = n; }) [
              "thimble"
              "bobbin"
              "seam"
            ]
          );
          parentGraph = genScope.vertices (builtins.attrNames nodes);
          decls = nodes;
          types = builtins.mapAttrs (
            n: _:
            if genValues.thimbles ? ${n} then
              "thimble"
            else if genValues.bobbins ? ${n} then
              "bobbin"
            else
              "seam"
          ) nodes;
        };

        ev = genScope.eval {
          inherit scope;
          # A flat scope: nothing is contained in anything, so `children` selects nothing.
          attributes.children = _: _: { };
        };

        thimbles = builtins.attrNames (ev.nodesOfType "thimble");
        bobbinNodes = builtins.attrNames (ev.nodesOfType "bobbin");
        seamNodes = builtins.attrNames (ev.nodesOfType "seam");

        # ── C5 — a policy program producing a dynamic edge (ADR-0020, ADR-0022, ADR-0033) ──
        # Computed ahead of C2 because its output joins C2's edge set: ONE graph (ADR-0012), never a
        # second structure for the policy stratum's output. C12's promotion is a SECOND head in this
        # SAME program, never a program invented for that row.
        pipingHead = "piping:grosgrain:faille";
        prog = genProgram.program {
          frozen = [
            "pewter"
            "damask"
            "grosgrain"
            "faille"
          ]; # earlier passes settled these
          declarations = [
            {
              head = "nap:pewter";
              relata = [ "pewter" ];
            }
            {
              head = pipingHead;
              pos = [ "nap:pewter" ];
              neg = [ "scotched:pewter" ];
              relata = [
                "grosgrain"
                "faille"
              ];
            }
            {
              head = seamHead;
              pos = [ "nap:pewter" ];
              neg = [ "scotched:pewter" ];
              relata = map (d: seamCoords.${d}) seamSpace.product.dims;
            }
          ];
        };
        mdl = genProgram.model {
          program = prog;
          interpretation = [ ];
          complete = true;
        };
        # THE DYNAMIC EDGE, materialised: the atom's predicate is the label, its relata are the
        # endpoints. It keeps its own label (`piping`) rather than borrowing a declared one (`tacks`),
        # so it is never mistakable for a declaration.
        pipingEdge =
          if (mdl.resolve pipingHead).included then
            [
              {
                from = "grosgrain";
                to = "faille";
                label = "piping";
              }
            ]
          else
            [ ];
        # THE PROMOTION — a coordinate promoted into a node of the one graph by giving it edges
        # (ADR-0016 ruling 2). Both the node and its edges are read off `seamCoords`/`seamSpace`,
        # never restated as literals.
        seamPromotion =
          if (mdl.resolve seamHead).included then
            {
              nodes.${seamHead} = { };
              edges = map (d: {
                from = seamHead;
                to = seamCoords.${d};
                label = d;
              }) seamSpace.product.dims;
            }
          else
            {
              nodes = { };
              edges = [ ];
            };

        # ── C2 — edges, queried (ADR-0012, ADR-0019) ──
        # `edges` IS the one graph: what the corpus declared, plus what C5's policy stratum admitted,
        # plus C12's promoted coordinate edges.
        edges = genValues.declaredEdges ++ pipingEdge ++ seamPromotion.edges;
        byLabel = lbl: id: map (e: e.to) (builtins.filter (e: e.label == lbl && e.from == id) edges);
        lg = genGraph.labeledFrom {
          nodes = builtins.attrNames nodes;
          perLabel = {
            tacks = byLabel "tacks";
            gathers = byLabel "gathers";
            piping = byLabel "piping";
          };
        };
        # The named query: tacks*, then piping* — walks the derived label, so C5's edge changes what
        # this answers without the query ever mentioning `piping` as a declared thing.
        tacked = genGraph.query {
          graph = lg;
          from = "pewter";
          follow = genGraph.regex.seq [
            (genGraph.regex.star (genGraph.regex.lit "tacks"))
            (genGraph.regex.star (genGraph.regex.lit "piping"))
          ];
        };
        # The discriminator: `gathers` alone, so a label filter that stopped filtering is visible.
        gathered = genGraph.query {
          graph = lg;
          from = "pewter";
          follow = genGraph.regex.star (genGraph.regex.lit "gathers");
        };

        # A second door on the same declarations: gen-select, over the heterogeneous union. The
        # adapter's default `kindFor` (`_: kind`) projects one constant kind across the union and the
        # `false` arm never appears (`gen-select/lib/adapters/registry.nix`); the explicit per-id
        # `kindFor` is required because `nodes` spans two registries.
        thimbleKind = genValues.schema.thimble;
        selCtx = genSelect.adapters.registry.mkContext {
          nodes = builtins.attrNames nodes;
          data = id: nodes.${id};
          parent = _: null;
          kind = thimbleKind;
          kindFor = id: if genValues.thimbles ? ${id} then thimbleKind else genValues.schema.bobbin;
        };
        selPewter = genSelect.matches (genSelect.kind thimbleKind) "pewter" selCtx;
        selGrosgrain = genSelect.matches (genSelect.kind thimbleKind) "grosgrain" selCtx;

        # ── C3 — a binding node (ADR-0016) ──
        # THE ONE SOURCE for the labelled relata — C4's carrier reads its names, so the two
        # declarations cannot drift apart.
        bastingRelata = {
          warp = "pewter";
          weft = "grosgrain";
        };
        minted = genScope.mintStrata {
          kinds = { };
          emitters = [
            {
              pass = 0;
              identifier = "pewter";
              kind = "thimble";
              relata = { };
              content = {
                spool = "linen";
              };
              site = "c:pewter";
            }
            {
              pass = 0;
              identifier = "grosgrain";
              kind = "bobbin";
              relata = { };
              content = {
                gauge = "fine";
              };
              site = "c:gros";
            }
            {
              pass = 1;
              identifier = "basting:pewter:grosgrain";
              kind = "basting";
              content = {
                tension = "slack";
              };
              relata = bastingRelata;
              site = "c:basting";
            }
          ];
        };

        # ── C4 — a movement declaration through gen-view (ADR-0010, ADR-0024) ──
        # `carrier`'s field set is CLOSED — exactly these six. `relatumLabels` reads C3's relata names
        # by construction (`builtins.attrNames bastingRelata`), not a restated copy.
        movementLabels = genView.edgeLabels { letters = [ "tacks" ]; };
        movementCarrier = genView.carrier {
          labels = movementLabels;
          relations = genView.relations { names = [ "gimp" ]; };
          relatumLabels = genView.relatumLabels { names = builtins.attrNames bastingRelata; };
          labelWellFormedness = genView.labelWellFormedness {
            alphabet = movementLabels;
            expression = "tacks*";
          };
          labelOrder = genView.labelOrder {
            alphabet = movementLabels;
            layers = [ [ "tacks" ] ];
            endOfPath = -1;
          };
          dataOrder = genView.dataOrder {
            channel = "selvage";
            keyOf = _: "selvage";
          };
        };
        movementDefinition = genView.compositions.movement {
          channel = "selvage";
          relation = "gimp";
          root = "pewter";
          direction = "outbound";
          admission = movementCarrier.labelWellFormedness;
          order = movementCarrier.labelOrder;
          wellFormed = _: true;
          empty = [ ];
          tieSet = genView.tieSets.union;
          combine = genView.combines.listAppend;
          dedup = genView.dedups.byDatum;
        };
        movementGraph = genView.scopeGraph {
          carrier = movementCarrier;
          scopes = [
            "pewter"
            "grosgrain"
          ];
          # The walk steps on `tacks` alone — the same static edge C2 also declares — and cannot enter
          # the binding, which carries no `tacks` edge of its own.
          edges = {
            tacks = id: if id == "pewter" then [ "grosgrain" ] else [ ];
          };
          data = [
            {
              scope = "grosgrain";
              relation = "gimp";
              datum = [ "cambric" ];
            }
          ];
        };
        moved = genView.viewRelation {
          definition = movementDefinition;
          marks = _: [ ];
          graph = movementGraph;
        };

        # ── C4b — element identity: a diamond is one element, a collision is two, and a key that
        # splits an element refuses by name (ADR-0024 arm F, den-hoag-2vzn) ──
        #
        # ★★ ONE CELL CANNOT CARRY BOTH, MEASURED AT THE BINDING. `compositions.movement` fixes its
        # key to a constant (`a: _: a.channel`), so a movement declaration reaches the one-group case
        # only and cannot reach the spanning refusal at all. The spanning cell below is therefore
        # built on `compositions.registry`, whose `entityOf` is caller-supplied.
        #
        # ★★★ TWO INDEPENDENT MASKERS REDUCE A DOUBLED DIAMOND TO ONE, AND THIS DECLARATION DEFEATS
        # BOTH: an ASYMMETRIC admission (`tacks(gimping|tacks)*|gimping(tacks)*`, never the
        # symmetric `(tacks|gimping)*` a caller might reach for, which folds both arrivals to one
        # derivative-state class before the element check ever runs) and a `labelOrder` with BOTH
        # letters in ONE layer (`endOfPath = -1`) — the exact shape `gen-view/ci/fixture.nix` ships
        # as `flatOrder`. C4's own `movementCarrier` defeats neither: it declares a single-letter
        # alphabet with `layers = [ [ "tacks" ] ]` and cannot carry this cell.
        diamondLabels = genView.edgeLabels {
          letters = [
            "tacks"
            "gimping"
          ];
        };
        diamondCarrier = genView.carrier {
          labels = diamondLabels;
          relations = genView.relations { names = [ "gimp" ]; };
          relatumLabels = genView.relatumLabels { names = [ ]; };
          labelWellFormedness = genView.labelWellFormedness {
            alphabet = diamondLabels;
            expression = "tacks(gimping|tacks)*|gimping(tacks)*";
          };
          labelOrder = genView.labelOrder {
            alphabet = diamondLabels;
            layers = [
              [
                "tacks"
                "gimping"
              ]
            ];
            endOfPath = -1;
          };
          dataOrder = genView.dataOrder {
            channel = "settled";
            keyOf = _: "settled";
          };
        };

        # `pewter` reaches `grosgrain` by two routes — one `tacks` hop, one `gimping` hop — leaving
        # DIFFERENT residual admission states; one `gimp` datum authored at `grosgrain`.
        diamondGraph = genView.scopeGraph {
          carrier = diamondCarrier;
          scopes = [
            "pewter"
            "grosgrain"
            "faille"
          ];
          edges = {
            tacks = id: if id == "pewter" then [ "grosgrain" ] else [ ];
            gimping = id: if id == "pewter" then [ "grosgrain" ] else [ ];
          };
          data = [
            {
              scope = "grosgrain";
              relation = "gimp";
              datum = [ "cambric" ];
            }
          ];
        };
        diamondMoved = genView.viewRelation {
          definition = genView.compositions.movement {
            channel = "selvage";
            relation = "gimp";
            root = "pewter";
            direction = "outbound";
            admission = diamondCarrier.labelWellFormedness;
            order = diamondCarrier.labelOrder;
            wellFormed = _: true;
            empty = [ ];
            tieSet = genView.tieSets.refuse;
            combine = genView.combines.listAppend;
            dedup = genView.dedups.none;
          };
          marks = _: [ ];
          graph = diamondGraph;
        };

        # The same datum content declared at `grosgrain` TWICE and at `faille` ONCE: three
        # declarations, one content. Element identity is `(producer, ordinal)` — the declaration
        # coordinate, never path-multiplicity — so three declarations mint three elements even
        # though every one of them carries the identical datum.
        collisionGraph = genView.scopeGraph {
          carrier = diamondCarrier;
          scopes = [
            "pewter"
            "grosgrain"
            "faille"
          ];
          edges = {
            tacks =
              id:
              if id == "pewter" then
                [
                  "grosgrain"
                  "faille"
                ]
              else
                [ ];
          };
          data = [
            {
              scope = "grosgrain";
              relation = "gimp";
              datum = [ "cambric" ];
            }
            {
              scope = "grosgrain";
              relation = "gimp";
              datum = [ "cambric" ];
            }
            {
              scope = "faille";
              relation = "gimp";
              datum = [ "cambric" ];
            }
          ];
        };
        collisionMoved = genView.viewRelation {
          definition = genView.compositions.movement {
            channel = "selvage";
            relation = "gimp";
            root = "pewter";
            direction = "outbound";
            admission = diamondCarrier.labelWellFormedness;
            order = diamondCarrier.labelOrder;
            wellFormed = _: true;
            empty = [ ];
            tieSet = genView.tieSets.union;
            combine = genView.combines.listAppend;
            dedup = genView.dedups.none;
          };
          marks = _: [ ];
          graph = collisionGraph;
        };

        # ★ THE ONLY DECLARATION IN THE CORPUS THAT REACHES THE SPANNING REFUSAL. `compositions.
        # registry`'s key is caller-supplied (`entityOf`); reading the DIAMOND's own residual
        # admission state makes the two arrivals of `diamondGraph`'s one authored element carry two
        # DIFFERENT keys, which is exactly what a competition key may never do.
        splitKeyed = genView.viewRelation {
          definition = genView.compositions.registry {
            channel = "selvage";
            relation = "gimp";
            root = "pewter";
            direction = "outbound";
            admission = diamondCarrier.labelWellFormedness;
            order = diamondCarrier.labelOrder;
            wellFormed = _: true;
            empty = [ ];
            tieSet = genView.tieSets.union;
            combine = genView.combines.listAppend;
            dedup = genView.dedups.none;
            entityOf = c: c.admission;
          };
          marks = _: [ ];
          graph = diamondGraph;
        };

        # ── C17 — the identity-key set closes at the KIND boundary (ADR-0016 ruling 5, ADR-0033) ──
        # Read off the composed VALUES, not the delivery projection: an instance's `id_hash` and its
        # published key set are schema data, and the projection carries neither.
        c17Schema = inputs.gen.lib.substrate.schema;
        c17Pewter = genValues.thimbles.pewter;
        c17Thimble = genValues.schema.thimble;
        c17Bobbin = genValues.schema.bobbin;

        # ── C21 — THE CORPUS'S IDENTITY STAMP SURVIVES THE SCHEMA-INHERITANCE RELOCATION ──
        # (ADR-0016 ruling 7, ADR-0033). §2.6 of the relocation moved every kind declaration off the
        # live `config.schema.<k>` crossing and onto gen-schema's staged `evalSchema` pass, where a
        # parent travels as a NAME instead of being read out of the tree being declared. The corpus's
        # own stamp must not move across that rewrite — and the oracle must be able to SEE it move,
        # or the equality is two agreeing arms measuring nothing.
        #
        # THREE ARMS, ONE COMPOSITION ATTRIBUTE APART, over the corpus's real instrument: gen-aspects'
        # own `schemaOption`, `mkInstanceRegistry`, and C17's `extraModules` inlet.
        #   head       — the RETIRED idiom, `imports = [ config.schema.hank ]`. It is APPARATUS, not a
        #                survival of the migrated class: the reference value has to be built the old
        #                way or there is nothing for the new way to be compared against.
        #   relocated  — `inherits = [ "hank" ]`, resolved by the staged pass.
        #   no-inherit — the same staged tree with the parent dropped: the PERTURBATION.
        #
        # `hank` carries ONE primitive option, so it enters the identity key set (`name`/`selvage`/
        # `spool` against `name`/`spool`) and the stamp genuinely moves when the inheritance goes. The
        # no-inherit arm lands on
        # `thimble:d3dc9389c41b780239d34cc9e1046d74ed8ead1af294db092f7bd3e79c9cba6a` — the corpus's own
        # published stamp, the one `ci/refusals.sh` row 13 pins — which is what shows this instrument
        # is the corpus's and not a lookalike built beside it.
        #
        # Asserted RELATIONALLY and never as a literal digest: the digests this pair was designed
        # against were measured at a different lock, and pinning one here would relay a figure across
        # a rev boundary.
        c21Schema = inputs.gen.lib.substrate.schema;
        c21AspectSchema = genAspects.mkAspectSchema (import ./aspect-cnf.nix);
        c21Parent = {
          options.selvage = genMerge.mkOption {
            type = genMerge.types.str;
            default = "bound";
          };
        };
        c21ThimbleWith =
          compose:
          compose
          // {
            options.aspects = genMerge.mkOption {
              type = genMerge.types.listOf genMerge.types.str;
              default = [ ];
            };
            options.spool = genMerge.mkOption { type = genMerge.types.str; };
          };
        c21HeadSchema =
          (genMerge.evalModuleTree {
            modules = [
              { options.schema = c21AspectSchema.schemaOption; }
              (
                { config, ... }:
                {
                  config.schema.hank = c21Parent;
                  config.schema.thimble = c21ThimbleWith { imports = [ config.schema.hank ]; };
                }
              )
            ];
          }).config.schema;
        c21RelocatedSchema =
          compose:
          c21Schema.evalSchema {
            inherit (c21AspectSchema) schemaOption;
            modules = [
              {
                config.schema.hank = c21Parent;
                config.schema.thimble = c21ThimbleWith compose;
              }
            ];
          };
        c21Stamp =
          kind:
          (genMerge.evalModuleTree {
            modules = [
              { imports = [ (c21AspectSchema.mkAspectModule { }) ]; }
              {
                options.thimbles = c21Schema.mkInstanceRegistry kind {
                  extraModules = [
                    {
                      options.shirring = genMerge.mkOption {
                        type = genMerge.types.str;
                        default = "gathered";
                      };
                    }
                  ];
                };
              }
              {
                config.thimbles.pewter = {
                  aspects = [ "stitch" ];
                  spool = "linen";
                };
              }
            ];
          }).config.thimbles.pewter.id_hash;
        c21HeadIdhash = c21Stamp c21HeadSchema.thimble;
        c21RelocatedIdhash = c21Stamp (c21RelocatedSchema { inherits = [ "hank" ]; }).thimble;
        c21NoInheritIdhash = c21Stamp (c21RelocatedSchema { }).thimble;

        # ── C6 — a delivery to one target (ADR-0028) ──
        pewterClasses = builtins.attrNames config.gen.composed.hosts.pewter.classes;
        damaskClasses = builtins.attrNames config.gen.composed.hosts.damask.classes;
        stitchKeySet = builtins.attrNames config.gen.composed.aspects.stitch;

        # A SECOND ROUTE TO A PROJECTION, kept deliberately — and the cardinality is NO LONGER the
        # reason. `gen.nodeRegistryPath` names ONE attribute path because it names a delivery-target
        # VIEW and a view is singular (`den-hoag-uedvp`); the corpus declares the union of both
        # registries as `options.haberdashery` and names THAT path, so the hub now reaches every node
        # of both. What keeps this call is the reason the comment already gave second: it is the
        # corpus's only DIRECT exercise of `gen-delivery.project`'s `selectHosts` formal, which
        # survives the ruling and would be lost with the call. Calling `realize` directly is
        # rejected — it takes `terminals`, so the corpus would have to rebuild the hub's unexported
        # `terminalOf` bridge, and a corpus that reimplements the surface it tests has stopped
        # testing it. Taken instead: one extra check calling `project` directly with `selectHosts`,
        # so gen-delivery's own selector stays exercised beside the hub's option.
        bobbinProjection = genDelivery.project {
          values = genValues;
          cnf = import ./aspect-cnf.nix;
          selectHosts = v: v.bobbins or { };
        };
        bobbinProjectedNodes = builtins.attrNames bobbinProjection.nodes;

        # ── T2b — the incremental plane's byte-parity cell (ADR-0008) ──
        roster = inputs.gen.lib.mkGenLibs { inherit lib; };
        t2bCtors = {
          genMerge = roster.merge;
          genSchema = roster.schema;
          genAspects = roster.aspects;
          genTypes = roster.types;
          genPrelude = roster.prelude;
        };
        t2bBase =
          { genMerge, ... }:
          {
            options.spool = genMerge.mkOption {
              type = genMerge.types.str;
              default = "linen";
            };
          };
        t2bEdit = _: {
          config.spool = "sateen";
        };
        warmBase = inputs.gen.lib.compose {
          modules = [ t2bBase ];
          specialArgs = t2bCtors;
        };
        # `warmAdmits reuseKey edits` = `attrNames edits == [ reuseKey ]` (`gen-memo/lib/warmTrace.nix`)
        # fires on `modules` alone.
        warm = warmBase.override { modules = [ t2bEdit ]; };
        cold = inputs.gen.lib.compose {
          modules = [
            t2bBase
            t2bEdit
          ];
          specialArgs = t2bCtors;
        };

        # ── C8 — the contribution protocol (ADR-0012, ADR-0014): shape unions commutatively,
        # content folds by positional authority. Three contributions, only one carrying edges.
        c8Thimbles = {
          name = "thimbles";
          vertices = [
            "pewter"
            "damask"
          ];
          decls = {
            pewter = {
              spool = "linen";
              aspects = [ "stitch" ];
            };
            damask = {
              spool = "sateen";
              aspects = [ ];
            };
          };
        };
        c8Bobbins = {
          name = "bobbins";
          vertices = [
            "grosgrain"
            "faille"
          ];
          edgeGraphs = [
            {
              label = "tacks";
              graph = genScope.edge "pewter" "grosgrain";
            }
          ];
          decls = {
            grosgrain = {
              gauge = "fine";
            };
            faille = {
              gauge = "coarse";
            };
          };
        };
        c8Overlay = {
          name = "overlay"; # a later layer, no members of its own
          vertices = [ ];
          decls.pewter = {
            spool = "gros-de-tours";
            tacked = true;
          };
        };
        c8Contributions = [
          c8Thimbles
          c8Bobbins
          c8Overlay
        ];
        c8Assembled = genAssemble.assemble { contributions = c8Contributions; };
        c8Unioned = genAssemble.union { contributions = c8Contributions; };
        c8Permuted = genAssemble.union {
          contributions = [
            c8Overlay
            c8Thimbles
            c8Bobbins
          ];
        };

        # ── C9 — a SHARE class over declared content (ADR-0028): the class partitions on `weave`,
        # never on the kind boundary itself.
        shareProjections = {
          pewter = {
            weave = "plain";
            spool = "linen";
          };
          damask = {
            weave = "plain";
            spool = "sateen";
          };
          grosgrain = {
            weave = "twill";
            gauge = "fine";
          };
          faille = {
            weave = "twill";
            gauge = "coarse";
          };
        };
        shareClasses = genClass.mkClasses {
          nodes = shareProjections;
          keyOf = _name: p: p.weave;
        };
        plainClass = lib.findFirst (c: c.key == "plain") null shareClasses;
        plainCore = genClass.mkCore {
          class = plainClass;
          projection = "selvage";
          projections = shareProjections;
        };
        pewterShared = genClass.applyCoreMerge {
          core = plainCore;
          memberProjection = shareProjections.pewter;
        };
        plainGate = genClass.gateCore {
          core = plainCore;
          candidate = pewterShared;
          real = shareProjections.pewter;
        };
        plainInvariance = genClass.invariantUnder {
          projection = "selvage";
          projections = shareProjections;
          class = plainClass;
        };

        # ── C10 — one stratified dispatch over an invented action family (ADR-0019): each rule's
        # stratum is STAMPED by `deriveGroup` from its own declared `produces`, none written by hand.
        seamActions = genDispatch.mkActions {
          basting = [
            "tack"
            "gather"
          ];
          finishing = [ "hem" ];
        };
        seamRules = map (genDispatch.deriveGroup seamActions.groupOfKind) [
          (genDispatch.mkRule {
            identity = "tack-the-thimbles";
            produces = [ "tack" ];
            condition = {
              spool = "linen";
            };
            produce = id: _: [ (seamActions.tack { node = id; }) ];
          })
          (genDispatch.mkRule {
            identity = "hem-the-linen";
            produces = [ "hem" ];
            condition = {
              spool = "linen";
            };
            produce = id: _: [ (seamActions.hem { node = id; }) ];
          })
          (genDispatch.mkRule {
            identity = "gather-the-sateen";
            produces = [ "gather" ];
            condition = {
              spool = "sateen";
            };
            produce = id: _: [ (seamActions.gather { node = id; }) ];
          })
        ];
        seamDispatched = genDispatch.dispatch {
          rules = seamRules;
          id = "pewter";
          context = {
            spool = "linen";
          };
          match =
            cond: _id: ctx:
            cond.spool == ctx.spool;
          classify = seamActions.classify;
          groupOrder = [
            "basting"
            "finishing"
          ];
        };

        # ── C11 — a packaged subgraph, federated (ADR-0011 §4, ADR-0027). gen-link ships no
        # adapter/lens surface (measured, OPEN 2) — `link { sources; wire; }` with a per-origin
        # `keySemantics` is what it ships, and that is what this declares.
        selvageFacetOpt = genMerge.mkOption {
          type = genMerge.types.raw;
          default = null;
        };
        selvageFacets = {
          selvageCap = {
            category = "facet";
            contract = "capability";
            option = selvageFacetOpt;
          };
          selvageReq = {
            category = "facet";
            contract = "capability";
            option = selvageFacetOpt;
          };
        };
        mkSelvageRegistry =
          modules:
          let
            selvageSchema = genAspects.mkAspectSchema { keySemantics = selvageFacets; };
          in
          genMerge.evalModuleTree {
            modules = [
              { options.schema = selvageSchema.schemaOption; }
              (selvageSchema.mkAspectModule { })
            ]
            ++ modules;
          };
        mill = mkSelvageRegistry [
          {
            config.aspects.stitch.selvageCap = {
              provides = [
                "warp"
                "weft"
              ];
            };
          }
        ];
        loom = mkSelvageRegistry [
          {
            config.aspects.braid = {
              selvageReq = {
                requires = [ "warp" ];
              };
              includes = [ (genAspects.keyRef "mill/stitch") ];
            };
          }
        ];
        federated = genLink.link {
          sources = [
            {
              registry = mill.config.aspects;
              keySemantics = selvageFacets;
              origin = [ "mill" ];
            }
            {
              registry = loom.config.aspects;
              keySemantics = selvageFacets;
              origin = [ "loom" ];
            }
          ];
          wire."loom/braid".selvageReq = "mill/stitch";
        };
        selvageProvides = genLink.providesOf selvageFacets mill.config.aspects.stitch;

        # `frayed` is deliberately never added to `federated`'s `sources` below — the dangling entry
        # it carries would refuse the WHOLE `originStamp` call gen-link performs per source, so
        # folding it into the shared mill/loom federation would collaterally break every other C11
        # assertion that forces `federated` (den-hoag-lk06, mirroring the isolation gen-link's own
        # fixture keeps for the identical reason). It links alone, below.
        frayed = mkSelvageRegistry [
          {
            config.aspects.snag.includes = [ { } ];
          }
        ];

        # ── C13 — `foldLayers` over an invented layered record (ADR-0017): all three strategies
        # plus the default channel in one call, so a fold that only did `replace` would be green
        # under a broken `append`.
        weaveLayers = [
          {
            spool = "linen";
            tacks = [ "a" ];
            meta.warp = 1;
          }
          {
            spool = "sateen";
            tacks = [ "b" ];
            meta.weft = 2;
          }
        ];
        folded = genAlgebra.record.foldLayers {
          strategies = {
            tacks = "append";
            meta = "recursive";
          };
          defaults = {
            gauge = "fine";
          };
          layers = weaveLayers;
        };

        # ── C14 — the closed, first-order body-term algebra (ADR-0013 table row 2, ADR-0023). A
        # TargetId is LITERAL in the term, so no term can compute which fixpoint to read.
        selvageTerm =
          with genBind.crossing.term;
          concat [
            (lit "selvage-")
            (readFrom "pewter" [ "spool" ])
          ];
        selvageEnv = {
          targets.pewter = {
            spool = "linen";
          };
          siblings = { };
        };
        selvageChecked = genBind.crossing.checkTerm selvageTerm;
        selvageResolved = genBind.crossing.resolveTerm selvageEnv selvageTerm;
        knownFormers = genBind.crossing.knownFormers;
        crossingPrims = genBind.crossing.prims;
        inertBudget = genBind.crossing.inertBudget;
        readCtxHeadsOfSelvage = genBind.crossing.readCtxHeads selvageTerm;
        # THE THREE REFUSAL ARMS — refusals are DATA (a `__crossingResult == "refusal"` record),
        # never a throw, so all three are `checks` cells here rather than `refusals` rows.
        selvageBadLitChecked = genBind.crossing.checkTerm (
          with genBind.crossing.term; lit { spool = _: "linen"; }
        );
        selvageBadReadFromResolved = genBind.crossing.resolveTerm selvageEnv (
          with genBind.crossing.term; readFrom "sarcenet" [ "spool" ]
        );
        selvageBadVocabChecked = genBind.crossing.checkTerm { __bodyTerm = "Frobnicate"; };

        # ── C15 — the cyclic stratum, solved (ADR-0008 §2, ADR-0033). Deliberately OUTSIDE
        # `config.declaredEdges`: C7 gates that relation and it must stay acyclic, so this
        # component gets its own node names and its own accessor.
        cyclicAccessor = {
          dependencies =
            id:
            {
              chintz = [ "tulle" ];
              tulle = [
                "chintz"
                "organdy"
              ];
            }
            .${id} or [ ];
          nodeData = id: { inherit id; };
        };
        cyclicReach =
          acc: view: id:
          lib.sort (a: b: a < b) (
            lib.unique ([ id ] ++ lib.concatLists (map (d: view.${d} or [ ]) (acc.dependencies id)))
          );
        cyclicLattice = {
          bottom = [ ];
          join = a: b: lib.sort (x: y: x < y) (lib.unique (a ++ b));
          maxIter = 8;
        };
        solvedScc = genMemo.runScc genScope.ascend {
          accessor = cyclicAccessor;
          recompute = cyclicReach;
          store = { };
          scc = [
            "chintz"
            "tulle"
          ];
          higherStrata.organdy = [ "organdy" ];
          lattices = {
            chintz = cyclicLattice;
            tulle = cyclicLattice;
          };
        };

        # ── C22 — a bounded extent peer-read (ADR-0026 reuse; gen-bind's extent
        # peer-read shape, Q5 Arm A,
        # specs/2026-09-08-gen-bind-extent-peer-read-shape-spec.md, den-hoag-gcr8x).
        # Deliberately OUTSIDE `config.gen.composed`, the same way C15's cyclic stratum
        # is: its own invented nodes, its own accessor. Three nodes over one invented
        # kind, a complete peer relation, one node carrying an invented mark that
        # admits no label. The REAL `mkSystemTerminal` adapter and the REAL
        # `genDelivery.realize` (never a hand-written fold) bound the marked node's
        # handed peer set to empty and name the mark on every withheld member, while
        # the unmarked node's handed set stays the whole class.
        flounceNodes = [
          "grommet"
          "bodkin"
          "awl"
        ];
        flouncePeerGraph = genGraph.labeledFrom {
          nodes = flounceNodes;
          perLabel.kin = _id: flounceNodes;
        };
        flounceMarksOf =
          id:
          if id == "grommet" then
            [
              {
                name = "batting";
                admits = _label: false;
              }
            ]
          else
            [ ];
        flounceExtent = builtins.listToAttrs (
          map (n: {
            name = n;
            value = { };
          }) flounceNodes
        );
        flounceProjected.nodes = builtins.listToAttrs (
          map (n: {
            name = n;
            value = {
              bindings = { };
              classes.notion = [ { } ];
            };
          }) flounceNodes
        );
        # `realize`'s own per-node carriage (`{name;modules;bindings;extent;
        # extraModules;passthrough?;}`) is a different shape from the Adapter's
        # carriage (`{extent;extraModules;peerGraph;marksOf;readerId;passthrough?;
        # thunkBindings?;}`), so composing them needs the same thin wrapper gen-bind's
        # own O-1/O-2 oracle cells use (`ci/tests/crossing-extent-peer.nix`).
        #
        # `genBindNew`, NOT the hub's `genBind` module arg — see the ★ note on the
        # `gen-bind` input above. Called with `{ }`: gen-bind's own standalone root
        # entry (`default.nix`) resolves its own `prelude`/`graph` through its own
        # `ci/flake.lock`-pinned defaults, the same channel its own `ci/flake.nix`
        # and `gen-delivery`'s standalone shim use — never through the hub.
        genBindNew = import "${inputs.gen-bind}" { };
        flounceAdapterOf =
          readerId:
          (genBindNew.crossing.mkSystemTerminal {
            evaluator = a: builtins.attrNames a.specialArgs.nodes;
            locateConfig = x: x;
            class = "notion";
          }).adapter
            {
              extent = flounceExtent;
              extraModules = [ ];
              peerGraph = flouncePeerGraph;
              marksOf = flounceMarksOf;
              inherit readerId;
            };
        flounceTerminal =
          carriage:
          let
            a = flounceAdapterOf carriage.name;
          in
          a.wrapUnit (a.bindFormals carriage.bindings carriage.modules) [ ];
        flounceRealized = genDelivery.realize {
          projected = flounceProjected;
          terminals.notion = flounceTerminal;
        };

        # ── C7 — the well-definedness gate over the declared edge set (ADR-0008 §3, ADR-0030,
        # ADR-0019; gen-view). C2's OWN declarations, contracted. `mkDeclaredEdges` admits and
        # ignores the `label` field, so the corpus's edge records ride through unchanged.
        ref = genGraph.mkNodeRef { isRegistered = id: nodes ? ${id}; };
        contracted =
          es:
          genGraph.mkDeclaredEdges (
            map (
              e:
              e
              // {
                from = ref e.from;
                to = ref e.to;
              }
            ) es
          );
        gated = genView.boundedWellDefinedSchedule {
          nodes = builtins.attrNames nodes; # the registration set
          declaredDependencies = contracted genValues.declaredEdges; # NOT C2's `edges`
          equations = { }; # see OPEN 1
          admitsCycle = _: false; # nothing here is declared circular
        };
        # THE CELL READS `gated`, NOT `contracted` — see the Check. A cell over the argument
        # forces gen-graph only (already reached) and adds nothing for gen-view.
        gatedSccs = (gated.condensation).sccs;
        gatedEdges = gated.edges "pewter";

        # ── C16 — the aspect graph itself, assembled through the contribution protocol (ADR-0012,
        # ADR-0010 §3). `cnf` is the SAME value `gen.aspectCnf` above takes, bound once and reused:
        # the declaration cannot be read back out of the compose result. `genValues.aspects` is the
        # nested aspect root the corpus declares.
        c16Cnf = import ./aspect-cnf.nix;
        c16Facts = genAspects.graphFacts c16Cnf genValues.aspects;

        # CONTAINMENT travels as `parentGraph`, and the edge runs CHILD -> PARENT (gen-scope groups
        # a `P` contribution's edges by `e.from` and reads `e.to` as the parent).
        c16ParentGraph = genScope.overlays (
          map (
            id:
            let
              p = c16Facts.parentOf.${id};
            in
            if p == null then genScope.vertex id else genScope.edge id p
          ) c16Facts.nodes
        );

        # INCLUDES travels under a label of the caller's own. NOT `I` — that is gen-scope's own
        # import relation between scopes, reserved by gen-assemble at the entry.
        c16IncludesGraph = genScope.overlays (
          builtins.concatMap (id: map (t: genScope.edge id t) c16Facts.includesOf.${id}) c16Facts.nodes
        );

        c16AspectGraph = {
          name = "aspect-graph";
          vertices = c16Facts.nodes; # DECLARED membership; the only key that says a node exists
          parentGraph = c16ParentGraph;
          edgeGraphs = [
            {
              label = "declares";
              graph = c16IncludesGraph;
            }
          ];
          # A STATED PROJECTION of `nodeData`, not the raw record — `eyelet`/`includes` would
          # otherwise enter the assembly twice, once as shape and once as content, and `id_hash` is
          # internal addressing only (ADR-0016 ruling 5), read through the selector context below.
          #
          # ★ TOTAL OVER `vertices`, AND THE HETEROGENEITY IT ABSORBS IS THE LIBRARY'S OWN RULING.
          # gen-aspects' membership predicate admits a GUARD LEAF as a node — `walk.nix`, verbatim:
          # "a nested aspect or a guard leaf is a node, class content is not" — and a guard record
          # carries neither `key` nor `description`, only `{ __guard; fragments; meta; name; }`. So
          # `inherit (v) key description` was total only while this corpus declared no guard at an
          # aspect key; `aspects.stitch.trim` (den-hoag-sezf's witness 2) made it abort
          # `attribute 'description' missing`. The walk id is the right name to fall back to and not
          # merely an available one: `facts.nix` rules the node id the origin-qualified WALK POSITION
          # and deliberately NOT `identity.key`, because a guard record's minted key is its
          # predicate-and-body hash rather than its position, so `id` is the only name a guard leaf
          # has here. `description = null` is gen-aspects' own representable absence, the same answer
          # `gusset` gives for a declared-but-unset class.
          decls = builtins.mapAttrs (id: v: {
            key = v.key or id;
            description = v.description or null;
          }) c16Facts.nodeData;
        };

        # THE SECOND CONTRIBUTION — the corpus's own node registry, which already declares aspect
        # membership. The union point is only exercised because something else is in the list.
        c16RegNodes = genValues.thimbles // genValues.bobbins;
        c16Registry = {
          name = "node-registry";
          vertices = builtins.attrNames c16RegNodes;
          edgeGraphs = [
            {
              label = "members";
              graph = genScope.overlays (
                builtins.concatMap (id: map (a: genScope.edge id a) (genValues.thimbles.${id}.aspects or [ ])) (
                  builtins.attrNames genValues.thimbles
                )
              );
            }
          ];
        };

        c16Contributions = [
          c16AspectGraph
          c16Registry
        ];
        c16Union = genAssemble.union { contributions = c16Contributions; };
        c16Assembled = genAssemble.assemble { contributions = c16Contributions; };

        # ── C18 — A KINDED NODE SET, ASSEMBLED THROUGH THE CONTRIBUTION PROTOCOL ──
        #
        # C1 calls `genScope.buildRoots` DIRECTLY, and until now it had to: `assemble` supplied no
        # `kinds`, so a contribution carrying `types` was accepted at the protocol boundary and
        # refused one layer down by the substrate's registry check. A framework wanting kinded nodes
        # had to abandon the toolkit and write the constructor call itself — which is the exact
        # duplication gen-assemble exists to remove, and this corpus's C1 was the evidence.
        #
        # ★ IT IS A SECOND PATH OVER C1's OWN FACTS, NOT A SECOND C1. C1's `scope` still feeds C2,
        # C5 and C12 unchanged; moving it onto the toolkit would put a protocol change and a corpus
        # refactor in one declaration. What C18 asserts is that the two paths produce the SAME
        # RECORD, which is the two-paths-one-answer shape and is what makes README *Finding 4*'s
        # second and third clauses false.
        #
        # `c18Types` is C1's own declared kinds read back off C1's answer, so the protocol path is
        # given exactly the input the direct path was given rather than a second classifier written
        # here that could drift from it.
        c18Types = builtins.mapAttrs (_: n: n.type) scope.nodes;
        c18ThroughTheProtocol =
          types:
          genAssemble.assemble {
            contributions = [
              {
                name = "corpus";
                vertices = builtins.attrNames nodes;
                decls = nodes;
                inherit types;
              }
            ];
            kinds = genScope.mkKinds (
              map (n: genScope.mkKind { name = n; }) [
                "thimble"
                "bobbin"
                "seam"
              ]
            );
          };

        # ── the queries — §3.3's primitive table, both doors ──
        #
        # `c16Structural` is the same binding oracle 5's instance below substitutes — one call site
        # defined once and reused by both. `c16LabelGraph` reads one label's graph back off the
        # union (post-protocol); `c16Out` turns that graph into the `id -> [ids]` shape
        # `labeledFrom`'s `perLabel` wants, by the same from/to convention as containment above.
        c16Structural = genAssemble.structuralDecls c16Assembled.nodes;
        c16LabelGraph =
          label: (builtins.head (builtins.filter (g: g.label == label) c16Union.edgeGraphs)).graph;
        c16Out = g: id: map (e: e.to) (builtins.filter (e: e.from == id) g.edges);

        c16Lg = genGraph.labeledFrom {
          nodes = c16Assembled.nodeOrder;
          perLabel = {
            # THE INVERSION IS THE TOOLKIT'S, NOT HAND-ROLLED: `c16Structural.children` is
            # `genAssemble.structuralDecls`'s own `_self: id: filterAttrs (_: n: n.parent == id) nodes`.
            contains = id: builtins.attrNames (c16Structural.children null id);
            declares = c16Out (c16LabelGraph "declares");
            members = c16Out (c16LabelGraph "members");
          };
        };

        # The context is built with `parent` = the PUBLISHED `parentOf`, NOT a key split and NOT
        # `_: null` — the fix §3.4 names. `entryFor` is stated explicitly so the identity the
        # context projects is gen-aspects' own `aspectId`. `sel.kind` is left unsupported (its
        # default `null`): gen-aspects mints no kind value for an aspect node, so there is none to
        # pass and none to invent.
        c16Ctx = genSelect.adapters.registry.mkContext {
          nodes = c16Facts.nodes;
          data = id: c16Facts.nodeData.${id};
          parent = id: c16Facts.parentOf.${id};
          entryFor = id: c16Facts.nodeData.${id};
        };

        # ── oracle 5's instance — the structural-helper substitution, armed two ways ──
        #
        # C16's OWN non-flat assembly: the hand-written `children` (C1's own shape, nothing
        # contained) against the toolkit's `structuralDecls`. The node set cannot move (identity is
        # free by construction); `get`/`subtreeOf` DO move, which is the arming.
        c16ArmHand = genScope.eval {
          scope = c16Assembled;
          attributes.children = _: _: { };
        };
        c16ArmToolkit = genScope.eval {
          scope = c16Assembled;
          attributes = c16Structural;
        };

        # C1's OWN flat assembly, read as `ev`/`scope` are already bound above — never rebuilt here.
        # `structuralDecls` over C1's flat `scope.nodes` gives every node `parent == null` already,
        # so `filterAttrs (_: n: n.parent == id) nodes` is `{ }` for every id — the same answer
        # `ev`'s own hand-written `_: _: { }` gives. The node-set identity is the claim; the arming
        # pair above is what makes it non-vacuous.
        c16O5Toolkit = genScope.eval {
          inherit scope;
          attributes = genAssemble.structuralDecls scope.nodes;
        };

        # ── C19 — the discrete/monotone separation (den-hoag-0hwn; ADR-0019, ADR-0020, ADR-0012)
        #
        # Arntzenius & Krishnaswami (2016) split a typing context into a discrete ∆ and a monotone
        # Γ, and type every non-monotone operation (¬, =, a caller-supplied function) under a
        # CLEARED Γ. gen has no type-level split, so `gen-select/lib/match.nix`'s `discreteCtx`
        # clears the VALUE instead: a context declares which of its accessors read a graph still
        # under construction (`ctx.inFlight`), and the non-monotone positions — `not`, `attrs`,
        # `when`, `parentMatches` among them — refuse to observe a declared accessor rather than
        # answer against a value that has not settled.
        #
        # ONE two-node fixture, built through `adapters.registry.mkContext` like C16's own context
        # above: "b" is a child of "a", and carries `key = "b"` in its own data, under the SAME
        # condition — `builtins.elem "b" acc` — closing `parent`/`data` over one accumulator
        # rather than a live fixpoint, which is all a two-value probe needs to exhibit both the
        # answer RED gives and the refusal GREEN gives at the same read.
        c19Ctx =
          acc: inFlight:
          genSelect.adapters.registry.mkContext {
            nodes = [
              "a"
              "b"
            ];
            data = id: if id == "b" && builtins.elem "b" acc then { key = "b"; } else { };
            parent = id: if id == "b" && builtins.elem "b" acc then "a" else null;
            entryFor = _: null; # neither node is entity-backed; kind matching is not this cell's business
            inherit inFlight;
          };
        # the writable cycle §1.1 names: "a" admits "b" as a child iff "b" does NOT already carry
        # the key its own admission would give it.
        c19NegTerm = genSelect.not (genSelect.has (genSelect.attrs { key = "b"; }));

        # ── C20 — gen-select's product adapter wired to a REAL gen-product coordinate graph
        # (den-hoag-4kh.53.52 G2/G3), not a mock: C12's own `seamSpace`/`seamCell` supply
        # `coordsFor`'s real return value, so `adapters.product.mkContext` is exercised against
        # real gen-product data for the first time anywhere in the swept ecosystem. The armed
        # variant swaps in a deliberately under-applied `coordsFor` (mode C, den-hoag-g8lo) over
        # the SAME real space, to exhibit the totality door this landing added to
        # `lib/adapters/product.nix` in the same expression as the working arm.
        c20Ctx = genSelect.adapters.product.mkContext {
          cellIds = [ seamCell ];
          coordsFor = cell: seamSpace.product.coordsOf cell;
        };
        c20ArmedCtx = genSelect.adapters.product.mkContext {
          cellIds = [ seamCell ];
          coordsFor = _cell: seamSpace.product.coordsOf; # under-applied: returns a function, not coords
        };

        # ── C23 — `attrs` as a NULLARY CONTAINER STRATEGY (den-hoag-241d7, ADR-0014's constructing
        # arm + ADR-0027). The engine's `attrs` stated a checker and nothing else: no empty value and
        # no fold, so an option of that type THREW when nothing defined it — where every container
        # type yields its empty — and two modules contributing disjoint keys COLLIDED instead of
        # being unioned. A container that cannot be empty and cannot be contributed to from two
        # places is not a container, and a corpus whose modules are written by different hands hits
        # both on its first day.
        #
        # Declared on the corpus's own invented vocabulary rather than on a real option, for C15's
        # reason: a fixture that borrows a live declaration greens when something ELSE is repaired.
        c23Decl = {
          options.selvedge = genMerge.mkOption { type = genMerge.types.attrs; };
        };
        # No definition anywhere and NO `default` — the defaultless half is the whole row. A `default
        # = { }` would green this from the declaration side and say nothing about the type.
        c23Undefined = (genMerge.evalModuleTree { modules = [ c23Decl ]; }).config.selvedge;
        # Two modules, disjoint keys. The fold has to UNION them: picking either definition, or
        # refusing, is the pre-component behaviour.
        c23Disjoint =
          (genMerge.evalModuleTree {
            modules = [
              c23Decl
              { config.selvedge.warp = "flax"; }
              { config.selvedge.weft = "tussah"; }
            ];
          }).config.selvedge;

        # ── C24 — ADR-0023 (b)'s DECLARED INTERIM, PRICED ON THE CORPUS'S OWN CROSSED PAYLOAD
        # (den-hoag-9ivu, ADR-0023). Limb (b) turned the unstated crossing violations into declared
        # opt-outs with their price recorded, and site 5's price — `injectAdapter`'s, stated in
        # gen-bind's `lib/crossing-adapter-set.nix` — is the only one addressed to a CONSUMER:
        # "substrate-built gen TYPE objects cross this boundary. They are inert HERE only because
        # `_module.args` is not type-walked by the consuming module system." gen-demo is that
        # consumer, so the corpus is where the price stops being a sentence and becomes a reading.
        #
        # Sites 1 (`applyContracts`) and 4 (`configGate`) are NOT declarable here and this is not an
        # omission: each declaration's own (iii) clause states there is no crossing route through any
        # shipped Adapter to reach them by — `injectAdapter`, `mkSystemTerminal` and `mkFlakeTerminal`
        # all set `bindArgEnv = null`. Site 3 (`resolveThunks`) is already declared, by the thunk-
        # authorization rows 20/21 on the T5 plane, and site 6 (`bindFormals`) by C22's terminal.
        c24Payload = config.gen.composed.values;
        c24Crossed = (genBind.crossing.injectAdapter.bindFormals c24Payload { })._module.args;
        # Read at the crossed value's OWN TOP LEVEL, never a transitive walk: the transitive form is
        # the interim's own O-INJ-2 and lives in gen-bind, and a corpus cell restating it would be a
        # second copy of someone else's oracle rather than a consumer's reading.
        c24PlainAt = v: !(builtins.any builtins.isFunction (builtins.attrValues v));
      in
      {
        imports = [
          inputs.gen.flakeModules.default # the entry surface: gen.tree / gen.aspectCnf / systems out
          inputs.gen.flakeModules.genLibs # the roster as module args (genScope, genSchema, …)
        ];

        systems = [ "x86_64-linux" ];

        # `mkMerge` under ONE `gen` attrset, never a chain of top-level `//`: `//` shallow-updates
        # `gen` and SILENTLY DROPS the keys of the earlier operand, after which `requireCnf` fires
        # and reads exactly like a wiring failure.
        gen = lib.mkMerge [
          {
            tree = ./gen-modules;
            aspectCnf = import ./aspect-cnf.nix;
          }
          # THE NODE REGISTRY (ADR-0035): the hub no longer spells this word itself, so the corpus
          # names the attribute path of its own registry. Guarded on `options.gen ?
          # nodeRegistryPath` for the same reason `gen-schema/examples/demo` guards `aspectCnf`:
          # the option is undeclared at the committed pin, and DEFINING it there — even as `null` —
          # is itself "the option `gen.nodeRegistryPath' does not exist" (measured: exit 1 on this
          # corpus's own lock). The key is omitted outright, not conditioned false, so ARM 1 stays
          # green on the committed pin while ARM 2 exercises the option against the hub's main.
          (lib.optionalAttrs (options.gen ? nodeRegistryPath) {
            nodeRegistryPath = [ "haberdashery" ];
          })
        ];

        perSystem =
          { pkgs, ... }:
          let
            # A check is a derivation, so an assertion has to become one. `throw` rather than
            # `assert` so a red names the cell instead of printing a file position.
            asserts =
              name: cond:
              if cond then
                pkgs.runCommand "gen-demo-${name}" { } "touch $out"
              else
                throw "gen-demo: check '${name}' failed";

            # den-hoag-bl06m — this file carries TWO hand-maintained indices over its own
            # construct set (the numbered CI-contract list below, and the "## What v1 declares"
            # table), and they drifted twice in three landings because a repair fixed the one it
            # was looking at. Rather than trust either by eye, this derives BOTH from `checkNames`
            # (the evaluated `checks` attrset, including this cell's own name) and README.md's
            # OWN attribution text, and reports how many entries it scanned against how many it
            # expected — a comparison that passes without saying so is not an oracle over the set
            # it claims to cover.
            readmeIndexCheck =
              checkNames:
              pkgs.runCommand "gen-demo-construct-index"
                {
                  readme = ./README.md;
                  checkNamesFile = builtins.toFile "gen-demo-check-names.txt" (
                    builtins.concatStringsSep "\n" checkNames
                  );
                  nativeBuildInputs = [
                    pkgs.gnugrep
                    pkgs.gawk
                    pkgs.diffutils
                  ];
                }
                ''
                  set -euo pipefail

                  # surface 1: the numbered CI-contract list's own check names vs the evaluated
                  # `checks` attrset. This is the invariant the first two hand-repairs kept —
                  # deriving it means a THIRD unlisted check reds here instead of waiting on a
                  # fourth hand-repair.
                  awk '/^## The CI contract/,/^### Two arms/' "$readme" \
                    | grep -oP '^\d+\.\s+\*\*`\K[a-z0-9-]+(?=`\*\*)' | sort -u > numbered-names.txt
                  sort -u "$checkNamesFile" > expected-names.txt
                  numberedCount=$(wc -l < numbered-names.txt)
                  expectedNameCount=$(wc -l < expected-names.txt)
                  echo "numbered CI-contract list: $numberedCount names scanned against $expectedNameCount evaluated checks"
                  if ! diff -u expected-names.txt numbered-names.txt > names.diff; then
                    echo "the numbered CI-contract list disagrees with the evaluated checks attrset:"
                    cat names.diff
                    exit 1
                  fi

                  # surface 2: the "## What v1 declares" table's rows vs the construct labels the
                  # numbered list attributes each check to (the text right after its em-dash, up to
                  # the first "." or ","), plus T5 — the one construct with no check cell.
                  awk '/^## The CI contract/,/^### Two arms/' "$readme" \
                    | grep -oP '^\d+\.\s+\*\*`[a-z0-9-]+`\*\*\s+—\s+\K[^.]*?(?=[.,]|$)' \
                    | grep -oP '\bC[0-9]+b?\b|\bT[0-9]+b?\b' | sort -u > derived-constructs.txt
                  { cat derived-constructs.txt; echo T5; } | sort -u > expected-constructs.txt
                  awk '/^## What v1 declares/,/^### The naming rule/' "$readme" \
                    | grep -oP '^\| \K[A-Za-z0-9]+(?= -- )' | sort -u > table-rows.txt
                  scanned=$(wc -l < table-rows.txt)
                  expectedConstructCount=$(wc -l < expected-constructs.txt)
                  echo "'## What v1 declares' table: scanned $scanned rows against $expectedConstructCount expected constructs"
                  if ! diff -u expected-constructs.txt table-rows.txt > table.diff; then
                    echo "the table disagrees with the construct set the numbered list (by evaluation) attributes to each check:"
                    cat table.diff
                    exit 1
                  fi

                  {
                    echo "numbered CI-contract list: $numberedCount names agree with $expectedNameCount evaluated checks"
                    echo "'## What v1 declares' table: scanned $scanned rows agree with $expectedConstructCount expected constructs"
                  } > $out
                '';
          in
          {
            checks =
              let
                constructChecks = {
                  # (1) C1 + C2 — the assembled graph, queried, both doors. Red if a kind, a node, an
                  # edge, gen-scope's registration, gen-graph's query, or gen-select's second door stops
                  # working.
                  graph-query = asserts "graph-query" (
                    thimbles == [
                      "damask"
                      "pewter"
                    ]
                    &&
                      bobbinNodes == [
                        "faille"
                        "grosgrain"
                      ]
                    &&
                      tacked == [
                        "damask"
                        "faille"
                        "grosgrain"
                        "pewter"
                      ]
                    &&
                      gathered == [
                        "damask"
                        "pewter"
                      ]
                    && selPewter == true
                    && selGrosgrain == false
                  );

                  # (2) C3 — the binding node minted, identified by its labelled relata. The expected
                  # edges are read off `bastingRelata` by construction — same source C4's carrier reads —
                  # rather than restated as literal labels, so a relabelling at the shared source cannot
                  # make this check collaterally red for the wrong reason (C3 still mints; only the
                  # carrier's own disjointness is what a relabelling seed is meant to move).
                  binding-node = asserts "binding-node" (
                    builtins.attrNames minted.nodes == [
                      "basting:pewter:grosgrain"
                      "grosgrain"
                      "pewter"
                    ]
                    &&
                      minted.edges == map (l: {
                        from = "basting:pewter:grosgrain";
                        label = l;
                        to = bastingRelata.${l};
                      }) (builtins.attrNames bastingRelata)
                    && lib.hasPrefix "basting:" minted.nodes."basting:pewter:grosgrain".identity
                  );

                  # (3) C4 — the movement, and Λ read off C3's own relata.
                  movement = asserts "movement" (
                    moved.value == [ "cambric" ]
                    &&
                      builtins.attrNames bastingRelata == [
                        "warp"
                        "weft"
                      ]
                  );

                  # C4b — element identity: a diamond is one element (the two-route arrival to
                  # `grosgrain` collapses to `diamondMoved.value == [ "cambric" ]` and does not
                  # refuse under `tieSet = refuse`), and a collision is NOT a coincidence in content:
                  # `collisionGraph`'s three declarations -- two authored at `grosgrain`, one at
                  # `faille`, all three carrying the identical datum -- mint three elements, never
                  # fewer, because identity is the declaration coordinate `(producer, ordinal)` and
                  # never the content nor the path that reached it.
                  movement-element-identity = asserts "movement-element-identity" (
                    (builtins.tryEval (builtins.deepSeq diamondMoved.value diamondMoved.value)).success
                    && diamondMoved.value == [ "cambric" ]
                    && builtins.length collisionMoved.contributions == 3
                    &&
                      map (c: c.element.producer) collisionMoved.contributions == [
                        "grosgrain"
                        "grosgrain"
                        "faille"
                      ]
                    &&
                      builtins.length (
                        builtins.attrNames (
                          builtins.groupBy (e: builtins.toJSON e) (map (c: c.element) collisionMoved.contributions)
                        )
                      ) == 3
                  );

                  # registry-split-key-refuses -- named for `registry` and not for `movement`,
                  # because it declares `compositions.registry`: movement's key is a constant and
                  # cannot reach the spanning refusal at all, so a cell named `movement-...` would
                  # misname its own subject, which is the shape this library refuses elsewhere.
                  # `splitKeyed` reads the diamond's own residual admission state as its competition
                  # key, so the one authored element at `grosgrain` survives under two different
                  # keys and refuses BY NAME, catchably -- the refusal idiom is gen-demo's own,
                  # referenced rather than invented (`frayed-dangling-includes-refused` above).
                  # Live control in the same cell: the identical declaration keyed on `c.scope`
                  # instead evaluates, because both arrivals share one producer scope, and carries
                  # exactly one contribution.
                  registry-split-key-refuses = asserts "registry-split-key-refuses" (
                    !(builtins.tryEval (builtins.deepSeq splitKeyed.value splitKeyed.value)).success
                    && (
                      let
                        splitKeyedControl = genView.viewRelation {
                          definition = genView.compositions.registry {
                            channel = "selvage";
                            relation = "gimp";
                            root = "pewter";
                            direction = "outbound";
                            admission = diamondCarrier.labelWellFormedness;
                            order = diamondCarrier.labelOrder;
                            wellFormed = _: true;
                            empty = [ ];
                            tieSet = genView.tieSets.union;
                            combine = genView.combines.listAppend;
                            dedup = genView.dedups.none;
                            entityOf = c: c.scope;
                          };
                          marks = _: [ ];
                          graph = diamondGraph;
                        };
                      in
                      (builtins.tryEval (builtins.deepSeq splitKeyedControl.value splitKeyedControl.value)).success
                      && builtins.length splitKeyedControl.contributions == 1
                    )
                  );

                  # (4) C5 — the policy program's stable model, total, and the derived edge admitted.
                  policy-edge = asserts "policy-edge" (
                    (mdl.resolve pipingHead).included == true
                    && mdl.adjudication.outcome == "admitted"
                    && mdl.adjudication.searched == false
                    && mdl.adjudication.ground == "Van Gelder, Ross & Schlipf 1991, Corollary 5.6"
                  );

                  # C17 — the identity-key set is CLOSED at the kind boundary, so an option contributed on
                  # the instance side has nowhere to attach in an identity. The corpus's `thimbles` registry
                  # now carries an `extraModules` option (`shirring`); this asserts the option is really
                  # there AND that the stamp is byte-identical to the one the corpus carried before it
                  # existed. Both halves are load-bearing: the equality alone passes for a registry that
                  # dropped the caller's modules on the floor, which is a different library and a worse one.
                  #
                  # It also closes den-hoag-9l26n. `identityHashForKind` is the SOLE recompute path, and on
                  # a kind declared through gen-aspects' `schemaOption` — the shape this corpus uses, whose
                  # `options` attribute is EMPTY — it used to answer over `[ "name" ]` alone and disagree
                  # with the stamp on every instance. Since the derivation reads the kind's own evaluation
                  # it cannot disagree, and the pinned literal is what separates agreement from two
                  # derivations degenerating together.
                  #
                  # The live control is the OTHER kind: `bobbin` recomputes to its OWN stamp, over a
                  # different option set, and the two stamps differ — so the recompute is neither constant
                  # nor degenerate. (The gen-schema-DECLARED kind-value shape is controlled in gen-schema's
                  # own suite, `identity-key-closure.test-control-both-kind-value-shapes-mint-alike`; this
                  # corpus declares no such kind and inventing one here would test the fixture, not the
                  # corpus.)
                  #
                  # ★ THE WRONG-KIND ARM IS PRESENT, AND IT IS THE HALF KIND DISCOVERY ACTUALLY RUNS ON.
                  # `id-hash.nix`'s DISCOVERY PROPERTY says a recompute that does not match the carried
                  # hash means the kind guess is wrong, and a `findFirst` over candidate kinds reaches
                  # that case on nearly every candidate. Recomputing `bobbin` against a thimble instance
                  # answers `null` — *not this kind* — because a thimble carries none of `bobbin`'s
                  # identity keys; `null` is not an identity, so the loop passes over it instead of
                  # dying. This arm used to be absent and the absence was reported as a finding: the
                  # accessor was unguarded and this expression aborted `attribute 'gauge' missing`, an
                  # uncatchable interpreter error where the contract promises a value. The guard is
                  # presence-only by design, so a candidate whose key the instance CARRIES at a value the
                  # mint refuses still propagates the mint's named refusal — a different terminal state,
                  # owned by the mint, and catchable. This corpus exercises the absent-key half, which is
                  # the one discovery iterates over.
                  option-set-closure = asserts "option-set-closure" (
                    c17Pewter.shirring == "gathered"
                    && c17Pewter.id_hash == "thimble:d3dc9389c41b780239d34cc9e1046d74ed8ead1af294db092f7bd3e79c9cba6a"
                    &&
                      c17Pewter._identityKeys == [
                        "name"
                        "spool"
                      ]
                    && (c17Thimble.options or { }) == { }
                    && c17Schema.identityHashForKind c17Thimble c17Pewter == c17Pewter.id_hash
                    &&
                      c17Schema.identityHashForKind c17Bobbin genValues.bobbins.grosgrain
                      == genValues.bobbins.grosgrain.id_hash
                    && genValues.bobbins.grosgrain.id_hash != c17Pewter.id_hash
                    && c17Schema.identityHashForKind c17Bobbin c17Pewter == null
                  );

                  # (5) C6 — the delivery projection: the node set, the collected class, both Rider
                  # limbs absent from it despite both being present in the aspect body, and the bobbin
                  # door under an invented name.
                  delivery-projection = asserts "delivery-projection" (
                    builtins.attrNames config.gen.composed.hosts == [
                      "damask"
                      "faille"
                      "grosgrain"
                      "pewter"
                    ]
                    && pewterClasses == [ "nixos" ]
                    && damaskClasses == [ ]
                    &&
                      stitchKeySet == [
                        "binding"
                        "description"
                        "gusset"
                        "id_hash"
                        "includes"
                        "key"
                        "meta"
                        "name"
                        "nixos"
                        "trim"
                        "welt"
                      ]
                    # den-hoag-sezf's TWO WITNESSES, read as VALUES rather than as key names. The key
                    # set above is satisfied by a key that merged WRONGLY, so on its own it is a meter
                    # that greens on the defect; these two say what the freeform keys carry.
                    #
                    # `binding` (Arm A) — two cross-module definitions of an undeclared freeform key
                    # whose value is a list. Pre-fix the raw `{ _type = "merge"; contents = …; }`
                    # marker reached this attribute verbatim; post-fix `merge.mergeDefaultOption`
                    # concatenates in declaration order.
                    &&
                      config.gen.composed.aspects.stitch.binding == [
                        "bias"
                        "hem"
                      ]
                    # `trim` (Arm B) — two GUARD-RECORD definitions at one freeform key, merged into
                    # ONE carrier holding both fragments. Pre-fix this aborted uncatchably in
                    # `flatten`/`walk`; the bodies are read in order so a carrier that dropped or
                    # duplicated a fragment reads red.
                    &&
                      map (f: f.body) config.gen.composed.aspects.stitch.trim.fragments == [
                        "piping"
                        "cording"
                      ]
                    &&
                      bobbinProjectedNodes == [
                        "faille"
                        "grosgrain"
                      ]
                  );

                  # (6) T2b — the warm decision, byte-identical to the cold one, with the guard included:
                  # without `warm.trace.mode == "warm"` both arms could be cold and the comparison would
                  # measure nothing.
                  warm-parity = asserts "warm-parity" (
                    builtins.toJSON cold.values == builtins.toJSON warm.values
                    && builtins.toJSON cold.provenance == builtins.toJSON warm.provenance
                    && (warm.trace.mode or null) == "warm"
                    && !(cold ? trace)
                  );

                  # (7) the target instantiated, not built. Forcing the drvPath into a file runs the
                  # whole NixOS evaluation and writes the .drv, and stops there.
                  nixos-instantiate = pkgs.writeText "gen-demo-pewter-drvpath" (
                    config.flake.nixosConfigurations.pewter.config.system.build.toplevel.drvPath
                  );

                  # (8) C8 — the contribution protocol: shape unions commutatively while content folds
                  # by positional authority. Permuting `overlay` to the front is the discriminator: the
                  # node SET stays fixed, the folded `spool` does not.
                  contribution-protocol = asserts "contribution-protocol" (
                    builtins.attrNames c8Assembled.nodes == [
                      "damask"
                      "faille"
                      "grosgrain"
                      "pewter"
                    ]
                    &&
                      c8Assembled.nodeOrder == [
                        "pewter"
                        "damask"
                        "grosgrain"
                        "faille"
                      ]
                    &&
                      c8Unioned.decls.pewter == {
                        aspects = [ "stitch" ];
                        spool = "gros-de-tours";
                        tacked = true;
                      }
                    &&
                      c8Permuted.decls.pewter == {
                        aspects = [ "stitch" ];
                        spool = "linen";
                        tacked = true;
                      }
                    && map (g: g.label) c8Unioned.edgeGraphs == [ "tacks" ]
                  );

                  # (9) C9 — a SHARE class over declared content (`weave`): the "keys narrow, the gate
                  # decides" discipline asserted as both the partition and the byte gate.
                  share-class = asserts "share-class" (
                    map (c: c.key) shareClasses == [
                      "plain"
                      "twill"
                    ]
                    &&
                      map (c: c.members) shareClasses == [
                        [
                          "damask"
                          "pewter"
                        ]
                        [
                          "faille"
                          "grosgrain"
                        ]
                      ]
                    &&
                      map (c: c.archetype) shareClasses == [
                        "damask"
                        "faille"
                      ]
                    && plainCore.sharedKeys == [ "weave" ]
                    && plainCore.values == { weave = "plain"; }
                    &&
                      pewterShared == {
                        spool = "linen";
                        weave = "plain";
                      }
                    && plainGate.gate == true
                    && plainGate.candidateDigest == plainGate.realDigest
                    &&
                      plainInvariance == {
                        divergingKeys = [ "spool" ];
                        invariant = false;
                      }
                  );

                  # (10) C10 — one stratified dispatch: each rule's stratum was STAMPED by
                  # `deriveGroup` from its own declared `produces`, none written by hand; the `sateen`
                  # rule not firing against a `linen` context is the discriminator.
                  stratified-dispatch = asserts "stratified-dispatch" (
                    map (x: x.group) seamRules == [
                      "basting"
                      "finishing"
                      "basting"
                    ]
                    &&
                      seamDispatched.actions == {
                        basting = [
                          {
                            __action = "tack";
                            node = "pewter";
                          }
                        ];
                        finishing = [
                          {
                            __action = "hem";
                            node = "pewter";
                          }
                        ];
                      }
                    &&
                      seamDispatched.orderedGroups == [
                        "basting"
                        "finishing"
                      ]
                  );

                  # (11) C11 — a packaged subgraph, federated: the capability declared locally equals
                  # the capability the requirer resolves to after the exchange (ADR-0027's equivalence
                  # survival). gen-link ships no adapter/lens surface, measured (README finding), so
                  # `link` substitutes for the absent adapter.
                  federated-link = asserts "federated-link" (
                    selvageProvides == [
                      "warp"
                      "weft"
                    ]
                    &&
                      federated.resolved == {
                        "loom/braid" = [
                          "warp"
                          "weft"
                        ];
                      }
                    &&
                      builtins.attrNames federated.nodes == [
                        "loom/braid"
                        "mill/stitch"
                      ]
                    &&
                      federated.graph.edges == [
                        {
                          from = "loom/braid";
                          to = "mill/stitch";
                        }
                      ]
                    && (builtins.head federated.bound).relata == { selvageReq = "mill/stitch"; }
                    && lib.all (n: lib.hasPrefix "aspect:" n.identity) (builtins.attrValues federated.nodes)
                  );

                  # A local includes entry naming a key absent from BOTH `nodesByKey` and
                  # `refByToken` is refused by gen-link's `rewrite.originStamp`, catchably
                  # (den-hoag-lk06, ADR-0016 ruling 5). gen-aspects synthesizes a key for any bare
                  # attrset placed in `includes` regardless of what the author wrote there, so an
                  # anonymous entry and a named-but-wrong-key one are one class; `frayed` links
                  # ALONE — never joining `federated`'s sources above — for the isolation reason
                  # given at its declaration.
                  frayed-dangling-includes-refused = asserts "frayed-dangling-includes-refused" (
                    !(builtins.tryEval (
                      builtins.deepSeq
                        (genLink.link {
                          sources = [
                            {
                              registry = frayed.config.aspects;
                              keySemantics = selvageFacets;
                              origin = [ "frayed" ];
                            }
                          ];
                        }).manifest
                        true
                    )).success
                  );

                  # (12) C12 — a derived product graph and a policy-stratum promotion. The KIND is the
                  # discriminator (Oracle 3 drives this red by seeding `productN "tensor"`), and the
                  # coordinate coupling is guarded by the fact that both the head and the scope
                  # admission below are read off `seamCoords`, never restated.
                  product-promotion = asserts "product-promotion" (
                    seamSpace.product.dims == [
                      "thimble"
                      "bobbin"
                    ]
                    &&
                      map (c: "${c.thimble}*${c.bobbin}") (genProduct.cells seamSpace) == [
                        "damask*faille"
                        "damask*grosgrain"
                        "pewter*faille"
                        "pewter*grosgrain"
                      ]
                    &&
                      map (
                        cid:
                        let
                          c = genProduct.coordsOf seamSpace cid;
                        in
                        "${c.thimble}*${c.bobbin}"
                      ) (seamSpace.edges seamCell) == [
                        "damask*grosgrain"
                        "pewter*faille"
                      ]
                    && (genProduct.projectTo seamSpace "bobbin").projection.ofCell seamCell == "grosgrain"
                    && (mdl.resolve seamHead).included == true
                    && seamNodes == [ "seam:pewter:grosgrain" ]
                    &&
                      thimbles == [
                        "damask"
                        "pewter"
                      ]
                    &&
                      bobbinNodes == [
                        "faille"
                        "grosgrain"
                      ]
                  );

                  # C12c — the coordinate's PROVENANCE, standing (owner override 2026-09-14, exit
                  # sitting Q10, den-hoag-eh6x8). The fourteen other Oracle 3 rows guard a VALUE a
                  # cell already reads; a value assertion cannot tell "`seamHead` computed from
                  # `seamCoords`" apart from "`seamHead` restated as the same literal" — both
                  # evaluate to the identical string, `"seam:pewter:grosgrain"`. So this cell reads
                  # no value at all: it reads the corpus's OWN SOURCE for the one line binding
                  # `seamHead` and requires it to interpolate BOTH `seamCoords.thimble` and
                  # `seamCoords.bobbin`. A literal has no such line. Without this cell, ADR-0016
                  # ruling 2 — "the promoted node must be a function of the product or the ruling
                  # is prose" — is prose.
                  #
                  # No construction closes this without a scan: a Nix value carries no provenance
                  # once forced, so a `let`-bound RHS accepts a hand-written literal in exactly the
                  # syntactic position it accepts a derived expression, and nothing in the type or
                  # module system distinguishes them at the call site. A source-text scan is the
                  # only instrument that sees the difference; there is no by-construction fix here.
                  #
                  # Hardened 2026-09-15 against two measured gaps in the first cut:
                  #  (1) a literal with a hand-added trailing comment mentioning both coordinates
                  #      satisfied the old whole-line `hasInfix` check, because the check read the
                  #      comment text along with the code. Fixed by scanning only the code half of
                  #      the line, cut at its first `#`. That cut is UNSOUND in general — several
                  #      gen-* purity suites carry `#` inside string literals a naive cut would
                  #      swallow — but it holds for THIS line specifically: `seamHead`'s value is
                  #      built only from `seamCoords.thimble` / `.bobbin`, both plain identifiers
                  #      (`pewter`, `grosgrain`, …) with no `#` in their vocabulary, so nothing in
                  #      this line's code half can legitimately contain one. If a coordinate value
                  #      ever gains a `#`, this cut needs the real lexer the general case does.
                  #  (2) `lib.findFirst (lib.hasInfix "seamHead = ")` matched this cell's OWN quoted
                  #      search string and only read line 96 first because line 96 sorts earlier in
                  #      the file than this cell — a layout property nobody declared. Fixed by
                  #      requiring the match to be a PREFIX of the trimmed line (`seamHead = ` at
                  #      column 0, not anywhere in the line), which this cell's own code never is:
                  #      it assigns `seamHeadLine`/`codeOf`, not `seamHead`.
                  #
                  # Residual, not closed: a `seamHead` binding split across more than one line, or a
                  # legitimate coordinate value that itself contains `#`, both defeat this cell —
                  # closing either needs a real Nix lexer, not a line scan.
                  seam-head-provenance =
                    let
                      lines = lib.splitString "\n" (builtins.readFile ./flake.nix);
                      codeOf = line: lib.head (lib.splitString "#" line);
                      isSeamHeadBinding = line: lib.hasPrefix "seamHead = " (lib.trim (codeOf line));
                      seamHeadLine = lib.findFirst isSeamHeadBinding null lines;
                      seamHeadCode = if seamHeadLine == null then null else codeOf seamHeadLine;
                    in
                    asserts "seam-head-provenance" (
                      seamHeadCode != null
                      && lib.hasInfix "seamCoords.thimble" seamHeadCode
                      && lib.hasInfix "seamCoords.bobbin" seamHeadCode
                    );

                  # (13) C13 — `foldLayers`: all three strategies plus the default channel in one call.
                  layered-fold = asserts "layered-fold" (
                    folded == {
                      gauge = "fine";
                      meta = {
                        warp = 1;
                        weft = 2;
                      };
                      spool = "sateen";
                      tacks = [
                        "a"
                        "b"
                      ];
                    }
                  );

                  # (14) C14 — the closed, first-order body-term algebra: refusals are DATA, never a
                  # throw, so all three refusal arms live in this one cell rather than in
                  # `refusals` — the only construct of which that is true.
                  body-term-algebra = asserts "body-term-algebra" (
                    selvageResolved == {
                      __crossingResult = "ok";
                      value = "selvage-linen";
                    }
                    && selvageChecked.__crossingResult == "ok"
                    &&
                      knownFormers == [
                        "Lit"
                        "ReadFrom"
                        "ReadCtx"
                        "If"
                        "Attrs"
                        "List"
                        "Concat"
                        "PathJoin"
                        "Apply"
                      ]
                    &&
                      builtins.attrNames crossingPrims == [
                        "attrNames"
                        "concatStringsSep"
                        "elemAt"
                        "getAttr"
                        "length"
                        "toString"
                      ]
                    &&
                      inertBudget == {
                        maxDepth = 32;
                        maxNodes = 10000;
                      }
                    && readCtxHeadsOfSelvage == [ ]
                    && selvageBadLitChecked.refusal.code == "lit-payload-function"
                    && selvageBadLitChecked.refusal.blamed == "supplier"
                    && selvageBadReadFromResolved.refusal.code == "readfrom-names-non-member"
                    &&
                      selvageBadReadFromResolved.refusal.witness == {
                        available = [ "pewter" ];
                        target = "sarcenet";
                      }
                    && selvageBadVocabChecked.refusal.code == "term-vocabulary"
                    && selvageBadVocabChecked.refusal.witness.former == "Frobnicate"
                  );

                  # (15) C15 — the cyclic stratum, solved: both members reach each other and the
                  # external `higherStrata` supplied, by `runScc`'s iterate-from-bottom ascent rather
                  # than the acyclic rebuilder, which cannot express a cycle at all.
                  cyclic-stratum = asserts "cyclic-stratum" (
                    solvedScc == {
                      chintz = [
                        "chintz"
                        "organdy"
                        "tulle"
                      ];
                      tulle = [
                        "chintz"
                        "organdy"
                        "tulle"
                      ];
                    }
                  );

                  # extent-peer-bounded — C22, den-hoag-gcr8x. `grommet` carries the `batting`
                  # mark, which admits no label, so its handed `specialArgs.nodes` is bounded to
                  # empty; `bodkin` and `awl` carry no mark and are handed the whole class,
                  # including themselves (the relation carries self-loops). The withheld half is
                  # read straight off the adapter — bypassing `realize` — because ADR-0026's one
                  # stated requirement on a consuming implementation is that a boundary refusal
                  # NAME the mark that caused it, and `realize`'s own carriage never surfaces a
                  # withheld set at all.
                  extent-peer-bounded = asserts "extent-peer-bounded" (
                    flounceRealized.notion.grommet == [ ]
                    &&
                      flounceRealized.notion.bodkin == [
                        "awl"
                        "bodkin"
                        "grommet"
                      ]
                    &&
                      flounceRealized.notion.awl == [
                        "awl"
                        "bodkin"
                        "grommet"
                      ]
                    && (flounceAdapterOf "grommet").peerRelation.admitted == [ ]
                    &&
                      builtins.sort builtins.lessThan (
                        map (w: w.target) (flounceAdapterOf "grommet").peerRelation.withheld
                      ) == [
                        "awl"
                        "bodkin"
                        "grommet"
                      ]
                    && builtins.all (w: w.marks == [ "batting" ]) (flounceAdapterOf "grommet").peerRelation.withheld
                    && (flounceAdapterOf "bodkin").peerRelation.withheld == [ ]
                  );

                  # (16) C7 — the well-definedness gate. Fields of `gated` ITSELF, never of
                  # `contracted` (that would force gen-graph only, already reached — gate v0's
                  # CONSTRUCTION-1). Forcing `gated.condensation` and `gated.edges` also runs
                  # gen-view's own door (`graph.isDeclaredEdges`), its cyclic-SCC filter and its
                  # `admitsCycle` application — none of which gen-graph performs.
                  well-defined-schedule = asserts "well-defined-schedule" (
                    gatedSccs == [
                      [ "damask" ]
                      [ "faille" ]
                      [ "seam:pewter:grosgrain" ]
                      [ "grosgrain" ]
                      [ "pewter" ]
                    ]
                    && (builtins.filter (scc: builtins.length scc > 1) gatedSccs) == [ ]
                    &&
                      gatedEdges == [
                        "grosgrain"
                        "damask"
                      ]
                  );

                  # (17) C16 — the aspect graph, assembled through the contribution protocol (ADR-0012,
                  # ADR-0010 §3 toolkit item). The corpus's own aspect facts, contributed alongside the
                  # node registry's declared membership, queried through gen-graph's labelled graph and
                  # gen-select's context; oracle 5's structural-helper substitution armed at C16's own
                  # non-flat assembly (children/subtreeOf diverge) and at C1's flat one (the node set
                  # does not).
                  aspect-contribution = asserts "aspect-contribution" (
                    # O1/O2 — the facts are a GRAPH, and they assemble; containment survives.
                    #
                    # ★ `stitch/trim` IS A NODE, AND ITS PRESENCE IS den-hoag-sezf's WITNESS 2 READ
                    # STRUCTURALLY. `aspects.stitch.trim` is a guard record, and gen-aspects' walk
                    # admits a guard leaf as a node. Pre-fix the two cross-module definitions merged
                    # to a raw `{ _type = "merge"; contents = …; }` marker, which carries no
                    # `__guard` and is therefore NOT a guard leaf — so the node would be silently
                    # ABSENT from this list rather than present. The membership assertion below
                    # discriminates the fix from the defect on its own, without reading the value.
                    c16Facts.nodes == [
                      "bartack"
                      "hemline"
                      "hemline/facing"
                      "hemline/placket"
                      "hemline/placket/eyelet"
                      "stitch"
                      "stitch/trim"
                    ]
                    &&
                      c16Assembled.nodeOrder == [
                        "bartack"
                        "hemline"
                        "hemline/facing"
                        "hemline/placket"
                        "hemline/placket/eyelet"
                        "stitch"
                        "stitch/trim"
                        "damask"
                        "faille"
                        "grosgrain"
                        "pewter"
                      ]
                    && c16Assembled.nodes."hemline/placket".parent == "hemline"
                    &&
                      c16Assembled.nodes."hemline/placket".decls == {
                        __edges = {
                          declares = [ ];
                          members = [ ];
                        };
                        description = "Aspect placket";
                        key = "hemline/placket";
                      }
                    # …and the guard leaf's projection is PINNED rather than left to whatever the
                    # `or` fallbacks happen to produce: its `key` is its walk id (a guard record has
                    # no `key` of its own) and its `description` is the representable absence. Both
                    # arms of the projection above are therefore exercised by this cell, not just the
                    # nested-aspect one.
                    &&
                      c16Assembled.nodes."stitch/trim".decls == {
                        __edges = {
                          declares = [ ];
                          members = [ ];
                        };
                        description = null;
                        key = "stitch/trim";
                      }
                    # O3 — containment travels CHILD -> PARENT, for a guard leaf exactly as for a
                    # nested aspect: the parent comes from the walk position, not from the record's
                    # `meta`, which is what lets a guard leaf (whose `meta.loc` gen-merge stamps) hold
                    # an edge at all.
                    &&
                      c16Union.parentGraph.edges == [
                        {
                          from = "hemline/facing";
                          to = "hemline";
                        }
                        {
                          from = "hemline/placket";
                          to = "hemline";
                        }
                        {
                          from = "hemline/placket/eyelet";
                          to = "hemline/placket";
                        }
                        {
                          from = "stitch/trim";
                          to = "stitch";
                        }
                      ]
                    # O4 — includes travel under the caller's own label.
                    &&
                      map (g: g.label) c16Union.edgeGraphs == [
                        "declares"
                        "members"
                      ]
                    # O5 — the two contributions are ONE assembly, membership globally declared.
                    &&
                      c16Assembled.nodes."pewter".decls.__edges == {
                        declares = [ ];
                        members = [ "stitch" ];
                      }
                    && c16Assembled.nodes."bartack".decls.__edges.declares == [ "hemline/placket" ]
                    # O6 — the query walks the labelled graph the union produced.
                    &&
                      genGraph.query {
                        graph = c16Lg;
                        from = "hemline";
                        follow = genGraph.regex.star (genGraph.regex.lit "contains");
                      } == [
                        "hemline"
                        "hemline/facing"
                        "hemline/placket"
                        "hemline/placket/eyelet"
                      ]
                    &&
                      # `members` then `contains*` — the host's DECLARED membership followed by
                      # containment, so the closure now reaches the guard leaf under `stitch` as well
                      # as `stitch` itself. `pewter`'s own `members` edge is still the single one
                      # (asserted at O5 below); the second answer is the `contains` step, which is the
                      # point of running the star rather than a `members` literal.
                      genGraph.query {
                        graph = c16Lg;
                        from = "pewter";
                        follow = genGraph.regex.seq [
                          (genGraph.regex.lit "members")
                          (genGraph.regex.star (genGraph.regex.lit "contains"))
                        ];
                      } == [
                        "stitch"
                        "stitch/trim"
                      ]
                    &&
                      genGraph.query {
                        graph = c16Lg;
                        from = "bartack";
                        follow = genGraph.regex.seq [
                          (genGraph.regex.lit "declares")
                          (genGraph.regex.star (genGraph.regex.lit "contains"))
                        ];
                      } == [
                        "hemline/placket"
                        "hemline/placket/eyelet"
                      ]
                    &&
                      genGraph.roots (genGraph.forgetLabels c16Lg) == [
                        "bartack"
                        "damask"
                        "faille"
                        "grosgrain"
                        "hemline"
                        "pewter"
                      ]
                    &&
                      # `stitch` is no longer a leaf and that is not an omission: its guard leaf is
                      # its child, so the containment edge moved the leaf one level down.
                      genGraph.leaves (genGraph.forgetLabels c16Lg) == [
                        "damask"
                        "faille"
                        "grosgrain"
                        "hemline/facing"
                        "hemline/placket/eyelet"
                        "stitch/trim"
                      ]
                    && genGraph.cycles (genGraph.forgetLabels c16Lg) == [ ]
                    # O7 — the selector reads the PUBLISHED parent, not a key split.
                    && genSelect.matches (genSelect.descendant (genSelect.attrs {
                      key = "hemline";
                    }) genSelect.star) "hemline/placket/eyelet" c16Ctx
                    && genSelect.matches (genSelect.child (genSelect.attrs {
                      key = "hemline";
                    }) genSelect.star) "hemline/placket" c16Ctx
                    && !(genSelect.matches (genSelect.child (genSelect.attrs {
                      key = "hemline";
                    }) genSelect.star) "hemline/placket/eyelet" c16Ctx)
                    && genSelect.matches (genSelect.has (genSelect.attrs { key = "hemline/facing"; })) "hemline" c16Ctx
                    &&
                      c16Ctx.ancestors "hemline/placket/eyelet" == [
                        "hemline/placket"
                        "hemline"
                      ]
                    &&
                      c16Ctx.children "hemline" == [
                        "hemline/facing"
                        "hemline/placket"
                      ]
                    # O8 — `entryFor` is honoured and `sel.kind` is unsupported LOUDLY.
                    && !(builtins.tryEval (
                      builtins.deepSeq (genSelect.matches (genSelect.kind genValues.schema.thimble) "hemline" c16Ctx) true
                    )).success
                    && (c16Ctx.data "hemline/placket").__identity.id_hash == c16Facts.nodeData."hemline/placket".id_hash
                    && (c16Ctx.data "hemline/placket").__identity.kind == null
                    # O9 — oracle 5's instance, armed both ways.
                    && c16ArmHand.get "hemline" "children" == { }
                    &&
                      builtins.attrNames (c16ArmToolkit.get "hemline" "children") == [
                        "hemline/facing"
                        "hemline/placket"
                      ]
                    && builtins.attrNames (c16ArmHand.subtreeOf "hemline") == [ "hemline" ]
                    &&
                      builtins.attrNames (c16ArmToolkit.subtreeOf "hemline") == [
                        "hemline"
                        "hemline/facing"
                        "hemline/placket"
                        "hemline/placket/eyelet"
                      ]
                    && ev.allNodes == c16O5Toolkit.allNodes
                    &&
                      ev.allNodeIds == [
                        "damask"
                        "faille"
                        "grosgrain"
                        "pewter"
                        "seam:pewter:grosgrain"
                      ]
                    && c16O5Toolkit.allNodeIds == ev.allNodeIds
                    # comparator control, same run: two genuinely different node sets compare false.
                    && (ev.allNodeIds == c16Facts.nodes) == false
                  );

                  # (18) C16b — A FOREIGN REFERENCE IS PUBLISHED AS A REFERENCE AND NEVER AS AN EDGE.
                  # The corpus declares `keyRef "mill/stitch"` at `aspects.bartack.includes` (see
                  # `gen-modules/corpus.nix`): this file carries no `providerPrefix`, so the corpus's
                  # origin is `[ ]` — gen-link's `self`, "assigned by whoever federates me" — and the
                  # sugar's origin is its first segment, `mill`. gen-aspects cannot check that reference
                  # and no longer pretends to: it leaves `includesOf`, which now carries ONLY edges the
                  # library checked, and arrives in `foreignIncludesOf` in the declaration's own
                  # `{ origin; path; key; }` shape.
                  #
                  # ★ THIS DECLARATION WAS UNWRITABLE BEFORE. With the reference in `includesOf` it
                  # became a `declares` edge whose `to` is no vertex of this graph, and gen-assemble's
                  # `requireDeclaredMembership` refused the whole contribution by name. The cell is
                  # therefore red against the previous gen-aspects for two independent reasons: the
                  # relation it reads did not exist, and the corpus it reads did not evaluate.
                  #
                  # ★★ CARDINALITY IS STATED BECAUSE THE POPULATION IS TINY. `bartack.includes` is the
                  # only `includes` list in the whole corpus and it holds THREE positions — one checked
                  # edge, one inline body, one foreign reference. Clause 3 below is a universal over a
                  # population of ONE edge across SEVEN vertices, and a run that did not say so would
                  # be reporting a vacuous truth. Every figure here was read off this corpus, not
                  # copied — the seventh vertex is `stitch/trim`, the guard leaf den-hoag-sezf's
                  # witness 2 declares, and the totality control below covers it like any other node.
                  aspect-foreign-reference = asserts "aspect-foreign-reference" (
                    # O6a — the reference is PUBLISHED, in the declaration's own shape. Structured, not
                    # a rendered "mill/stitch": the qualifier is recoverable without re-splitting a
                    # string, which is the second source the relation exists to avoid.
                    c16Facts.foreignIncludesOf."bartack" == [
                      {
                        origin = [ "mill" ];
                        path = [ "stitch" ];
                        key = "stitch";
                      }
                    ]
                    # O6b — and it is NOT an edge. `includesOf` carries the one reference this library
                    # COULD check, and nothing else; the foreign one did not merely fail to resolve, it
                    # is not in this relation at all.
                    && c16Facts.includesOf."bartack" == [ "hemline/placket" ]
                    && !(builtins.elem "mill/stitch" c16Facts.includesOf."bartack")
                    # CONTROL: the relation is TOTAL over `nodes` — a node with no foreign reference is
                    # PRESENT with an empty list, so an absent key and "none declared" are not the same
                    # answer, and O6a above cannot be read as "the only key that exists".
                    && builtins.attrNames c16Facts.foreignIncludesOf == c16Facts.nodes
                    && c16Facts.foreignIncludesOf."stitch" == [ ]
                    # O6c — EVERY `declares` edge in the assembled contribution names a MEMBER. This is
                    # the widening `danglingIncludeRefusal` names and `requireDeclaredMembership`
                    # catches, asserted here at the contribution gen-demo actually builds.
                    && builtins.all (
                      e: builtins.elem e.from c16AspectGraph.vertices && builtins.elem e.to c16AspectGraph.vertices
                    ) (builtins.head c16AspectGraph.edgeGraphs).graph.edges
                    # CARDINALITY, all four figures from this corpus's own evaluation. The three
                    # declared positions are accounted for EXACTLY ONCE across the three relations, so
                    # neither clause above can pass by a position having been dropped.
                    && builtins.length (builtins.head c16AspectGraph.edgeGraphs).graph.edges == 1
                    && builtins.length c16AspectGraph.vertices == 7
                    && builtins.length (builtins.concatLists (builtins.attrValues c16Facts.foreignIncludesOf)) == 1
                    && builtins.length genValues.aspects.bartack.includes == 3
                    &&
                      (
                        builtins.length c16Facts.includesOf."bartack"
                        + builtins.length c16Facts.foreignIncludesOf."bartack"
                        + builtins.length c16Facts.unresolvedIncludesOf."bartack"
                      ) == 3
                    # And the assembled view is UNMOVED by the new declaration: `bartack` still declares
                    # exactly its one checked edge. The reference was added without widening the graph.
                    && c16Assembled.nodes."bartack".decls.__edges.declares == [ "hemline/placket" ]
                  );

                  # (19) C18 — A KINDED NODE SET REACHES THE ASSEMBLY THROUGH THE PROTOCOL.
                  # C1 calls `genScope.buildRoots` directly because it had to: `assemble` supplied no
                  # `kinds`, so `types` — a key the contribution record declares itself TOTAL over — was
                  # accepted at the boundary and refused one layer down. The claim is that the toolkit
                  # path and the direct path now answer the SAME RECORD over the SAME FACTS, which is
                  # what retires the corpus's own README *Finding 4*.
                  #
                  # ★ THE CELL IS RED AGAINST THE PREVIOUS gen-assemble FOR A STRUCTURAL REASON, not a
                  # value mismatch: `assemble` had no `kinds` formal, so the call below is a
                  # `called with unexpected argument 'kinds'` abort there.
                  kinded-contribution = asserts "kinded-contribution" (
                    # O1 — WHOLE-RECORD EQUALITY, both paths, C1's own facts. Not a spot-check on one
                    # field: `nodes`, `nodeOrder` and the registry itself all have to agree.
                    (c18ThroughTheProtocol c18Types) == scope
                    # ★ NEGATIVE CONTROL, SAME COMPARATOR, SAME RUN: change ONE node's kind and the
                    # equality reads false. Without it the cell passes on any comparator that says true.
                    && ((c18ThroughTheProtocol (c18Types // { damask = "bobbin"; })) == scope) == false
                    # O2 — and the kinds SURVIVE the protocol as kinds, read through the same evaluator
                    # door C1's own queries use, so the equality above is not two sides equally empty.
                    &&
                      builtins.attrNames (
                        (genScope.eval {
                          scope = c18ThroughTheProtocol c18Types;
                          attributes.children = _: _: { };
                        }).nodesOfType
                          "thimble"
                      ) == thimbles
                    # CARDINALITY, read off this corpus rather than assumed: three kinds are declared,
                    # every node carries one, and the node set is the one C1 built.
                    &&
                      builtins.attrNames (c18ThroughTheProtocol c18Types).kinds.kinds == [
                        "bobbin"
                        "seam"
                        "thimble"
                      ]
                    && builtins.all (t: t != null) (builtins.attrValues c18Types)
                    && builtins.length (builtins.attrNames c18Types) == builtins.length (builtins.attrNames nodes)
                    # O3 — `kinds` is still NOT an eighth contribution key. Offered ON a contribution it
                    # is refused by name, so the routing bought the capability without widening the
                    # record the protocol declares itself total over.
                    && !(builtins.tryEval (
                      builtins.deepSeq (genAssemble.union {
                        contributions = [
                          {
                            name = "corpus";
                            vertices = builtins.attrNames nodes;
                            kinds = genScope.mkKinds [ (genScope.mkKind { name = "thimble"; }) ];
                          }
                        ];
                      }) 1
                    )).success
                  );

                  # (20) C19 — THE DISCRETE/MONOTONE SEPARATION (den-hoag-0hwn). `sel.not` (and six
                  # more positions — `attrs`, `when`, `entity`, `kind`, `coord`, `parentMatches`) is
                  # ANTITONE in `ctx`: growing the graph under construction can flip such a
                  # selector's answer, and nothing in gen refused a negative edge in a cycle being
                  # written against it. `discreteCtx` clears a context's declared `inFlight`
                  # accessors at exactly those non-monotone positions — Datafun's discrete/monotone
                  # split (Arntzenius & Krishnaswami 2016), applied at evaluation time because gen
                  # has no type-level ∆/Γ to clear instead.
                  #
                  # O1/O2 are the writable cycle itself, both seeds: "b" is a child of "a" iff "b"
                  # does not already carry the key its own admission would give it, unstable either
                  # way (RED's own `fromEmpty=true, fromB=false`). O3/O5/O6b are the controls that
                  # keep O1/O4/O6a from reading as a blanket refusal: the class is the READ an
                  # accessor is put to, not the tag carrying it. A9 (the refusal is actionable) is
                  # NOT asserted here — `tryEval` exposes only `{success, value}`, never the thrown
                  # text — and is instead a new pairing on `ci/refusals.sh` /
                  # `ci/tests/refusals-pairing.nix` (den-hoag-9mo), alongside its existing pairings.
                  monotone-separation = asserts "monotone-separation" (
                    # O1 — the cycle REFUSES when `children` is declared in flight, at BOTH seeds
                    # (the refusal fires at `not`'s own site, before `acc` is ever read).
                    !(builtins.tryEval (
                      builtins.deepSeq (genSelect.matches c19NegTerm "a" (c19Ctx [ ] [ "children" ])) true
                    )).success
                    && !(builtins.tryEval (
                      builtins.deepSeq (genSelect.matches c19NegTerm "a" (c19Ctx [ "b" ] [ "children" ])) true
                    )).success
                    # O2 — CONTROL. the SAME selector and fixture, `inFlight = [ ]`: it ANSWERS, and
                    # the two seeds give the two values RED gives — so O1 is not a blanket refusal.
                    && genSelect.matches c19NegTerm "a" (c19Ctx [ ] [ ]) == true
                    && genSelect.matches c19NegTerm "a" (c19Ctx [ "b" ] [ ]) == false
                    # O3 — CONTROL. the Datafun-permitted case: `not` over a DISCRETE accessor
                    # (`parent`, never declared in flight) still answers inside the same in-flight
                    # context O1 refuses in.
                    &&
                      genSelect.matches (genSelect.not (genSelect.parentMatches genSelect.star)) "a" (
                        c19Ctx [ "b" ] [ "children" ]
                      ) == true
                    # O4 — `sel.when` reaching an in-flight accessor refuses with NO `not` anywhere
                    # in the term — the class is the read, not a negation syntactically present.
                    && !(builtins.tryEval (
                      builtins.deepSeq (genSelect.matches (genSelect.when (id: c: c.children id != [ ])) "a" (
                        c19Ctx [ "b" ] [ "children" ]
                      )) true
                    )).success
                    # O5 — CONTROL. a MONOTONE observation of the SAME in-flight accessor
                    # (`sel.has`, no `not`) is not refused.
                    &&
                      genSelect.matches (genSelect.has (genSelect.attrs { key = "b"; })) "a" (
                        c19Ctx [ "b" ] [ "children" ]
                      ) == true
                    # O6a — the class is the READ: `sel.attrs` refuses against an in-flight `data`.
                    && !(builtins.tryEval (
                      builtins.deepSeq (genSelect.matches (genSelect.attrs { key = "b"; }) "b" (
                        c19Ctx [ "b" ] [ "data" ]
                      )) true
                    )).success
                    # O6b — CONTROL. the SAME `sel.attrs` answers against an in-flight `children`,
                    # which `attrs` never itself observes.
                    && genSelect.matches (genSelect.attrs { key = "b"; }) "b" (c19Ctx [ "b" ] [ "children" ]) == true
                  );

                  # (24) C20 — gen-select's product adapter, real coordsOf data (den-hoag-4kh.53.52).
                  # RED (pre-landing): a malformed `coordsFor`'s result wrote straight into `__coords`
                  # and every coord-selector match against it read a plausible, silent, WRONG `false`
                  # — never a refusal (`lib/adapters/product.nix` had no door at all). GREEN: the same
                  # malformed `coordsFor` is now caught at construction, before any match runs.
                  product-adapter-totality = asserts "product-adapter-totality" (
                    # the working arm: real coordsOf flows through the adapter unchanged.
                    (c20Ctx.data seamCell).__coords == seamSpace.product.coordsOf seamCell
                    # the armed arm: the SAME real space, deliberately under-applied `coordsFor`
                    # (mode C, den-hoag-g8lo), now refuses (named throw, `tryEval`-caught) instead
                    # of writing a residual function into `__coords`.
                    && !(builtins.tryEval (builtins.deepSeq (c20ArmedCtx.data seamCell).__coords true)).success
                  );

                  # (25) C21 — the EQUALITY cell: the relocated spelling mints the stamp the retired
                  # one did. This is the half that pins what the value must be when unperturbed, and
                  # without it the discriminator below asserts nothing — a perturbation that moves a
                  # value proves nothing unless something says what the unmoved value is.
                  # DRIVEN RED: seeding gen-schema's `evalSchema` so `parentsOf` returns `[ ]` (the
                  # `inherits` built-in dropped) reds THIS cell and leaves the discriminator green.
                  corpus-stamp-relocation-invariant = asserts "corpus-stamp-relocation-invariant" (
                    c21RelocatedIdhash == c21HeadIdhash
                  );

                  # (26) C21 — the PERTURBATION arm, and it is what stops the cell above being two
                  # agreeing arms. Drop the inheritance from the staged tree and the stamp MOVES, so
                  # the equality is non-vacuous: the instrument is shown to discriminate on the exact
                  # axis the equality asserts, rather than asserted to.
                  # DRIVEN RED: making `hank`'s option `internal` (so the parent contributes no
                  # identity key) reds THIS cell and leaves the equality green.
                  corpus-stamp-no-inherit-discriminator = asserts "corpus-stamp-no-inherit-discriminator" (
                    c21NoInheritIdhash != c21HeadIdhash
                    # ★ AND THE INSTRUMENT IS THE CORPUS'S, ASSERTED RATHER THAN DOCUMENTED. Strip the
                    # inheritance and this tree must collapse onto the LIVE corpus node's own stamp —
                    # `genValues.thimbles.pewter`, the same value C17 pins and `ci/refusals.sh` row 13
                    # asserts. Without this conjunct the two cells above measure a tree that differs
                    # from the corpus by exactly the parent, while the README row and this construct's
                    # header state the invariant over THE CORPUS: an author editing `c21ThimbleWith`'s
                    # option set moves all three arms together, both cells stay green, and the stated
                    # proposition goes false with nothing red. Relational — `c17Pewter.id_hash`, never
                    # a digest literal — so the no-literals ruling is untouched.
                    && c21NoInheritIdhash == c17Pewter.id_hash
                  );

                  # (30) C23 — an undefined, defaultless `attrs` option IS the empty container, not a
                  # throw. Reads the VALUE and not a `tryEval` success bit: the failure this cell has
                  # to catch is a repair that makes the option resolve to `null`, or to a nested
                  # shape, while still "succeeding" — a bit-reading cell passes all of those.
                  # DRIVEN RED: dropping `whenEmpty.value` from the construction reds THIS cell and
                  # leaves the union cell below green.
                  attrs-undefined-yields-empty = asserts "attrs-undefined-yields-empty" (c23Undefined == { });

                  # (31) C23 — two modules contributing DISJOINT keys to one `attrs` option both
                  # survive. The empty value alone does not buy this: a type can state an empty and
                  # still have no fold, and then the corpus's second contributor is the one that
                  # reds. Pinned as an equality over the whole attrset rather than a key-presence
                  # test, so a fold that unions the keys but loses a VALUE is caught here too.
                  # DRIVEN RED: a fold returning one definition reds THIS cell and leaves the
                  # empty-value cell above green.
                  attrs-unions-disjoint-contributions = asserts "attrs-unions-disjoint-contributions" (
                    c23Disjoint == {
                      warp = "flax";
                      weft = "tussah";
                    }
                  );

                  # (32) C24 — ADR-0023 (b)'s interim price, read by the consumer that pays it
                  # (den-hoag-9ivu). Four arms, and the first two are a matched pair so neither can
                  # pass for the wrong reason: the crossed payload is NOT all-plain at a position the
                  # SUBSTRATE writes (`schema.thimble` carries gen-schema's own `__functor`), while a
                  # position the substrate writes as data IS plain (`thimbles.pewter`) — a predicate
                  # that called everything impure would satisfy the first arm alone.
                  # The remaining two are the crossing itself: plain data arrives verbatim, and the
                  # closure arrives EXECUTABLE — applying it inside this evaluation is the price's own
                  # words ("a substrate closure executes in the target"), not an inference from a type.
                  # RED (what this cell exists to catch): the interim ending unannounced. If site 5
                  # ever narrows to provably-plain-data — ADR-0023 (c), den-hoag-i546n — the closure
                  # stops crossing and this cell reds, which is the corpus noticing that the declared
                  # opt-out it records is no longer the system's behaviour.
                  injection-payload-price = asserts "injection-payload-price" (
                    !(c24PlainAt c24Payload.schema.thimble)
                    && c24PlainAt c24Payload.thimbles.pewter
                    && c24Crossed.declaredEdges == c24Payload.declaredEdges
                    && (c24Crossed.schema.thimble { }) ? imports
                  );
                };
              in
              constructChecks
              // {
                construct-index = readmeIndexCheck (builtins.attrNames constructChecks ++ [ "construct-index" ]);
              };
          };
      }
    );
}
