# The T5 plane's PAIRING DISCIPLINE, held to a cell.
#
# `ci/refusals.sh` runs every enforcer BOTH planted and unplanted, and its own header states why:
# "a construction that refused unconditionally would pass the planted arm for the wrong reason."
# Row 16 is the live proof that this is load-bearing rather than tidy — the defect it caught exited
# 1 on BOTH arms, so the planted arm's exit code alone would have passed it, and only the message
# grep discriminated. The discipline is therefore a property of the fixture, not of any one row,
# and a row that quietly loses an arm is exactly the regression nothing else in this repository
# would see: the script's own exit is 0 when every arm it still has passes.
#
# This is the one nix-unit cell gen-demo declares. `mkCi` takes `testModules` as a required formal
# and an empty collection reports `0/0 successful` at exit 0 — a green gate asserting nothing, run
# by `nix flake check ./ci` and by the pre-commit hook on every `.nix` commit. One cell that can
# fail is what makes that plane non-vacuous, and this is the invariant worth spending it on.
#
# The four figures are read from the arm labels rather than declared twice, so the cell fails on
# each distinct way the discipline can erode: an arm deleted (`totalArms`), a row left one-sided
# (`plantedOnly` / `unplantedOnly`), a whole row deleted (`paired`).
{ lib, ... }:
let
  armLabels = builtins.filter (m: m != null) (
    map (line: builtins.match "check \"T5 row([0-9]+) +(planted|unplanted).*" line) (
      lib.splitString "\n" (builtins.readFile ../refusals.sh)
    )
  );

  rowsCarrying =
    arm:
    lib.unique (
      map (m: builtins.elemAt m 0) (builtins.filter (m: builtins.elemAt m 1 == arm) armLabels)
    );

  planted = rowsCarrying "planted";
  unplanted = rowsCarrying "unplanted";
in
{
  flake.tests.refusals = {
    test-every-row-runs-both-planted-and-unplanted = {
      expr = {
        totalArms = builtins.length armLabels;
        paired = builtins.length (lib.intersectLists planted unplanted);
        plantedOnly = lib.subtractLists unplanted planted;
        unplantedOnly = lib.subtractLists planted unplanted;
      };
      expected = {
        totalArms = 33;
        paired = 16;
        # Row 17 is the deliberate exception and the only one: it is a THIRD PLANTED arm, asserting
        # that the forged registry refuses CATCHABLY rather than by overflowing the stack, so it has
        # no unplanted counterpart to carry. Adding a row here is a decision, not a fixture update.
        plantedOnly = [ "17" ];
        unplantedOnly = [ ];
      };
    };
  };
}
