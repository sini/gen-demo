{
  description = "gen-demo — the acceptance corpus for gen: gen-demo v1, one declaration per ruled construct";

  inputs = {
    # The only input of note. gen-demo consumes the hub the way den v2 will: through its published
    # surface, with no library code of its own and no direct pin on any gen-* member.
    gen.url = "github:sini/gen";

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
        genScope,
        genGraph,
        genSelect,
        genValues,
        ...
      }:
      let
        # `gen-view`, `gen-program` and `gen-delivery` are NOT among the eight module args
        # `flakeModules.genLibs` injects (`genAlgebra genSchema genAspects genScope genGraph genSelect
        # genBind genDispatch`, `gen/flakeModules/genLibs.nix`); they are reached through the published
        # stratum buckets instead — `substrate.view` and `framework.{program,delivery}`.
        genView = inputs.gen.lib.substrate.view;
        genProgram = inputs.gen.lib.framework.program;
        genDelivery = inputs.gen.lib.framework.delivery;

        # ── C1 — kinds and nodes (ADR-0012) ──
        # The node union across both registries. `damask` is the one C2 reaches only across two
        # `tacks` hops; `faille` is the one no DECLARED edge reaches at all, which is what makes C5's
        # dynamic edge observable rather than a sentence.
        nodes = genValues.hosts // genValues.bobbins;

        scope = genScope.buildRoots {
          kinds = genScope.mkKinds (
            map (n: genScope.mkKind { name = n; }) [
              "thimble"
              "bobbin"
            ]
          );
          parentGraph = genScope.vertices (builtins.attrNames nodes);
          decls = nodes;
          types = builtins.mapAttrs (n: _: if genValues.hosts ? ${n} then "thimble" else "bobbin") nodes;
        };

        ev = genScope.eval {
          inherit scope;
          # A flat scope: nothing is contained in anything, so `children` selects nothing.
          attributes.children = _: _: { };
        };

        thimbles = builtins.attrNames (ev.nodesOfType "thimble");
        bobbinNodes = builtins.attrNames (ev.nodesOfType "bobbin");

        # ── C5 — a policy program producing a dynamic edge (ADR-0020, ADR-0022, ADR-0033) ──
        # Computed ahead of C2 because its output joins C2's edge set: ONE graph (ADR-0012), never a
        # second structure for the policy stratum's output.
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

        # ── C2 — edges, queried (ADR-0012, ADR-0019) ──
        # `edges` IS the one graph: what the corpus declared, plus what C5's policy stratum admitted.
        edges = genValues.declaredEdges ++ pipingEdge;
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
          kindFor = id: if genValues.hosts ? ${id} then thimbleKind else genValues.schema.bobbin;
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

        # ── C6 — a delivery to one target (ADR-0028) ──
        pewterClasses = builtins.attrNames config.gen.composed.hosts.pewter.classes;
        damaskClasses = builtins.attrNames config.gen.composed.hosts.damask.classes;
        stitchKeySet = builtins.attrNames config.gen.composed.aspects.stitch;

        # The registry stays spelled `hosts` (den-hoag-hub-hardcodes-hosts-mxpd5: the hub's `project`
        # call carries no `selectHosts`, so any other name projects empty with no error). Calling
        # `realize` directly is rejected — it takes `terminals`, so the corpus would have to rebuild
        # the hub's unexported `terminalOf` bridge, and a corpus that reimplements the surface it
        # tests has stopped testing it. Taken instead: one extra check calling `project` directly with
        # `selectHosts` naming the second registry under a name the hub does not impose.
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
      in
      {
        imports = [
          inputs.gen.flakeModules.default # the entry surface: gen.tree / gen.aspectCnf / systems out
          inputs.gen.flakeModules.genLibs # the roster as module args (genScope, genSchema, …)
        ];

        systems = [ "x86_64-linux" ];

        gen.tree = ./gen-modules;
        gen.aspectCnf = import ./aspect-cnf.nix;

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
          in
          {
            checks = {
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
                && minted.nodes."basting:pewter:grosgrain" ? identity
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

              # (4) C5 — the policy program's stable model, total, and the derived edge admitted.
              policy-edge = asserts "policy-edge" (
                (mdl.resolve pipingHead).included == true
                && mdl.adjudication.outcome == "admitted"
                && mdl.adjudication.searched == false
              );

              # (5) C6 — the delivery projection: the node set, the collected class, both Rider
              # limbs absent from it despite both being present in the aspect body, and the bobbin
              # door under an invented name.
              delivery-projection = asserts "delivery-projection" (
                builtins.attrNames config.gen.composed.hosts == [
                  "damask"
                  "pewter"
                ]
                && pewterClasses == [ "nixos" ]
                && damaskClasses == [ ]
                &&
                  stitchKeySet == [
                    "description"
                    "gusset"
                    "id_hash"
                    "includes"
                    "key"
                    "meta"
                    "name"
                    "nixos"
                    "welt"
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
            };
          };
      }
    );
}
