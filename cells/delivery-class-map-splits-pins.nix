# `delivery-class-map-splits-pins` — C118, den-hoag-htfv3. One authored class, `couching`, realizes
# on two pins out of one projection: `godet` and `jabot` reach `couching-batiste`, stamped `batiste`,
# and each reads only the other and itself as peers; `ruffle` reaches `couching-organza`, stamped
# `organza`, and reads only itself. No `couching` set is realized. Without the map every node's
# content sat under `couching`, one terminal for all three pins.
{
  asserts,
  couchingRealized,
}:
let
  at = pin: peers: {
    stitches = [ "braid" ];
    inherit pin peers;
  };
in
{
  construct = [ "one-projection-realizes-on-two-pins" ];
  check = asserts (
    couchingRealized == {
      couching-batiste = {
        godet = at "batiste" [
          "godet"
          "jabot"
        ];
        jabot = at "batiste" [
          "godet"
          "jabot"
        ];
      };
      couching-organza.ruffle = at "organza" [ "ruffle" ];
    }
  );
}
