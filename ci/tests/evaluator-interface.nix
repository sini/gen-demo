{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      system,
      config,
      ...
    }:
    let
      harness = inputs.gen-harness;
      aggregate = config.packages.evaluators;
      published = harness.lib.checks.evaluators { inherit pkgs system; };
      # Package identities come from the caller's input graph, independently of the aggregate.
      packages = {
        nix = harness.inputs.nix-upstream.packages.${system}.nix-cli;
        determinate = harness.inputs.nix-determinate.packages.${system}.nix-cli;
        lix = harness.inputs.nix-lix.packages.${system}.default;
      };
      manifest = pkgs.writeText "evaluator-identities.json" (
        builtins.toJSON (
          builtins.mapAttrs (_: package: {
            executable = "${package}/bin/nix";
            version = package.version;
          }) packages
        )
      );
      closure = pkgs.closureInfo { rootPaths = [ aggregate ]; };
    in
    {
      checks.evaluator-interface =
        assert aggregate.drvPath == published.drvPath;
        pkgs.runCommand "gen-demo-evaluator-interface" { nativeBuildInputs = [ pkgs.python3 ]; } ''
          export HOME="$TMPDIR/home" XDG_CACHE_HOME="$TMPDIR/cache"
          mkdir -p "$HOME" "$XDG_CACHE_HOME"
          python3 ${../evaluator-interface.py} ${aggregate} ${manifest} ${closure}/store-paths > "$out"
          cat "$out"
        '';
    };
}
