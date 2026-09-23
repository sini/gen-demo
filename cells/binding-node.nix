# `binding-node` — C3. The binding minted, identified by its own labelled relata.
#
# C3 — the binding node minted, identified by its labelled relata. The expected
# edges are read off `bastingRelata` by construction — same source C4's carrier reads —
# rather than restated as literal labels, so a relabelling at the shared source cannot
# make this check collaterally red for the wrong reason (C3 still mints; only the
# carrier's own disjointness is what a relabelling seed is meant to move).
{
  asserts,
  bastingRelata,
  lib,
  minted,
}:
{
  construct = [ "C3" ];
  check = asserts (
    builtins.attrNames minted.nodes == [
      "basting:pewter:grosgrain"
      "grosgrain"
      "pewter"
    ]
    &&
      minted.edges == map (l: {
        from = "basting:pewter:grosgrain";
        label = l;
        to = bastingRelata.${l};
      }) (builtins.attrNames bastingRelata)
    && lib.hasPrefix "basting:" minted.nodes."basting:pewter:grosgrain".identity
  );
}
