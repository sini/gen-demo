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
# This is the one nix-unit cell gen-demo declares against the refusals plane. `mkCi` takes
# `testModules` as a required formal and an empty collection reports `0/0 successful` at exit 0 — a
# green gate asserting nothing. One cell that can fail is what makes that plane non-vacuous, and
# this is the invariant worth spending it on.
#
# The rows are files (`ci/refusals/*.sh`, discovered, never listed), so every figure here is read
# off the arm labels in those files and none is a count someone must bump when a row lands. The
# cell fails on each distinct way the discipline can erode: a row left one-sided (`plantedOnly` /
# `unplantedOnly`), and a row file whose arms this regex cannot see at all (`filesWithoutAPair`) —
# a label that drops the `T5 <id> planted|unplanted` form would otherwise leave its row outside
# the population, which reads exactly like a row that needs no pairing.
{ lib, ... }:
let
  rowDir = ../refusals;
  rowFiles = builtins.attrNames (
    lib.filterAttrs (file: type: type == "regular" && lib.hasSuffix ".sh" file) (
      builtins.readDir rowDir
    )
  );

  armsIn =
    file:
    builtins.filter (m: m != null) (
      map (line: builtins.match "check \"T5 ([a-z0-9-]+) +(planted|unplanted).*" line) (
        lib.splitString "\n" (builtins.readFile (rowDir + "/${file}"))
      )
    );

  armLabels = lib.concatMap armsIn rowFiles;

  rowsCarrying =
    arms: arm:
    lib.unique (map (m: builtins.elemAt m 0) (builtins.filter (m: builtins.elemAt m 1 == arm) arms));

  planted = rowsCarrying armLabels "planted";
  unplanted = rowsCarrying armLabels "unplanted";

  pairedIn =
    file:
    let
      arms = armsIn file;
    in
    lib.intersectLists (rowsCarrying arms "planted") (rowsCarrying arms "unplanted");
in
{
  flake.tests.refusals = {
    test-every-row-runs-both-planted-and-unplanted = {
      expr = {
        # A floor on the population, so the cell cannot pass over a directory it failed to read.
        readsRows = builtins.length rowFiles > 0 && builtins.length armLabels > 0;
        plantedOnly = lib.subtractLists unplanted planted;
        unplantedOnly = lib.subtractLists planted unplanted;
        filesWithoutAPair = builtins.filter (file: pairedIn file == [ ]) rowFiles;
      };
      expected = {
        readsRows = true;
        # Row 17 is the only THIRD-ARM row counted here as `plantedOnly`: its catchable check is
        # its SOLE arm (no unplanted counterpart of its own to carry), so labelling it "planted" is
        # the only way it registers at all — a deliberate decision, not a fixture update. Every
        # other third arm (row24's and later) is labelled "catchable" or "control", a distinct word,
        # alongside an already-complete planted+unplanted pair, so it stays outside this population
        # instead of manufacturing a spurious one-sided row.
        plantedOnly = [ "row17" ];
        unplantedOnly = [ ];
        # row22/row23 (den-hoag-4kh.53.13) carry no `T5`/planted/unplanted label by design — they
        # assert an id's stability, not a refusal — so their file carries no pair.
        filesWithoutAPair = [ "row22-23.sh" ];
      };
    };
  };
}
