# `delivery-class-map-missing-entry-refused` — C118, den-hoag-htfv3. With no map entry for `ruffle`,
# its content stays under the authored class `couching`, which has no terminal, so the realization
# refuses, catchably, rather than dropping `ruffle` (the message is read in `refusals` row 131). The
# control is the same projection with the entry: it realizes all three nodes.
{
  asserts,
  couchingMissingRealized,
  couchingRealized,
}:
let
  forces = v: (builtins.tryEval (builtins.deepSeq v v)).success;
in
{
  construct = [ "one-projection-realizes-on-two-pins" ];
  check = asserts (
    !(forces couchingMissingRealized)
    && forces couchingRealized
    &&
      builtins.attrNames couchingRealized.couching-batiste
      ++ builtins.attrNames couchingRealized.couching-organza == [
        "godet"
        "jabot"
        "ruffle"
      ]
  );
}
