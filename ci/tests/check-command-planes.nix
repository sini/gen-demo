# The PLANE-COVERAGE discipline of the check commands, held to a cell (`den-hoag-dq6mw`).
#
# `nix flake check` covers the flake its argument names and no other. This repository has two —
# the root flake's corpus cells and `ci/`'s six harness cells — so a command running
# one form produces a green over a population it never touched. Driven at `b1843a5`: with the
# `refusals` pairing cell seeded red, root `nix flake check` returned rc 0 and "all checks
# passed!" while `nix flake check ./ci` returned rc 1, on one tree in one run. `check-lock` ran
# the root form only, so "check-lock is green" read as suite cover and was not.
#
# The landing widened both commands' domain. This cell is what keeps it widened: the narrowing is
# a one-line deletion, it leaves every other check green, and nothing else in this repository
# would see it — the green a narrowed `check-lock` prints is indistinguishable from the green a
# correct one prints. That is the same shape as the class `ci-plane-coverage.nix` exists for, and
# that class was discharged once and re-opened six days later, which is why the guard is a
# standing cell and not a comment.
#
# THE UNIT IS THE COMMAND, NOT THE FILE. A file-wide count of `./ci` occurrences passes while one
# of the two arms carries both and the other carries neither. The scan therefore attributes each
# executing `nix flake check` line to the command whose `name =` most recently opened, and the
# two figures fail distinguishably: a command that loses an arm stays in `commands` and leaves
# `twoPlane`, a command deleted outright leaves both, and a third check command added without
# thinking about planes joins `commands` alone. Neither figure is a bare boolean.
#
# COMMENT LINES ARE EXCLUDED, and the exclusion is load-bearing rather than tidy: the commands'
# own comments quote both forms verbatim to explain them, so a scan that read them would find
# every arm present in a file where none ran. `ci-plane-coverage.nix` states the same condition
# first for the same reason.
#
# `ci/flake.nix` is NOT added to `readRoots`. That guard exists to catch a read of an UNTRACKED
# file, and this one cannot be untracked: nix evaluates a git flake from its tracked tree, so
# `nix flake check ./ci` could not have reached this cell at all if `ci/flake.nix` were missing
# from the index. The guarantee is structural here and a declaration would only restate it.
{ lib, ... }:
let
  lines = lib.splitString "\n" (builtins.readFile ../flake.nix);

  nameOf =
    l:
    let
      m = builtins.match ''.*name = "([a-z-]+)";.*'' l;
    in
    if m == null then null else builtins.head m;

  step =
    acc: l:
    let
      n = nameOf l;
      isComment = builtins.match "[[:space:]]*#.*" l != null;
      prev =
        acc.arms.${acc.current} or {
          root = false;
          ci = false;
        };
    in
    if n != null then
      acc // { current = n; }
    else if isComment || !(lib.hasInfix "nix flake check" l) then
      acc
    else
      acc
      // {
        arms = acc.arms // {
          ${acc.current} =
            if lib.hasInfix "nix flake check ./ci" l then prev // { ci = true; } else prev // { root = true; };
        };
      };

  # `current` starts at a name no command can have, so a `nix flake check` line standing outside
  # every command body is attributed to it and fails the cell rather than being silently folded
  # into whichever command happened to be declared last.
  final = lib.foldl' step {
    current = "<outside any command>";
    arms = { };
  } lines;
in
{
  flake.tests.check-command-planes = {
    test-every-flake-check-command-runs-both-planes = {
      expr = {
        commands = builtins.attrNames final.arms;
        twoPlane = builtins.attrNames (lib.filterAttrs (_: a: a.root && a.ci) final.arms);
      };
      expected = {
        commands = [
          "check-hub-main"
          "check-lock"
        ];
        twoPlane = [
          "check-hub-main"
          "check-lock"
        ];
      };
    };
  };
}
