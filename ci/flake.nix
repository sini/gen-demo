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

        # The corpus-specific half of the command surface. gen-harness supplies `ci`, `relock`,
        # `fmt` and `repl`; a consuming module adds what only it needs, which is the pattern the
        # hub's own `ci/flake.nix` follows. The first three below are `den-hoag-g87v` term 2's
        # contract — the two lock arms and the one built target — written where a shared instrument
        # can reach them instead of in a justfile nothing schedules. Term 2 names no relock: bumping
        # the hub pin is `relock gen`, the shipped command, and a local declaration of a name mkCi
        # already ships collides in buildEnv rather than overriding it.
        {
          perSystem = {
            devshells.default.commands = [
              # ★ BOTH ARMS RUN BOTH PLANES, and that is the whole of den-hoag-dq6mw. This
              # repository carries TWO check planes — the root flake's forty-two corpus cells and
              # `./ci`'s six harness cells — and `nix flake check` names only the one its argument
              # points at. Driven at `b1843a5`, one tree one run: with the nix-unit pairing cell
              # seeded red, root `nix flake check` returned rc 0 and printed "all checks passed!"
              # while `nix flake check ./ci` returned rc 1. So a command that ran the root form
              # alone produced a green that ranged over a population it never touched, and
              # "check-lock is green" read as suite cover when it was not.
              #
              # The remedy is the DOMAIN, not the name: a rename would only make the misreading
              # harder, and would still leave a person able to run one command and quote it for
              # both planes. Each arm runs both forms, reports both exit codes, and exits non-zero
              # if either did — so its green is the thing anyone would take it for.
              #
              # ★ `|| rc=$?` AND NOT `cmd; rc=$?`, because numtide devshell emits `set -euo
              # pipefail` at the head of every command script. Measured on the built wrapper at
              # `/nix/store/54wppsanda76vcy4v1x7dz5sr6m2pvh6-check-lock/bin/check-lock`: the
              # `cmd; rc=$?` spelling of this same body ran the root plane, then exited the instant
              # the `./ci` plane reded and printed no summary line at all — so a root failure would
              # have suppressed the second plane entirely, which is this row's own defect one level
              # down. A command on the left of `||` is exempt from errexit; that is the whole
              # reason for the spelling. (gen-harness's `ci` command carries a comment asserting
              # these scripts are NOT under `set -e` — the code there is unaffected, but the stated
              # ground is wrong, and believing it is what produced the first spelling.)
              {
                name = "check-lock";
                help = "ARM 1 - both planes, FULL BUILD, against the committed flake.lock, the last-green pin. CI's own 'ARM 1' step (.github/workflows/ci.yml) runs eval-only over the root plane alone — a CI green does not cover everything this command does.";
                command = ''
                  cd "$FLAKE_ROOT" || exit
                  root=0; nix flake check --keep-going || root=$?
                  plane=0; nix flake check ./ci --keep-going || plane=$?
                  echo "check-lock: root=$root ci=$plane"
                  [ "$root" -eq 0 ] && [ "$plane" -eq 0 ]
                '';
              }
              {
                name = "check-hub-main";
                help = "ARM 2 - both planes, the corpus against the hub's current main, so a hub landing that breaks it reads red before the relock";
                command = ''
                  cd "$FLAKE_ROOT" || exit
                  hub=0; nix flake check --refresh --override-input gen github:sini/gen --keep-going || hub=$?
                  # NO override on this line, deliberately: the harness plane declares `gen-harness`
                  # and `nixpkgs` and no `gen` at all, so it does not move with the hub. Measured at
                  # `b1843a5`: `nix flake check ./ci --override-input gen github:sini/gen` warns
                  # "override for a non-existent input 'gen'" and exits 0 — inert, so carrying it
                  # would be noise that reads like coverage. `--refresh` is omitted for the same
                  # reason: there is no hub input here to refresh.
                  plane=0; nix flake check ./ci --keep-going || plane=$?
                  echo "check-hub-main: hub=$hub ci=$plane"
                  [ "$hub" -eq 0 ] && [ "$plane" -eq 0 ]
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
