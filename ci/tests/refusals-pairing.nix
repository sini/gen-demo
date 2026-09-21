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
        # Stated as a DELTA against what `refusals.sh` carried before, never as an absolute target
        # lifted from a document: 41 arms / 20 paired was read off the script at gen-demo `3c53cbd`
        # (den-hoag-4kh.53.13's row22/row23 land in this same file but carry no `T5`/planted/
        # unplanted label — 0 of this regex's arms, by design and stated in their own comment — so
        # they move neither figure). den-hoag-n03z's row24 is an ordinary paired row — +2 arms,
        # +1 paired. den-hoag-row12-message-cells-wrong-plane-x2stm's rows 25 and 26 are two more
        # ordinary paired rows — +4 arms, +2 paired — and row26's third arm is labelled "control"
        # (a distinct word, row24's reasoning below) so it stays outside this regex's population.
        # den-hoag-viewrelation-definition-graph-alphabet-seam-og383's row27 — the definition⟂graph
        # alphabet seam — is one more ordinary paired row: +2 arms, +1 paired.
        # den-hoag-nn4's row28 — a kind-declaration key no reader consumes — is one more ordinary
        # paired row: +2 arms, +1 paired. den-hoag-6vgwm's row29 — a collection key colliding with
        # gen-schema's own vocabulary, row28's mirror image on the other side of one `elem` — is one
        # more ordinary paired row: +2 arms, +1 paired.
        totalArms = 53;
        paired = 26;
        # Row 17 is still the only THIRD-ARM row counted here as `plantedOnly`, and row24 (den-hoag-
        # n03z) does NOT join it despite also carrying a third `catchable` arm: row17's catchable
        # check is its SOLE arm (no unplanted counterpart of its own to carry), so labelling it
        # "planted" is the only way it registers at all — a deliberate decision, not a fixture
        # update. row24's catchable check is a THIRD arm alongside an already-complete planted+
        # unplanted pair; that pair alone fully discharges the pairing discipline for row24, so its
        # catchable arm is additional and orthogonal, not itself planted-only. Labelling it "T5
        # row24 catchable" (a distinct word, not "planted") keeps it correctly outside this regex's
        # population instead of manufacturing a spurious `plantedOnly` entry for a row that is not
        # one-sided.
        plantedOnly = [ "17" ];
        unplantedOnly = [ ];
      };
    };
  };
}
