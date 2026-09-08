{
  description = "gen-demo — the acceptance corpus for gen: one kind, one node, one query, one target";

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
        config,
        genScope,
        genValues,
        ...
      }:
      let
        # ── THE ONE QUERY, evaluated by gen-scope ──
        # ADR-0006: gen-scope is the sole evaluator. The corpus therefore asks its question of
        # gen-scope rather than of Nix — the node set is registered as a scope, the kind vocabulary
        # is registered with it, and the answer is read back off the evaluation's own accessor.
        # `nodesOfType` is "the nodes of that kind" and nothing else.
        scope = genScope.buildRoots {
          kinds = genScope.mkKinds [ (genScope.mkKind { name = "thimble"; }) ];
          parentGraph = genScope.vertices (builtins.attrNames genValues.hosts);
          decls = genValues.hosts;
          types = builtins.mapAttrs (_: _: "thimble") genValues.hosts;
        };

        thimbles = builtins.attrNames (
          (genScope.eval {
            inherit scope;
            # A flat scope: nothing is contained in anything, so `children` selects nothing.
            attributes.children = _: _: { };
          }).nodesOfType
            "thimble"
        );
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
              # (1) the assembled graph, queried. Red if the kind, the node, or gen-scope's
              # registration of either stops working.
              graph-query = asserts "graph-query" (thimbles == [ "pewter" ]);

              # (2) the delivered projection for the one target: the node projected, and the `nixos`
              # class collected onto it. Red if the declared category stops reaching the projection —
              # the failure mode that reads as an empty `nixosConfigurations` rather than an error.
              delivery-projection = asserts "delivery-projection" (
                builtins.attrNames config.gen.composed.hosts == [ "pewter" ]
                && config.gen.composed.hosts.pewter.classes ? nixos
              );

              # (3) the target instantiated, not built. Forcing the drvPath into a file runs the
              # whole NixOS evaluation and writes the .drv, and stops there.
              nixos-instantiate = pkgs.writeText "gen-demo-pewter-drvpath" (
                config.flake.nixosConfigurations.pewter.config.system.build.toplevel.drvPath
              );
            };
          };
      }
    );
}
