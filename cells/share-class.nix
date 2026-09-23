# `share-class` — C9. The partition on `weave`, the core's shared keys and values, the gate on a
# real member, and the invariance check all in one cell.
#
# C9 — a SHARE class over declared content (`weave`): the "keys narrow, the gate
# decides" discipline asserted as both the partition and the byte gate.
{
  asserts,
  pewterShared,
  plainCore,
  plainGate,
  plainInvariance,
  shareClasses,
}:
{
  construct = [ "C9" ];
  check = asserts (
    map (c: c.key) shareClasses == [
      "plain"
      "twill"
    ]
    &&
      map (c: c.members) shareClasses == [
        [
          "damask"
          "pewter"
        ]
        [
          "faille"
          "grosgrain"
        ]
      ]
    &&
      map (c: c.archetype) shareClasses == [
        "damask"
        "faille"
      ]
    && plainCore.sharedKeys == [ "weave" ]
    && plainCore.values == { weave = "plain"; }
    &&
      pewterShared == {
        spool = "linen";
        weave = "plain";
      }
    && plainGate.gate == true
    && plainGate.candidateDigest == plainGate.realDigest
    &&
      plainInvariance == {
        divergingKeys = [ "spool" ];
        invariant = false;
      }
  );
}
