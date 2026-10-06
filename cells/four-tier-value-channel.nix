# `four-tier-value-channel` — C114, den-hoag-zakjg U4 (ADR-0029, four-tier C′). The owner's four
# canonical cases and the seed, each read on BOTH sides: the list the substrate moved, and the value
# the receiver resolves from it. The head letter decides first and structure only within one:
#   k1 both set ⇒ the more specific root wins; k2 a set beats a default; k3 a default beats a
#   contributor holding only the declared default; k4 a force beats a set. k5 and k6 move nothing
#   and the receiver reads its own declared default (the seed).
# Control that structure is read at all: with continuing ranked above stopping, k1 flips to `T`.
# One tie within a head: two set contributors at one distance are refused under `refuse` and folded
# in a declared position order under `orderedFold`.
# The receiver's red arm (`gRecvHost_k4`): the host's own evaluation, given the moved `TF` beside its
# own `R`, refuses, where the receiver of spec §8 U4 reads `TF`.
#
# Red: placing every moved record at the `set` head (the landed pieces composed with no tier) reads
# k2 `RD` and k4 `R`.
{
  asserts,
  fourTier,
  genView,
}:
let
  ok = x: builtins.tryEval (builtins.deepSeq x x);
  read =
    k: args:
    let
      c = fourTier.case k args;
    in
    {
      inherit (c) moved received;
    };
  tie =
    tieSet:
    (fourTier.channel {
      contributions = {
        r = [ ];
        t = [ "T" ];
        u = [ "U" ];
      };
      inherit tieSet;
    }).moved;
in
{
  construct = [ "four-tier-value-channel-joined-to-provenance" ];
  check = asserts (
    read "k1" { } == {
      moved = [ "R" ];
      received = "R";
    }
    &&
      read "k2" { } == {
        moved = [ "T" ];
        received = "T";
      }
    &&
      read "k3" { } == {
        moved = [ "TD" ];
        received = "TD";
      }
    &&
      read "k4" { } == {
        moved = [ "TF" ];
        received = "TF";
      }
    &&
      read "k5" { } == {
        moved = [ ];
        received = "RD";
      }
    &&
      read "k6" { } == {
        moved = [ ];
        received = "RD";
      }
    &&
      read "k1" { endOfPath = 1; } == {
        moved = [ "T" ];
        received = "T";
      }
    && !(ok (tie (_: genView.tieSets.refuse))).success
    &&
      tie (
        pos:
        genView.tieSets.orderedFold {
          order = [
            (pos.position "u" "set")
            (pos.position "t" "set")
          ];
        }
      ) == [
        "U"
        "T"
      ]
    && !(ok (fourTier.case "k4" { }).receivedByHost).success
  );
}
