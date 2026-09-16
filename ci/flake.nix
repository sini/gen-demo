{
  inputs = {
    gen-harness.url = "github:sini/gen-harness";
    # nixpkgs is the CI runner's dependency (test harness + treefmt) and supplies the `lib` the
    # one test module uses. It is deliberately NOT `follows`-ed onto the root flake's `gen/nixpkgs`:
    # the corpus's nixpkgs moves with the hub under `check-hub-main`, and the instrument that
    # measures the corpus must not move with the thing it measures.
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
  };

  outputs =
    inputs@{ gen-harness, ... }:
    gen-harness.lib.mkCi {
      inherit inputs;
      name = "gen-demo";
      testModules = ./tests;
      # `ci/refusals.sh` is read by `tests/refusals-pairing.nix`, so it is declared: the guard's
      # subject is the bytes the evaluator sees, and an untracked script would give the cell a
      # different file from the one the commit carries. `worktree-precommit-check.sh` is declared for
      # the same reason: it is the artefact the `worktree-check` command executes, so the evaluator
      # must reach the committed bytes rather than whatever the working tree happens to hold.
      readRoots = [
        ./refusals.sh
        ./worktree-precommit-check.sh
      ];
      extraModules = [
        # gen-demo is the ACCEPTANCE CORPUS, not an ecosystem library: it is absent from the
        # register roster (`gen/lib/mkGenLibs.nix`) and unreferenced by the hub, so no capability
        # sheet is owed. Recorded as a declaration rather than left silent, so the absence reads
        # as a decision (owner, 2026-09-14).
        { gen.ci.agentsMd.sheet = "not-owed"; }

        # The corpus-specific half of the command surface. gen-harness supplies `ci`, `fmt` and
        # `repl`; a consuming module adds what only it needs, which is the pattern the hub's own
        # `ci/flake.nix` follows. These four are `den-hoag-g87v` term 2's contract — the two check
        # arms, the one built target, and the deliberate relock — written where a shared instrument
        # can reach them instead of in a justfile nothing schedules.
        {
          perSystem = {
            devshells.default.commands = [
              {
                name = "check-lock";
                help = "ARM 1 - the corpus against the committed flake.lock, the last-green pin";
                command = ''
                  cd "$FLAKE_ROOT" && nix flake check
                '';
              }
              {
                name = "check-hub-main";
                help = "ARM 2 - the corpus against the hub's current main, so a hub landing that breaks it reads red before the relock";
                command = ''
                  cd "$FLAKE_ROOT" && nix flake check --refresh --override-input gen github:sini/gen
                '';
              }
              {
                name = "build-target";
                help = "NOT a check - the full build of the one nixos target, on demand";
                command = ''
                  cd "$FLAKE_ROOT" && nix build .#nixosConfigurations.pewter.config.system.build.toplevel
                '';
              }
              {
                name = "relock";
                help = "Advance the hub pin deliberately; both check arms must be green before it lands";
                command = ''
                  cd "$FLAKE_ROOT" && nix flake update gen
                '';
              }
              {
                name = "refusals";
                help = "The T5 plane (ADR-0025) - every enforcer planted and unplanted, refused BY NAME";
                command = ''
                  exec "$FLAKE_ROOT/ci/refusals.sh"
                '';
              }
              {
                name = "worktree-check";
                help = "den-hoag-0gsn0's declaration - a linked worktree self-provisions its pre-commit config on checkout";
                command = ''
                  exec "$FLAKE_ROOT/ci/worktree-precommit-check.sh"
                '';
              }
            ];
          };
        }
      ];
    };
}
